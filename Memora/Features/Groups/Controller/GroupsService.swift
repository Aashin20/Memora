//
//  GroupsService.swift
//  Memora
//
//  Created by user@33 on 17/01/26.
//

import Foundation

// MARK: - Response Models
struct CreateGroupResponse: Codable {
    let group_id: Int
    let name: String
    let join_code: String
    
    func toUserGroup(adminId: String) -> UserGroup {
        return UserGroup(
            id: group_id,
            name: name,
            code: join_code,
            adminId: adminId,
            createdAt: Date(),
            memberCount: 1
        )
    }
}

struct JoinRequestResponse: Codable {
    let message: String
}

struct HandleRequestResponse: Codable {
    let status: String
}

struct GroupMemberDTO: Codable {
    let user_id: Int
    let username: String
    let role: String
    
    func toGroupMember(email: String = "") -> GroupMember {
        return GroupMember(
            id: String(user_id),
            name: username,
            email: email,
            isAdmin: role == "ADMIN",
            joinedAt: Date()
        )
    }
}

// MARK: - GroupsService
final class GroupsService {
    
    static let shared = GroupsService()
    private init() {}
    
    // MARK: - Create Group
    /// POST /groups
    func createGroup(name: String) async throws -> UserGroup {
        let token = try await AuthService.shared.fetchAccessToken()
        
        var components = URLComponents(
            url: AppConfig.apiBaseURL.appendingPathComponent("groups"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "name", value: name)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(http.statusCode) {
            throw handleHTTPError(statusCode: http.statusCode, data: data)
        }
        
        let createResponse = try JSONDecoder().decode(CreateGroupResponse.self, from: data)
        
        // Get current user ID for admin
        let currentUserId = try await getCurrentUserId()
        
        return createResponse.toUserGroup(adminId: currentUserId)
    }
    
    // MARK: - Join Group
    /// POST /groups/join
    func joinGroup(code: String) async throws -> UserGroup {
        let token = try await AuthService.shared.fetchAccessToken()
        
        var components = URLComponents(
            url: AppConfig.apiBaseURL.appendingPathComponent("groups/join"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "join_code", value: code)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode == 404 {
            throw NSError(
                domain: "GroupsService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Invalid join code"]
            )
        }
        
        if http.statusCode == 400 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Bad request"
            throw NSError(
                domain: "GroupsService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
        }
        
        if !(200...299).contains(http.statusCode) {
            throw handleHTTPError(statusCode: http.statusCode, data: data)
        }
        
        let joinResponse = try JSONDecoder().decode(JoinRequestResponse.self, from: data)
        print("✅ Join request sent: \(joinResponse.message)")
        
        // Return a temporary group object indicating pending status
        return UserGroup(
            id: 0,
            name: "Pending Approval",
            code: code,
            adminId: "",
            createdAt: Date(),
            memberCount: 0
        )
    }
    
    // MARK: - Handle Join Request (Admin Only)
    /// POST /groups/{group_id}/requests/{request_id}
    func handleJoinRequest(
        groupId: Int,
        requestId: Int,
        action: String // "APPROVE" or "REJECT"
    ) async throws -> String {
        let token = try await AuthService.shared.fetchAccessToken()
        
        var components = URLComponents(
            url: AppConfig.apiBaseURL
                .appendingPathComponent("groups")
                .appendingPathComponent("\(groupId)")
                .appendingPathComponent("requests")
                .appendingPathComponent("\(requestId)"),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "action", value: action)
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode == 403 {
            throw NSError(
                domain: "GroupsService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Admin access required"]
            )
        }
        
        if http.statusCode == 404 {
            throw NSError(
                domain: "GroupsService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Request not found"]
            )
        }
        
        if !(200...299).contains(http.statusCode) {
            throw handleHTTPError(statusCode: http.statusCode, data: data)
        }
        
