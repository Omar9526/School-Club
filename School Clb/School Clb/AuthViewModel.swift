//
//  AuthViewModel.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        // Проверяем, есть ли сохраненный пользователь
        if let userData = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func login(phoneNumber: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Имитация загрузки (в реальном приложении здесь был бы запрос к серверу)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Простая проверка (замените на реальную логику)
        if phoneNumber.count > 4 && password.count > 3 {
            let user = User(
                id: UUID().uuidString,
                uid: UUID().uuidString,
                phone: phoneNumber,
                fullName: "Колдонуучу",
                nickname: "Колдонуучу",
                avatarURL: nil,
                district: nil,
                school: nil,
                role: .student,
                isPremium: false,
                premiumUntil: nil,
                points: 0,
                createdAt: Date(),
                lastSeen: Date()
            )
            
            saveUser(user)
            self.currentUser = user
            self.isAuthenticated = true
        } else {
            errorMessage = "Телефон же пароль туура эмес"
        }
        
        isLoading = false
    }
    
    func register(phoneNumber: String, fullName: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Имитация загрузки
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Простая валидация
        if phoneNumber.count > 4 && fullName.count > 2 && password.count > 3 {
            let user = User(
                id: UUID().uuidString,
                uid: UUID().uuidString,
                phone: phoneNumber,
                fullName: fullName,
                nickname: fullName,
                avatarURL: nil,
                district: nil,
                school: nil,
                role: .student,
                isPremium: false,
                premiumUntil: nil,
                points: 0,
                createdAt: Date(),
                lastSeen: Date()
            )
            
            saveUser(user)
            self.currentUser = user
            self.isAuthenticated = true
        } else {
            errorMessage = "Баардык талааларды толтуруңуз"
        }
        
        isLoading = false
    }
    
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
    }
    
    func signOut() {
        userDefaults.removeObject(forKey: userKey)
        self.currentUser = nil
        self.isAuthenticated = false
    }
}
