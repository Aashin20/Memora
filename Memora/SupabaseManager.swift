import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    private(set) var currentUser: User?
    
    private init() {
        //  REPLACE THESE WITH YOUR ACTUAL VALUES
        let supabaseUrl = "https://rphfhugkmcycarakepvb.supabase.co"
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwaGZodWdrbWN5Y2FyYWtlcHZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc4NDQ5NzUsImV4cCI6MjA4MzQyMDk3NX0.KjYhMxIp1LgKDZ8II31oAyjszVJwURhQZAFn4WAyF9w"
        
        self.client = SupabaseClient(
            supabaseURL: URL(string: supabaseUrl)!,
            supabaseKey: supabaseKey
        )
        
        // Load current user on init
        loadCurrentUser()
    }
    
    // MARK: - Current User Management
    private func loadCurrentUser() {
        Task {
            do {
                let session = try await client.auth.session
                self.currentUser = session.user
            } catch {
                print("No current session: \(error)")
                self.currentUser = nil
            }
        }
    }
    
    func getCurrentUserId() -> String? {
        return currentUser?.id.uuidString
    }
    
    func isUserLoggedIn() -> Bool {
        return getCurrentUserId() != nil
    }
    
    func getCurrentUserEmail() -> String? {
        return currentUser?.email
    }
    
    // MARK: - Authentication
    func signUp(name: String, email: String, password: String) async throws {
        do {
            // Create auth user
            _ = try await client.auth.signUp(
                email: email,
                password: password
            )
            
            // Sign in to create session
            try await signIn(email: email, password: password)
            
            // Create profile
            try await createUserProfile(name: name, email: email)
            
        } catch {
            print("Sign up error: \(error)")
            throw error
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            _ = try await client.auth.signIn(email: email, password: password)
            // Update current user
            let session = try await client.auth.session
            self.currentUser = session.user
        } catch {
            print("Sign in error: \(error)")
            throw error
        }
    }
    
    func signOut() async throws {
        do {
            try await client.auth.signOut()
            self.currentUser = nil
        } catch {
            print("Sign out error: \(error)")
            throw error
        }
    }
    
    // MARK: - Profile Management
    func createUserProfile(name: String, email: String) async throws {
        guard let userId = getCurrentUserId() else {
            throw NSError(domain: "No user logged in", code: 401)
        }
        
        try await client
            .from("profiles")
            .insert([
                "id": userId,
                "name": name,
                "email": email
            ])
            .execute()
    }
    
    func getUserProfile() async throws -> UserProfile? {
        guard let userId = getCurrentUserId() else {
            return nil
        }
        
        do {
            let response = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            return try decoder.decode(UserProfile.self, from: response.data)
        } catch {
            print("Error fetching profile: \(error)")
            return nil
        }
    }
    
    // MARK: - Test Connection
    func testConnection() async -> Bool {
        do {
            _ = try await client
                .from("profiles")
                .select("count")
                .limit(1)
                .execute()
            
            print("Supabase connection successful")
            return true
        } catch {
            print("Supabase connection failed: \(error)")
            return false
        }
    }
    

    // MARK: - Groups
    func createGroup(name: String) async throws -> UserGroup {
        guard let userId = getCurrentUserId() else {
            throw NSError(domain: "No user logged in", code: 401)
        }
        
        // Generate a unique 6-digit code
        let code = generateGroupCode()
        
        let response = try await client
            .from("groups")
            .insert([
                "name": name,
                "code": code,
                "created_by": userId,
                "admin_id": userId
            ])
            .select()
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let group = try decoder.decode(UserGroup.self, from: response.data)
        
        // Add creator as admin member
        try await addGroupMember(groupId: group.id, userId: userId, isAdmin: true)
        
        return group
    }

    func joinGroup(code: String) async throws -> UserGroup {
        guard let userId = getCurrentUserId() else {
            throw NSError(domain: "No user logged in", code: 401)
        }
        
        // Find group by code
        let groupResponse = try await client
            .from("groups")
            .select()
            .eq("code", value: code)
            .single()
            .execute()
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let group = try decoder.decode(UserGroup.self, from: groupResponse.data)
        
        // Add user as member
        try await addGroupMember(groupId: group.id, userId: userId, isAdmin: false)
        
        return group
    }

    func getMyGroups() async throws -> [UserGroup] {
        guard let userId = getCurrentUserId() else {
            return []
        }
        
        do {
            let response = try await client
                .from("group_members")
                .select("group_id, groups!inner(*)")
                .eq("user_id", value: userId)
                .execute()
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Debug: Print raw response
            print("My groups raw response: \(String(data: response.data, encoding: .utf8) ?? "")")
            
            // Parse the nested response
            struct GroupMembership: Codable {
                let groupId: String
                let groups: UserGroup
            }
            
            let memberships = try decoder.decode([GroupMembership].self, from: response.data)
            return memberships.map { $0.groups }
        } catch {
            print("Error fetching groups: \(error)")
            return []
        }
    }

    func getGroupMembers(groupId: String) async throws -> [GroupMember] {
        do {
            let response = try await client
                .from("group_members")
                .select("user_id, is_admin, joined_at, profiles(name, email)")
                .eq("group_id", value: groupId)
                .execute()
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Debug: Print the raw response
            print("Group members raw response: \(String(data: response.data, encoding: .utf8) ?? "")")
            
            // Parse the nested response
            struct GroupMemberDB: Codable {
                let userId: String
                let isAdmin: String  // Change from Bool to String
                let joinedAt: Date
                let profiles: UserProfile
                
                enum CodingKeys: String, CodingKey {
                    case userId = "user_id"
                    case isAdmin = "is_admin"
                    case joinedAt = "joined_at"
                    case profiles
                }
            }
            
            let dbMembers = try decoder.decode([GroupMemberDB].self, from: response.data)
            
            // Convert to GroupMember array
            return dbMembers.map { dbMember in
                GroupMember(
                    id: dbMember.userId,
                    name: dbMember.profiles.name,
                    email: dbMember.profiles.email,
                    isAdmin: dbMember.isAdmin.lowercased() == "true",  // Convert string to bool
                    joinedAt: dbMember.joinedAt
                )
            }
        } catch {
            print("Error fetching group members: \(error)")
            throw error
        }
    }

    func addGroupMember(groupId: String, userId: String, isAdmin: Bool = false) async throws {
        try await client
            .from("group_members")
            .insert([
                "group_id": groupId,
                "user_id": userId,
                "is_admin": String(isAdmin)
            ])
            .execute()
    }

    func removeGroupMember(groupId: String, userId: String) async throws {
        try await client
            .from("group_members")
            .delete()
            .eq("group_id", value: groupId)
            .eq("user_id", value: userId)
            .execute()
    }

    func deleteGroup(groupId: String) async throws {
        try await client
            .from("groups")
            .delete()
            .eq("id", value: groupId)
            .execute()
    }

    func updateGroupAdmin(groupId: String, userId: String, isAdmin: Bool) async throws {
        try await client
            .from("group_members")
            .update(["is_admin": isAdmin])
            .eq("group_id", value: groupId)
            .eq("user_id", value: userId)
            .execute()
    }

    private func generateGroupCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}
