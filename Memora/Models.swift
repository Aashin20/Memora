import Foundation

// Profile model for the profiles table
struct Profile: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, email
        case createdAt = "created_at"
    }
}

// Prompt model
struct Prompt: Codable, Identifiable {
    let id: String
    let question: String
    let category: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, question, category
        case createdAt = "created_at"
    }
}

// Memory model
struct Memory: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let content: String?
    let mediaUrl: String?
    let mediaType: String?
    let year: Int?
    let category: String?
    let visibility: String
    let scheduledDate: Date?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, year, category, visibility
        case userId = "user_id"
        case mediaUrl = "media_url"
        case mediaType = "media_type"
        case scheduledDate = "scheduled_date"
        case createdAt = "created_at"
    }
}

// For creating new memories
struct MemoryRequest: Codable {
    let title: String
    let content: String?
    let category: String
    let visibility: String
    let year: Int?
}
