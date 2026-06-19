//
//  ProfileViewModel.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var completionPercentage: Double = 0.45
    @Published var lastLessonDate: String = "02 сент 2026"
    
    init() {
        // Временные тестовые данные (позже заменим на Firebase)
        loadMockData()
    }
    
    // MARK: - Load Mock Data
    private func loadMockData() {
        user = UserProfile(
            id: "mock-user-id",
            fullName: "Айдай Омурова",
            username: "aidai_omur",
            email: "aidai@example.com",
            district: "Ленинский район",
            school: "Школа №42",
            isPremium: true,
            premiumUntil: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
            avatarURL: nil,
            vibe: "🎓",
            role: .student,
            subscriptionTier: .pro  // ✅ PRO тариф - полный доступ ко всем функциям
        )
    }
    
    // MARK: - Update Profile
    func updateProfile(fullName: String, username: String, district: String, school: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(for: .seconds(0.5))
        
        user?.fullName = fullName
        user?.username = username
        user?.district = district
        user?.school = school
    }
    
    // MARK: - Update Vibe (Emoji)
    func updateVibe(_ emoji: String) {
        user?.vibe = emoji
    }
    
    // MARK: - Upload Avatar
    func uploadAvatar(_ image: UIImage) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(for: .seconds(1))
        
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            UserDefaults.standard.set(imageData, forKey: "userAvatarData")
            user?.avatarURL = "local://avatar"
        }
        
        return "local://avatar"
    }
    
    // MARK: - Get Avatar Image
    func getAvatarImage() -> UIImage? {
        if let imageData = UserDefaults.standard.data(forKey: "userAvatarData") {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    // MARK: - Change Password
    func changePassword(currentPassword: String, newPassword: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await Task.sleep(for: .seconds(0.5))
        
        guard !currentPassword.isEmpty else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Введите текущий пароль"])
        }
        
        guard newPassword.count >= 6 else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Пароль должен быть минимум 6 символов"])
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        user = nil
        UserDefaults.standard.removeObject(forKey: "userAvatarData")
    }
}

// MARK: - UserProfile Model
struct UserProfile: Identifiable {
    let id: String
    var fullName: String
    var username: String
    var email: String
    var district: String
    var school: String
    var isPremium: Bool
    var premiumUntil: Date?
    var avatarURL: String?
    var vibe: String
    var role: UserRole
    var subscriptionTier: SubscriptionTier
    
    // Computed properties for access control
    var hasStudentAccess: Bool {
        return subscriptionTier == .student || subscriptionTier == .pro
    }
    
    var hasProAccess: Bool {
        return subscriptionTier == .pro
    }
}