        let handleResponse = try JSONDecoder().decode(HandleRequestResponse.self, from: data)
        return handleResponse.status
    }
    
    // MARK: - Get Group Members
    /// GET /groups/{group_id}/members
    func getGroupMembers(groupId: Int) async throws -> [GroupMember] {
        let token = try await AuthService.shared.fetchAccessToken()
        
        let url = AppConfig.apiBaseURL
            .appendingPathComponent("groups")
            .appendingPathComponent("\(groupId)")
            .appendingPathComponent("members")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode == 403 {
            throw NSError(
                domain: "GroupsService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Not a group member"]
            )
        }
        
        if !(200...299).contains(http.statusCode) {
            throw handleHTTPError(statusCode: http.statusCode, data: data)
        }
        
        let memberDTOs = try JSONDecoder().decode([GroupMemberDTO].self, from: data)
        return memberDTOs.map { $0.toGroupMember() }
    }
    
    // MARK: - Get My Groups
    /// GET /groups (you'll need to implement this endpoint)
    func getMyGroups() async throws -> [UserGroup] {
        let token = try await AuthService.shared.fetchAccessToken()
        
        let url = AppConfig.apiBaseURL.appendingPathComponent("groups")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(http.statusCode) {
            throw handleHTTPError(statusCode: http.statusCode, data: data)
        }
        
        // TODO: Update this when backend endpoint is ready
        // For now, return empty array
        return []
    }
    
    // MARK: - Delete Group (Admin Only)
    /// DELETE /groups/{group_id}
    func deleteGroup(groupId: Int) async throws {
        let token = try await AuthService.shared.fetchAccessToken()
        
        let url = AppConfig.apiBaseURL
            .appendingPathComponent("groups")
            .appendingPathComponent("\(groupId)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode == 403 {
            throw NSError(
                domain: "GroupsService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Admin access required"]
            )
        }
        
        if !(200...299).contains(http.statusCode) {
            throw handleHTTPError(statusCode: http.statusCode, data: data)
        }
    }
    
    // MARK: - Remove Group Member
    /// DELETE /groups/{group_id}/members/{user_id}
    func removeGroupMember(groupId: Int, userId: String) async throws {
        let token = try await AuthService.shared.fetchAccessToken()
        
        let url = AppConfig.apiBaseURL
            .appendingPathComponent("groups")
            .appendingPathComponent("\(groupId)")
            .appendingPathComponent("members")
            .appendingPathComponent(userId)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode == 403 {
            throw NSError(
                domain: "GroupsService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Admin access required"]
            )
        }
        
        if !(200...299).contains(http.statusCode) {
            throw handleHTTPError(statusCode: http.statusCode, data: data)
        }
    }
    
    // MARK: - Update Group Admin
    /// PATCH /groups/{group_id}/members/{user_id}
    func updateGroupAdmin(groupId: Int, userId: String, isAdmin: Bool) async throws {
        let token = try await AuthService.shared.fetchAccessToken()
        
        var components = URLComponents(
            url: AppConfig.apiBaseURL
                .appendingPathComponent("groups")
                .appendingPathComponent("\(groupId)")
                .appendingPathComponent("members")
                .appendingPathComponent(userId),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = [
            URLQueryItem(name: "is_admin", value: String(isAdmin))
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode == 403 {
            throw NSError(
                domain: "GroupsService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Admin access required"]
            )
        }
        
        if !(200...299).contains(http.statusCode) {
            throw handleHTTPError(statusCode: http.statusCode, data: data)
        }
    }
    
    // MARK: - Get Pending Join Requests (Admin Only)
    /// GET /groups/{group_id}/requests
    func getPendingJoinRequests(groupId: Int) async throws -> [JoinRequest] {
        let token = try await AuthService.shared.fetchAccessToken()
        
        let url = AppConfig.apiBaseURL
            .appendingPathComponent("groups")
            .appendingPathComponent("\(groupId)")
            .appendingPathComponent("requests")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if http.statusCode == 403 {
            throw NSError(
                domain: "GroupsService",
                code: 403,
                userInfo: [NSLocalizedDescriptionKey: "Admin access required"]
            )
        }
        
        if !(200...299).contains(http.statusCode) {
            throw handleHTTPError(statusCode: http.statusCode, data: data)
        }
        
        // TODO: Update decoder when backend is ready
        return []
    }
    
    // MARK: - Helper Methods
    private func getCurrentUserId() async throws -> String {
        // Get user ID from auth token or user session
        // This assumes you have a way to get the current user ID
        if let userId = StaticDataManager.shared.getCurrentUserId() {
            return userId
        }
        throw NSError(
            domain: "GroupsService",
            code: 401,
            userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
        )
    }
    
    private func handleHTTPError(statusCode: Int, data: Data) -> Error {
        let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
        return NSError(
            domain: "GroupsService",
            code: statusCode,
            userInfo: [NSLocalizedDescriptionKey: errorMessage]
        )
    }
}

// MARK: - Join Request Model
struct JoinRequest: Codable {
    let id: Int
    let userId: String
    let userName: String
    let userEmail: String
    let requestedAt: Date
    let status: String
}
