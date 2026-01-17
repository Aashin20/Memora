//
//  AuthService.swift
//  Memora
//

import Foundation
import Supabase

@MainActor
final class AuthService {

    static let shared = AuthService()

    private lazy var supabaseClient: SupabaseClient = {
        SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }()

    var errorMessage: String?

    private init() {}

    // MARK: - LOGIN
    func signIn(email: String, password: String) async -> Bool {
        do {
            // 🔥 signIn returns Session directly
            _ = try await supabaseClient.auth.signIn(
                email: email,
                password: password
            )

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - SIGN UP
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

            // 🔥 user is NON-OPTIONAL
            let user = response.user

            try await createProfile(
                username: name,
                supabaseUserId: user.id.uuidString
            )

            return true

        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Create Profile (FastAPI)
    private func createProfile(
        username: String,
        supabaseUserId: String
    ) async throws {

        let url = AppConfig.apiBaseURL.appendingPathComponent("users/profile")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": username,
            "supabase_uid": supabaseUserId
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard
            let http = response as? HTTPURLResponse,
            http.statusCode == 201
        else {
            throw NSError(domain: "ProfileCreationFailed", code: 0)
        }
    }
}

extension AuthService {

    /// Returns a valid access token or throws if not logged in
    func fetchAccessToken() async throws -> String {
        let session = try await supabaseClient.auth.session
        return session.accessToken
    }

    /// Safe authentication check
    func isAuthenticated() async -> Bool {
        do {
            _ = try await supabaseClient.auth.session
            return true
        } catch {
            return false
        }
    }
}
