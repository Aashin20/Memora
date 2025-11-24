import Foundation
import UIKit

struct SessionUser: Codable {
    let id: UUID
    let name: String
    let avatarName: String? // asset name or nil
}

final class Session {
    static let shared = Session()

    private init() {
        // create a placeholder user
        currentUser = SessionUser(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
                                  name: "Demo User",
                                  avatarName: "demo_profile")
    }

    var currentUser: SessionUser
}
