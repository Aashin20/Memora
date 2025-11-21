import Foundation
import UIKit

public final class MemoryStore {
    public static let shared = MemoryStore()

    private let queue = DispatchQueue(label: "com.app.MemoryStore", qos: .userInitiated)
    private var memories: [Memory] = []
    private let fileManager = FileManager.default

    // filenames / folders
    private let memoriesFilename = "memories.json"
    private let attachmentsFolder = "attachments"

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var attachmentsURL: URL {
        let u = documentsURL.appendingPathComponent(attachmentsFolder, isDirectory: true)
        if !fileManager.fileExists(atPath: u.path) {
            try? fileManager.createDirectory(at: u, withIntermediateDirectories: true, attributes: nil)
        }
        return u
    }

    private var memoriesFileURL: URL {
        documentsURL.appendingPathComponent(memoriesFilename)
    }

    private init() {
        loadFromDisk()
    }

    // MARK: - Public helpers for attachments

    /// Save a UIImage to the attachments folder and return the filename (not a full path).
    /// Throws on failure.
    public func saveImageAttachment(_ image: UIImage) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw NSError(domain: "MemoryStore", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode image"])
        }
        let name = "img_\(UUID().uuidString).jpg"
        let url = attachmentsURL.appendingPathComponent(name)
        try data.write(to: url, options: .atomic)
        return name
    }

    /// Copy audio file at given url into attachments folder and return saved filename.
    public func saveAudioAttachment(at srcURL: URL) throws -> String {
        let ext = srcURL.pathExtension.isEmpty ? "m4a" : srcURL.pathExtension
        let name = "aud_\(UUID().uuidString).\(ext)"
        let dest = attachmentsURL.appendingPathComponent(name)
        // remove if exists (shouldn't), then copy
        if fileManager.fileExists(atPath: dest.path) {
            try fileManager.removeItem(at: dest)
        }
        try fileManager.copyItem(at: srcURL, to: dest)
        return name
    }

    /// Returns a full URL to an attachment filename saved by this store.
    public func urlForAttachment(filename: String) -> URL {
        return attachmentsURL.appendingPathComponent(filename)
    }

    // MARK: - Memory CRUD

    /// Add memory: persists to disk.
    public func add(_ memory: Memory, completion: ((Result<Void, Error>) -> Void)? = nil) {
        queue.async {
            self.memories.insert(memory, at: 0) // newest first
            do {
                try self.saveToDisk()
                DispatchQueue.main.async { completion?(.success(())) }
            } catch {
                DispatchQueue.main.async { completion?(.failure(error)) }
            }
        }
    }

    /// Create convenience helper that creates a Memory and saves it.
    public func createMemory(ownerId: String,
                             title: String,
                             body: String?,
                             attachments: [MemoryAttachment],
                             visibility: MemoryVisibility,
                             scheduledFor: Date?,
                             category: String? = nil,
                             completion: ((Result<Memory, Error>) -> Void)? = nil) {
        let memory = Memory(ownerId: ownerId,
                            title: title,
                            body: body,
                            category: category,
                            attachments: attachments,
                            visibility: visibility,
                            scheduledFor: scheduledFor)
        add(memory) { result in
            switch result {
            case .success: completion?(.success(memory))
            case .failure(let e): completion?(.failure(e))
            }
        }
    }

    /// Higher-level convenience helper used by PostOptionsViewController:
    /// (kept as in your original implementation)
    public func createMemory(ownerId: String,
                             title: String,
                             body: String?,
                             visibility: MemoryVisibility,
                             scheduledFor: Date?,
                             promptFallbackImageURL: String?,
                             userImages: [UIImage],
                             userAudioFiles: [(url: URL, duration: TimeInterval)],
                             category: String? = nil,
                             completion: ((Result<Memory, Error>) -> Void)? = nil) {
        queue.async {
            var memAttachments: [MemoryAttachment] = []

            for img in userImages {
                do {
                    let fname = try self.saveImageAttachment(img)
                    let ma = MemoryAttachment(kind: .image, filename: fname)
                    memAttachments.append(ma)
                } catch {
                    print("MemoryStore: failed to save image attachment:", error)
                }
            }

            for audio in userAudioFiles {
                do {
                    let fname = try self.saveAudioAttachment(at: audio.url)
                    let ma = MemoryAttachment(kind: .audio, filename: fname)
                    memAttachments.append(ma)
                } catch {
                    print("MemoryStore: failed to save audio attachment:", error)
                }
            }

            if !memAttachments.contains(where: { $0.kind == .image }),
               let fallback = promptFallbackImageURL,
               !fallback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let url = URL(string: fallback) {

                if (url.scheme?.starts(with: "http")) ?? false {
                    if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                        do {
                            let fname = try self.saveImageAttachment(img)
                            let ma = MemoryAttachment(kind: .image, filename: fname)
                            memAttachments.insert(ma, at: 0)
                        } catch {
                            print("MemoryStore: failed to save downloaded fallback image:", error)
                        }
                    } else {
                        print("MemoryStore: couldn't download fallback prompt image at: \(fallback)")
                    }
                } else {
                    if let img = UIImage(named: fallback) {
                        do {
                            let fname = try self.saveImageAttachment(img)
                            let ma = MemoryAttachment(kind: .image, filename: fname)
                            memAttachments.insert(ma, at: 0)
                        } catch {
                            print("MemoryStore: failed to save bundled fallback image:", error)
                        }
                    }
                }
            }

            let memory = Memory(ownerId: ownerId,
                                title: title,
                                body: body,
                                category: category,
                                attachments: memAttachments,
                                visibility: visibility,
                                scheduledFor: scheduledFor)

            self.memories.insert(memory, at: 0)
            do {
                try self.saveToDisk()
                DispatchQueue.main.async { completion?(.success(memory)) }
            } catch {
                if let idx = self.memories.firstIndex(where: { $0.id == memory.id }) {
                    self.memories.remove(at: idx)
                }
                DispatchQueue.main.async { completion?(.failure(error)) }
            }
        }
    }

    /// Update an existing memory in-place (preserves same id).
    /// Replaces title, body and attachments. Removes any local attachment files that were present
    /// on the previous memory but are not referenced in the new attachments list.
    public func updateMemory(id: String,
                             title: String,
                             body: String?,
                             attachments: [MemoryAttachment],
                             completion: ((Result<Void, Error>) -> Void)? = nil) {
        queue.async {
            guard let idx = self.memories.firstIndex(where: { $0.id == id }) else {
                DispatchQueue.main.async {
                    completion?(.failure(NSError(domain: "MemoryStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Memory not found"])))
                }
                return
            }

            // Existing memory and its attachments
            let existing = self.memories[idx]
            let existingFilenames = existing.attachments.map { $0.filename }
            let newFilenames = attachments.map { $0.filename }

            // Determine which local files should be removed: present in existing but NOT present in new
            let toDelete = existingFilenames.filter { fname in
                // skip remote-looking names (http/https)
                let lower = fname.lowercased()
                if lower.hasPrefix("http://") || lower.hasPrefix("https://") { return false }
                // if new references same filename, keep it
                return !newFilenames.contains(where: { $0 == fname })
            }

            var deletionError: Error?
            for fname in toDelete {
                let fileURL = self.attachmentsURL.appendingPathComponent(fname)
                if self.fileManager.fileExists(atPath: fileURL.path) {
                    do {
                        try self.fileManager.removeItem(at: fileURL)
                    } catch {
                        // record but continue
                        print("MemoryStore: failed to remove old attachment \(fileURL):", error)
                        deletionError = error
                    }
                }
            }

            // Update the memory in-memory
            var updated = existing
            updated.title = title
            updated.body = body
            updated.attachments = attachments

            // replace in array (keep same index to preserve ordering)
            self.memories[idx] = updated

            do {
                try self.saveToDisk()
                DispatchQueue.main.async {
                    if let err = deletionError {
                        // we succeeded updating memory but had errors deleting some files
                        completion?(.failure(err))
                    } else {
                        completion?(.success(()))
                    }
                }
            } catch {
                // Attempt rollback by restoring previous memory
                self.memories[idx] = existing
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }

    /// Returns all memories (thread-safe snapshot)
    public func allMemories() -> [Memory] {
        return queue.sync { self.memories }
    }

    // MARK: - DELETE (new public API)

    /// Delete memory with given id. Removes attachment files (if present) and persists updated list.
    /// - completion: called on main queue with success or error
    public func deleteMemory(id: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        queue.async {
            guard let idx = self.memories.firstIndex(where: { $0.id == id }) else {
                DispatchQueue.main.async {
                    completion?(.failure(NSError(domain: "MemoryStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Memory not found"])))
                }
                return
            }

            let mem = self.memories[idx]

            // Attempt to delete attachments on disk. Collect any errors but proceed with removing the memory record.
            var lastError: Error?
            for att in mem.attachments {
                // Only delete attachments that look like local filenames (not remote URL strings)
                if att.filename.lowercased().hasPrefix("http://") || att.filename.lowercased().hasPrefix("https://") {
                    continue
                }
                let fileURL = self.attachmentsURL.appendingPathComponent(att.filename)
                if self.fileManager.fileExists(atPath: fileURL.path) {
                    do {
                        try self.fileManager.removeItem(at: fileURL)
                    } catch {
                        print("MemoryStore: failed to remove attachment \(fileURL):", error)
                        lastError = error
                    }
                }
            }

            // Remove memory from array and try save
            let removed = self.memories.remove(at: idx)
            do {
                try self.saveToDisk()
                DispatchQueue.main.async {
                    completion?(.success(()))
                }
            } catch {
                // If saving failed, attempt to roll-back (reinsert removed memory)
                self.memories.insert(removed, at: idx)
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }

    // MARK: - Persistence (JSON)
    private func loadFromDisk() {
        queue.async {
            do {
                let url = self.memoriesFileURL
                guard self.fileManager.fileExists(atPath: url.path) else {
                    self.memories = []
                    return
                }
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                self.memories = try decoder.decode([Memory].self, from: data)
            } catch {
                print("MemoryStore: failed to load memories:", error)
                self.memories = []
            }
        }
    }

    private func saveToDisk() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self.memories)
        try data.write(to: memoriesFileURL, options: .atomic)
    }
}
