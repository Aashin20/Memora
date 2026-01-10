import Foundation
import Combine

class AuthState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    static let shared = AuthState()
    private init() {}
    
    func checkAuthStatus() {
        if let user = SupabaseManager.shared.getCurrentUser() {
            self.currentUser = user
            self.isAuthenticated = true
        } else {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            _ = try await SupabaseManager.shared.signIn(email: email, password: password)
            checkAuthStatus()
            return true
        } catch {
            print("Sign in error: \(error)")
            return false
        }
    }
    
    func signUp(name: String, email: String, password: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try await SupabaseManager.shared.signUp(
                name: name,
                email: email,
                password: password
            )
            self.currentUser = user
            self.isAuthenticated = true
            return true
        } catch {
            print("Sign up error: \(error)")
            return false
        }
    }
    
    func signOut() async {
        do {
            try await SupabaseManager.shared.signOut()
            self.currentUser = nil
            self.isAuthenticated = false
        } catch {
            print("Sign out error: \(error)")
        }
    }
}