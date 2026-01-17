//
//  AuthService.swift
//  Memora
//
//  Created by user@33 on 16/01/26.
//

import Foundation
import Supabase

@MainActor
final class AuthService {

    // Singleton
    static let shared = AuthService()

    // 🔥 MUST be lazy to avoid early AppConfig access
    private lazy var supabaseClient: SupabaseClient = {
        SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }()

    var errorMessage: String?

    private init() {}

    // MARK: - Sign Up
    func signUp(
        name: String,
        email: String,
        password: String
    ) async -> Bool {

        do {
            let response = try await supabaseClient.auth.signUp(
                email: email,
                password: password
            )

            guard response.user != nil else {
                errorMessage = "User not returned"
                return false
            }

            try await createProfile(username: name)
            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Create Profile (FastAPI)
    private func createProfile(username: String) async throws {

        let session = try await supabaseClient.auth.session
        let accessToken = session.accessToken

        let url = AppConfig.apiBaseURL.appendingPathComponent("users/profile")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let body: [String: String] = [
            "username": username
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard
            let http = response as? HTTPURLResponse,
            http.statusCode == 201
        else {
            throw NSError(
                domain: "ProfileCreationFailed",
                code: 0
            )
        }
    }
}
