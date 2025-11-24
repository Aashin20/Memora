//
//  PostOptionsViewController.swift
//  Home
//
//  Updated to integrate Memory model / MemoryStore (local save fallback)
//

import UIKit

final class PostOptionsViewController: UIViewController {
    weak var delegate: PostOptionsViewControllerDelegate?

    // MARK: — New: optional inputs from caller (PromptDetailViewControllerSimple should set these)
    /// If provided, these images and audio files will be saved into the Memory when posting locally.
    public var autoSaveToLocalStoreIfNoDelegate: Bool = true
    public var bodyText: String? = nil                       // body content from text view
    public var userImages: [UIImage] = []                    // images picked by user
    public var userAudioFiles: [(url: URL, duration: TimeInterval)] = [] // temp audio files recorded
    public var promptFallbackImageURL: String? = nil         // remote prompt image to use if user didn't attach one

    // MARK: UI
    private let dimView = UIControl()
    private let container = UIView()
    private let headingLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let titleField = UITextField()
    private let yearField = UITextField()

    // Visibility dropdown button (capsule)
    private let visibilityButton = UIButton(type: .system)
    private var visibilityMenuAnchor: UIView? // not used for popover; kept for clarity
    private var selectedVisibility: Visibility = .everyone {
        didSet { updateVisibilityButtonTitle() }
    }

    // schedule
    private var selectedScheduleDate: Date = Date()
    private var scheduleChosen: Bool = false // true if user explicitly chose schedule and date

    // buttons
    private let postButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    // SAVE loader UI
    private var savingOverlay: UIView?
    private var activityIndicator: UIActivityIndicatorView?

    // constraints for keyboard movement
    private var containerCenterY: NSLayoutConstraint?

    // keyboard observers
    private var keyboardObserversAdded = false

    // small validation helpers
    private enum Visibility {
        case everyone, `private`, schedule
        var asMemoryVisibility: MemoryVisibility {
            switch self {
            case .everyone: return .everyone
            case .private: return .private
            case .schedule: return .scheduled
            }
        }
        var title: String {
            switch self {
            case .everyone: return "Everyone"
            case .private: return "Private"
            case .schedule: return "Schedule"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        view.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        setupUI()
        setupActions()
        updateVisibilityButtonTitle()
        updatePostButtonState()
        addKeyboardObservers()
    }

    deinit {
        removeKeyboardObservers()
    }

    // MARK: UI Setup
    private func setupUI() {
        // dim background to dismiss
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor(white: 0, alpha: 0.28)
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        dimView.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)

        // container
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 20
        container.clipsToBounds = true
        view.addSubview(container)

        // heading
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.text = "Post your memory"
        headingLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        headingLabel.textColor = .label
        container.addSubview(headingLabel)

        // description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "A short description should be a short, complete sentence."
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.textColor = .secondaryLabel
        container.addSubview(descriptionLabel)

        // title field
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.placeholder = "Title (required)"
        titleField.borderStyle = .roundedRect
        titleField.returnKeyType = .next
        titleField.autocapitalizationType = .sentences
        container.addSubview(titleField)

        // year field (kept for compatibility with your UI)
        yearField.translatesAutoresizingMaskIntoConstraints = false
        yearField.placeholder = "Year (e.g. 1999) (required)"
        yearField.borderStyle = .roundedRect
        yearField.keyboardType = .numberPad
        container.addSubview(yearField)

        // visibility capsule button
        visibilityButton.translatesAutoresizingMaskIntoConstraints = false
        visibilityButton.setTitleColor(.label, for: .normal)
        visibilityButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        visibilityButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        visibilityButton.layer.cornerRadius = 20
        visibilityButton.layer.masksToBounds = true
        visibilityButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        container.addSubview(visibilityButton)

        // post button (black capsule)
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.setTitle("Post", for: .normal)
        postButton.setTitleColor(.white, for: .normal)
        postButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        postButton.backgroundColor = .black
        postButton.layer.cornerRadius = 28
        postButton.layer.masksToBounds = true
        container.addSubview(postButton)

        // cancel
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        container.addSubview(cancelButton)

        // Layout constraints
        // center vertically with adjustable centerY for keyboard
        containerCenterY = container.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0)
        containerCenterY?.isActive = true

