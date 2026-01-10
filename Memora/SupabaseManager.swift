import Foundation
import Supabase
import GoTrue
import PostgREST
import Realtime

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        // Replace with your actual values
        let supabaseUrl = "https://your-project-id.supabase.co"
        let supabaseKey = "your-anon-public-key"
        
        self.client = SupabaseClient(
            supabaseURL: URL(string: supabaseUrl)!,
            supabaseKey: supabaseKey
        )
    }
    
    // MARK: - Authentication
    func signUp(name: String, email: String, password: String) async throws -> User {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: ["name": .string(name)]
        )
        
        guard let user = response.user else {
            throw NSError(domain: "Signup failed", code: 0)
        }
        
        // Create profile
        try await createProfile(userId: user.id, name: name, email: email)
        
        return user
    }
    
    func signIn(email: String, password: String) async throws -> Session {
        let session = try await client.auth.signIn(email: email, password: password)
        return session
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getCurrentUser() -> User? {
        return try? client.auth.session.user
    }
    
    // MARK: - Profile Management
    private func createProfile(userId: UUID, name: String, email: String) async throws {
        try await client
            .from("profiles")
            .insert([
                "id": userId,
                "name": name,
                "email": email
            ])
            .execute()
    }
    
    func getProfile(userId: UUID) async throws -> Profile {
        let response = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
        
        return try JSONDecoder().decode(Profile.self, from: response.data)
    }
    
    // MARK: - Prompts
    func getDailyPrompts() async throws -> [Prompt] {
        let response = try await client
            .from("prompts")
            .select()
            .limit(3)
            .execute()
        
        return try JSONDecoder().decode([Prompt].self, from: response.data)
    }
    
    // MARK: - Memories
    func createMemory(_ memory: Memory) async throws {
        try await client
            .from("memories")
            .insert(memory)
            .execute()
    }
    
    func getMemories(forUserId userId: UUID? = nil) async throws -> [Memory] {
        var query = client
            .from("memories")
            .select()
        
        if let userId = userId {
            query = query.eq("user_id", value: userId)
        }
        
        let response = try await query
            .order("created_at", ascending: false)
            .execute()
        
        return try JSONDecoder().decode([Memory].self, from: response.data)
    }
    
    // MARK: - Real-time (for future use)
    func subscribeToMemories(callback: @escaping ([Memory]) -> Void) {
        let channel = client.realtime.channel("memories")
        
        let changes = channel.postgresChange(
            event: .all,
            schema: "public",
            table: "memories"
        )
        
        changes.onReceive { update in
            // Handle real-time updates
            print("Memory update received: \(update)")
        }
        
        channel.subscribe()
    }
}