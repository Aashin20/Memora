//
//  AccountSession.swift
//

import Foundation
import UIKit

public struct Account {
    public let id: UUID
    public let displayName: String
    public let avatarImageName: String? // asset name if available

    public init(id: UUID = UUID(), displayName: String, avatarImageName: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.avatarImageName = avatarImageName
    }
}

public final class AccountManager {
    public static let shared = AccountManager()

    // Sample "current" account; replace with your auth/session provider
    private(set) public var current: Account

    private init() {
        self.current = Account(displayName: "Sample User", avatarImageName: "profile")
    }

    // helper to mock/replace in tests
    public func setMockAccount(displayName: String, avatarImageName: String? = "profile") {
        current = Account(id: UUID(), displayName: displayName, avatarImageName: avatarImageName)
    }
}