        NSLayoutConstraint.activate([
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 360),

            headingLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            headingLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            headingLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),

            descriptionLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            descriptionLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            descriptionLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 8),

            titleField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            titleField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            titleField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 18),
            titleField.heightAnchor.constraint(equalToConstant: 46),

            yearField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            yearField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            yearField.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 12),
            yearField.heightAnchor.constraint(equalToConstant: 46),

            visibilityButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            visibilityButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -18),
            visibilityButton.topAnchor.constraint(equalTo: yearField.bottomAnchor, constant: 18),
            visibilityButton.heightAnchor.constraint(equalToConstant: 48),

            postButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 36),
            postButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -36),
            postButton.topAnchor.constraint(equalTo: visibilityButton.bottomAnchor, constant: 22),
            postButton.heightAnchor.constraint(equalToConstant: 56),

            cancelButton.topAnchor.constraint(equalTo: postButton.bottomAnchor, constant: 12),
            cancelButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
    }

    // MARK: Setup Actions
    private func setupActions() {
        visibilityButton.addTarget(self, action: #selector(visibilityTapped), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(postTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        // text change observers
        titleField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        yearField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)

        // navigate between fields
        titleField.delegate = self
        yearField.delegate = self

        // tap background to dismiss keyboard handled by dimView in setup
    }

    // MARK: Keyboard handling
    private func addKeyboardObservers() {
        guard !keyboardObserversAdded else { return }
        keyboardObserversAdded = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func removeKeyboardObservers() {
        if keyboardObserversAdded {
            NotificationCenter.default.removeObserver(self)
            keyboardObserversAdded = false
        }
    }

    @objc private func keyboardWillShow(_ note: Notification) {
        guard let info = note.userInfo,
              let frameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let kbFrame = frameValue.cgRectValue
        // Move container up so bottom of container is above keyboard by ~12 px
        // compute overlap in screen coordinates
        let containerFrame = container.convert(container.bounds, to: view)
        let overlap = max(0, (containerFrame.maxY) - (view.bounds.height - kbFrame.height))
        containerCenterY?.constant = -overlap - 12

        let options = UIView.AnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        guard let info = note.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        containerCenterY?.constant = 0
        let options = UIView.AnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: Visibility dropdown
    @objc private func visibilityTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: Visibility.everyone.title, style: .default, handler: { _ in
            self.selectedVisibility = .everyone
            self.scheduleChosen = false
            self.updatePostButtonState()
        }))
        alert.addAction(UIAlertAction(title: Visibility.private.title, style: .default, handler: { _ in
            self.selectedVisibility = .private
            self.scheduleChosen = false
            self.updatePostButtonState()
        }))
        alert.addAction(UIAlertAction(title: Visibility.schedule.title, style: .default, handler: { _ in
            self.selectedVisibility = .schedule
            // present date/time picker sheet after selecting schedule
            self.presentSchedulePicker()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad, show as popover anchored to the button
        if let p = alert.popoverPresentationController {
            p.sourceView = visibilityButton
            p.sourceRect = visibilityButton.bounds
        }

        present(alert, animated: true)
    }

    private func presentSchedulePicker() {
        // show a small alert controller with an inline date picker (UIDatePicker)
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.date = selectedScheduleDate

        let alert = UIAlertController(title: "Select schedule date", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
        alert.modalPresentationStyle = .automatic
        alert.view.addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false

        // Pin picker into alert
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: alert.view.leadingAnchor, constant: 8),
            picker.trailingAnchor.constraint(equalTo: alert.view.trailingAnchor, constant: -8),
            picker.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 8),
            picker.heightAnchor.constraint(equalToConstant: 200)
        ])

        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            self.selectedScheduleDate = picker.date
            self.scheduleChosen = true
            self.updateVisibilityButtonTitle()
            self.updatePostButtonState()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            // if user cancels schedule selection, revert visibility to Everyone
            if self.selectedVisibility == .schedule && !self.scheduleChosen {
                self.selectedVisibility = .everyone
            }
            self.updateVisibilityButtonTitle()
            self.updatePostButtonState()
        }))

        if let p = alert.popoverPresentationController {
            p.sourceView = visibilityButton
            p.sourceRect = visibilityButton.bounds
        }

        present(alert, animated: true)
    }

    private func updateVisibilityButtonTitle() {
        var title = selectedVisibility.title
        if selectedVisibility == .schedule, scheduleChosen {
            // show short selected date on button as suffix
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .short
            title = "\(f.string(from: selectedScheduleDate))"
        }
        // Keep it bold-ish and centered
        let att = NSMutableAttributedString(string: title)
        visibilityButton.setAttributedTitle(att, for: .normal)
    }

    // MARK: Posting
    @objc private func postTapped() {
        // validate
        guard let titleText = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !titleText.isEmpty else {
            showValidationError("Please enter a title (required).")
            return
        }

        guard let yearText = yearField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !yearText.isEmpty else {
            showValidationError("Please enter the year (required).")
            return
        }

        // simple 4-digit year check
        if yearText.count != 4 || Int(yearText) == nil {
            showValidationError("Please enter a valid 4-digit year (e.g. 1999).")
            return
        }

        if selectedVisibility == .schedule && !scheduleChosen {
            // require schedule date if schedule selected
            showValidationError("Please choose a schedule date and time.")
            return
        }

        // everything ok — either call delegate or persist locally if no delegate
        let visibility = selectedVisibility.asMemoryVisibility
        let scheduleDate = selectedVisibility == .schedule ? selectedScheduleDate : nil

        if let d = delegate {
            // still call delegate so PromptDetailViewControllerSimple can handle posting flow (and attachments handling)
            d.postOptionsViewController(self, didFinishPostingWithTitle: titleText, scheduleDate: scheduleDate, visibility: visibility)
            // leave dismissal / navigation to delegate (as before)
            return
        }

        guard autoSaveToLocalStoreIfNoDelegate else {
            // No delegate and auto save disabled: just dismiss
            dismiss(animated: true, completion: nil)
            return
        }

        // Start loader + disable UI
        showSavingOverlay()
        setControlsEnabled(false)

        // create local Memory using MemoryStore
        // Build a title/body; use `bodyText` provided by caller if available.
        let body = (bodyText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) ? nil : bodyText

        // Owner id — try to use Session.shared.currentUser.id if available.
        // Be defensive: Session.shared.currentUser.id might be UUID or String. Convert to String safely.
        let ownerId: String = {
            let raw = Session.shared.currentUser.id
            if let s = raw as? String { return s }
            if let u = raw as? UUID { return u.uuidString }
            return String(describing: raw)
        }()

        // We'll perform attachment saving on a background queue.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var memAttachments: [MemoryAttachment] = []
            let group = DispatchGroup()

            // Save image attachments (bundled images user provided)
            for img in self.userImages {
                do {
                    let fname = try MemoryStore.shared.saveImageAttachment(img)
                    let ma = MemoryAttachment(kind: .image, filename: fname)
                    memAttachments.append(ma)
                } catch {
                    print("PostOptions: failed to save image attachment:", error)
                }
            }

            // Save audio attachments
            for audio in self.userAudioFiles {
                do {
                    let fname = try MemoryStore.shared.saveAudioAttachment(at: audio.url)
                    let ma = MemoryAttachment(kind: .audio, filename: fname)
                    memAttachments.append(ma)
                } catch {
                    print("PostOptions: failed to save audio attachment:", error)
                }
            }

            // If no user images and a prompt fallback URL exists, try downloading and saving it asynchronously
            if !memAttachments.contains(where: { $0.kind == .image }),
               let fallback = self.promptFallbackImageURL,
               !fallback.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let u = URL(string: fallback),
               (u.scheme?.starts(with: "http") ?? false) {
                group.enter()
                self.downloadImage(from: u, timeout: 15.0) { result in
                    switch result {
                    case .success(let img):
                        do {
                            let fname = try MemoryStore.shared.saveImageAttachment(img)
                            let ma = MemoryAttachment(kind: .image, filename: fname)
                            // put fallback image as first attachment
                            memAttachments.insert(ma, at: 0)
                        } catch {
                            print("PostOptions: failed to save downloaded prompt image:", error)
                        }
                    case .failure(let err):
                        print("PostOptions: couldn't download fallback prompt image:", err)
                    }
                    group.leave()
                }
            }

            // Wait for any downloads to finish (bounded) before creating memory
            let waitResult = group.wait(timeout: .now() + 20)
            if waitResult == .timedOut {
                print("PostOptions: fallback image download timed out")
            }

            // Persist via MemoryStore.createMemory (preferred pattern used elsewhere)
            MemoryStore.shared.createMemory(ownerId: ownerId,
                                            title: titleText,
                                            body: body,
                                            attachments: memAttachments,
                                            visibility: visibility,
                                            scheduledFor: scheduleDate) { result in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    switch result {
                    case .success(let memory):
                        // Print the saved memory (pretty JSON if Encodable)
                        do {
                            let enc = JSONEncoder()
                            enc.outputFormatting = [.prettyPrinted, .sortedKeys]
                            let data = try enc.encode(memory)
                            if let s = String(data: data, encoding: .utf8) {
                                print("Memory saved (JSON):\n\(s)")
                            } else {
                                print("Memory saved:", memory)
                            }
                        } catch {
                            print("Memory saved:", memory)
                        }

                        // notify that memories updated
                        NotificationCenter.default.post(name: .memoriesUpdated, object: nil, userInfo: ["memoryId": memory.id])

                        // Show toast above overlay, keep overlay visible briefly, then hide and navigate back (pop)
                        self.showToastAboveOverlay(message: "Memory is now posted")

                        // Allow user to see toast briefly, then hide overlay and navigate back.
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            self.hideSavingOverlay()
                            self.setControlsEnabled(true)

                            // Attempt to pop one screen (go back) instead of forcing Home.
                            // Strategy: first try to find the presenting navigation controller (if any), else the controller's own nav.
                            if let nav = Self.findAppropriateNavigationController(startingFrom: self.presentingViewController) {
                                nav.popViewController(animated: true)
                                // If the PostOptions was presented modally above a pushed VC, we also dismiss PostOptions.
                                self.dismiss(animated: true, completion: nil)
                                return
                            }

                            if let navSelf = self.navigationController {
                                navSelf.popViewController(animated: true)
                                // If PostOptions was presented modally, dismiss it too:
                                self.dismiss(animated: true, completion: nil)
                                return
                            }

                            // Fallback: just dismiss this modal
                            self.dismiss(animated: true, completion: nil)
                        }

                    case .failure(let err):
                        // hide overlay and re-enable controls, then show error
                        self.hideSavingOverlay()
                        self.setControlsEnabled(true)
                        self.showValidationError("Failed saving memory: \(err.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Async image downloader helper
    private func downloadImage(from url: URL, timeout: TimeInterval = 15.0, completion: @escaping (Result<UIImage, Error>) -> Void) {
        var req = URLRequest(url: url)
        req.timeoutInterval = timeout
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = timeout
        cfg.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: cfg)
        let task = session.dataTask(with: req) { data, response, error in
            if let err = error { completion(.failure(err)); return }
            guard let d = data, let img = UIImage(data: d) else {
                let err = NSError(domain: "PostOptionsDownload", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                completion(.failure(err)); return
            }
            completion(.success(img))
        }
        task.resume()
    }

    // MARK: UI helpers: loader / toast

    /// Return a robust host view for overlays/toasts (tries scene window, then keyWindow, then topmost view controller view)
    private func hostWindowView() -> UIView? {
        // 1) Try to use a foreground window scene's key window (iOS 13+)
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
                if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    return window
                }
                // fallback: any visible window
                if let window = windowScene.windows.first(where: { $0.isHidden == false }) {
                    return window
                }
            }
        }

        // 2) Fallback to UIApplication windows
        if let w = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            return w
        }
        if let w = UIApplication.shared.windows.first(where: { $0.isHidden == false }) {
            return w
        }

        // 3) Last resort: topmost view controller's view
        if let top = Self.topMostViewController() {
            return top.view
        }

        // 4) Final fallback: self.view (guaranteed non-nil while visible)
        return self.view
    }

    /// Return the top most view controller by walking presentedViewController / child controllers
    private static func topMostViewController() -> UIViewController? {
        // Try scene/window root
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }),
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                var top = window.rootViewController
                while let presented = top?.presentedViewController { top = presented }
                return top
            }
        }
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }), let root = window.rootViewController {
            var top = root
            while let presented = top.presentedViewController { top = presented }
            return top
        }
        return nil
    }

    private func showSavingOverlay() {
        DispatchQueue.main.async {
            // avoid adding twice
            if let existing = self.savingOverlay {
                print("[PostOptions] showSavingOverlay: overlay already present: \(existing)")
                return
            }

            guard let host = self.hostWindowView() else {
                print("[PostOptions] showSavingOverlay: no host window/view found (shouldn't happen)")
                return
            }

            // overlay (blocks interactions underneath)
            let overlay = UIView()
            overlay.backgroundColor = UIColor(white: 0, alpha: 0.35)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.alpha = 0.0
            overlay.isUserInteractionEnabled = true

            // blurred box container for spinner + label
            let blur = UIBlurEffect(style: .systemMaterial)
            let blurView = UIVisualEffectView(effect: blur)
            blurView.layer.cornerRadius = 12
            blurView.layer.masksToBounds = true
            blurView.translatesAutoresizingMaskIntoConstraints = false

            // spinner
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.startAnimating()
            self.activityIndicator = indicator

            // label
            let lbl = UILabel()
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            lbl.text = "Saving…"
            lbl.textColor = .label

            blurView.contentView.addSubview(indicator)
            blurView.contentView.addSubview(lbl)
            overlay.addSubview(blurView)
            host.addSubview(overlay)

            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: host.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: host.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: host.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: host.bottomAnchor),

                blurView.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                blurView.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                blurView.widthAnchor.constraint(equalToConstant: 160),
                blurView.heightAnchor.constraint(equalToConstant: 120),

                indicator.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
                indicator.topAnchor.constraint(equalTo: blurView.topAnchor, constant: 18),

                lbl.centerXAnchor.constraint(equalTo: blurView.centerXAnchor),
                lbl.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 12)
            ])

            self.savingOverlay = overlay
            host.layoutIfNeeded()
            UIView.animate(withDuration: 0.18) { overlay.alpha = 1.0 }
            print("[PostOptions] showSavingOverlay: added overlay to host: \(String(describing: host))")
        }
    }

    private func hideSavingOverlay() {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.activityIndicator = nil
            if let overlay = self.savingOverlay {
                UIView.animate(withDuration: 0.18, animations: {
                    overlay.alpha = 0.0
                }, completion: { _ in
                    overlay.removeFromSuperview()
                })
            }
            self.savingOverlay = nil
            print("[PostOptions] hideSavingOverlay: removed overlay")
        }
    }

    private func setControlsEnabled(_ enabled: Bool) {
        DispatchQueue.main.async {
            self.postButton.isEnabled = enabled
            self.cancelButton.isEnabled = enabled
            self.titleField.isEnabled = enabled
            self.yearField.isEnabled = enabled
            self.visibilityButton.isEnabled = enabled
            self.postButton.alpha = enabled ? 1.0 : 0.55
        }
    }

    /// Shows a toast above the overlay (sliding animation)
    private func showToastAboveOverlay(message: String) {
        DispatchQueue.main.async {
            guard let host = self.hostWindowView() else {
                print("[PostOptions] showToastAboveOverlay: no host window found")
                return
            }

            // create toast
            let toast = UILabel()
            toast.translatesAutoresizingMaskIntoConstraints = false
            toast.backgroundColor = UIColor(white: 0, alpha: 0.85)
            toast.textColor = .white
            toast.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            toast.textAlignment = .center
            toast.text = message
            toast.layer.cornerRadius = 10
            toast.layer.masksToBounds = true
            toast.alpha = 0.0

            host.addSubview(toast)

            let safe = host.safeAreaLayoutGuide
            // initial offscreen constraint
            let centerX = toast.centerXAnchor.constraint(equalTo: host.centerXAnchor)
            let bottom = toast.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: 80)
            NSLayoutConstraint.activate([
                centerX,
                bottom,
                toast.widthAnchor.constraint(lessThanOrEqualToConstant: 340),
                toast.heightAnchor.constraint(equalToConstant: 44)
            ])
            host.layoutIfNeeded()

            // animate up
            bottom.constant = -48
            UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6, options: [], animations: {
                toast.alpha = 1.0
                host.layoutIfNeeded()
            }, completion: { _ in
                // visible for a moment then slide down
                UIView.animate(withDuration: 0.22, delay: 1.0, options: [], animations: {
                    toast.alpha = 0.0
                    bottom.constant = 80
                    host.layoutIfNeeded()
                }, completion: { _ in
                    toast.removeFromSuperview()
                })
            })
            print("[PostOptions] showToastAboveOverlay: toast shown")
        }
    }

    // Helper: attempt to find a navigation controller by walking presenting chain or inspecting view controllers
    private static func findAppropriateNavigationController(startingFrom vc: UIViewController?) -> UINavigationController? {
        var cur = vc
        // Walk up the presenting chain and check for navigation controllers or navigationController property
        while let c = cur {
            if let nav = c as? UINavigationController { return nav }
            if let nav = c.navigationController { return nav }
            cur = c.presentingViewController
        }
        return nil
    }

    // Helper: best-effort root navigation controller fallback (scene-aware)
    private static func rootNavigationControllerFallback() -> UINavigationController? {
        // iOS 13+ scene-safe way
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            for scene in scenes {
                if scene.activationState == .foregroundActive || scene.activationState == .foregroundInactive {
                    if let windowScene = scene as? UIWindowScene {
                        for window in windowScene.windows where window.isKeyWindow {
                            if let nav = window.rootViewController as? UINavigationController { return nav }
                            if let tab = window.rootViewController as? UITabBarController, let nav = tab.viewControllers?.first as? UINavigationController { return nav }
                        }
                    }
                }
            }
        }
        // Fallback to deprecated keyWindow (works in many cases)
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            if let nav = window.rootViewController as? UINavigationController { return nav }
            if let tab = window.rootViewController as? UITabBarController, let nav = tab.viewControllers?.first as? UINavigationController { return nav }
        }
        return nil
    }

    // Helper: dismiss all presented view controllers starting from the app root (robust)
    private func dismissEntirePresentedStack(completion: (() -> Void)? = nil) {
        // Try scene-aware key window first (iOS 13+)
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }),
               let window = windowScene.windows.first(where: { $0.isKeyWindow }),
               let root = window.rootViewController {
                // Dismissing root will dismiss any presented view controllers on top of it.
                root.dismiss(animated: true, completion: completion)
                return
            }
        }

        // Fallback to UIApplication.windows
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
           let root = window.rootViewController {
            root.dismiss(animated: true, completion: completion)
            return
        }

        // Last resort: dismiss this controller only
        self.dismiss(animated: true, completion: completion)
    }

    private func showValidationError(_ message: String) {
        let a = UIAlertController(title: "Missing info", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    @objc private func cancelTapped() {
        delegate?.postOptionsViewControllerDidCancel(self)
    }

    @objc private func dismissTapped() {
        view.endEditing(true)
    }

    // MARK: Text events
    @objc private func textDidChange(_ t: UITextField) {
        updatePostButtonState()
    }

    private func updatePostButtonState() {
        // simple validation: title non-empty and year 4-digit numeric
        let titleOK = !(titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let yearText = yearField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let yearOK = (yearText.count == 4 && Int(yearText) != nil)

        let visibilityOK: Bool = {
            if selectedVisibility == .schedule {
                return scheduleChosen
            }
            return true
        }()

        let enabled = titleOK && yearOK && visibilityOK
        postButton.isEnabled = enabled
        postButton.alpha = enabled ? 1.0 : 0.55
    }
}

// MARK: UITextFieldDelegate
extension PostOptionsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === titleField {
            yearField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - Notification name helper
extension Notification.Name {
    static let memoriesUpdated = Notification.Name("memoriesUpdatedNotification")
}
