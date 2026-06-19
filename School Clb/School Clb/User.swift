//
//  User.swift
//  School Club
//
//  Created on 20.05.2026
//

import Foundation

enum UserRole: String, Codable {
    case student = "student"
    case premium = "premium"
    case editor = "editor"
    case superadmin = "superadmin"
}

/// Тарифные планы подписки
enum SubscriptionTier: String, Codable {
    case base = "base"           // BASE - только реклама, пробные уроки
    case student = "student"     // STUDENT - студенты School Club: BASE + чаты группы + успеваемость
    case pro = "pro"            // PRO - полный доступ: уроки, тесты, форум, AI, чаты
    
    var displayName: String {
        switch self {
        case .base: return "BASE"
        case .student: return "STUDENT"
        case .pro: return "PRO"
        }
    }
    
    var description: String {
        switch self {
        case .base: return "Пробные уроки и реклама"
        case .student: return "Для студентов School Club"
        case .pro: return "Полный доступ ко всем функциям"
        }
    }
    
    var features: [String] {
        switch self {
        case .base:
            return [
                "Пробные уроки",
                "Просмотр рекламы",
                "Базовые функции"
            ]
        case .student:
            return [
                "Всё из BASE",
                "Чат «Моя группа»",
                "Доступ к успеваемости",
                "Расписание занятий"
            ]
        case .pro:
            return [
                "Всё из STUDENT",
                "Все уроки и тесты",
                "Форум",
                "AI ассистент",
                "Личные чаты",
                "Без рекламы"
            ]
        }
    }
    
    var iconName: String {
        switch self {
        case .base: return "star"
        case .student: return "book.fill"
        case .pro: return "crown.fill"
        }
    }
    
    var color: String {
        switch self {
        case .base: return "#9E9E9E"      // Серый
        case .student: return "#2196F3"   // Синий
        case .pro: return "#FFD700"       // Золотой
        }
    }
}

struct User: Identifiable, Codable {
    var id: String?
    var uid: String
    var phone: String
    var fullName: String
    var nickname: String
    var avatarURL: String?
    var district: String?
    var school: String?
    var role: UserRole
    var isPremium: Bool
    var premiumUntil: Date?
    var subscriptionTier: SubscriptionTier  // Новый тариф
    var points: Int
    var createdAt: Date
    var lastSeen: Date
    
    // Вычисляемое свойство для проверки доступа к функциям
    var hasStudentAccess: Bool {
        return subscriptionTier == .student || subscriptionTier == .pro
    }
    
    var hasProAccess: Bool {
        return subscriptionTier == .pro
    }
    
    // Для обратной совместимости
    var username: String {
        return nickname
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case uid
        case phone
        case fullName
        case nickname
        case avatarURL
        case district
        case school
        case role
        case isPremium
        case premiumUntil
        case subscriptionTier
        case points
        case createdAt
        case lastSeen
    }
    
    // Инициализатор с дефолтным значением для subscriptionTier
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        uid = try container.decode(String.self, forKey: .uid)
        phone = try container.decode(String.self, forKey: .phone)
        fullName = try container.decode(String.self, forKey: .fullName)
        nickname = try container.decode(String.self, forKey: .nickname)
        avatarURL = try container.decodeIfPresent(String.self, forKey: .avatarURL)
        district = try container.decodeIfPresent(String.self, forKey: .district)
        school = try container.decodeIfPresent(String.self, forKey: .school)
        role = try container.decode(UserRole.self, forKey: .role)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        premiumUntil = try container.decodeIfPresent(Date.self, forKey: .premiumUntil)
        subscriptionTier = try container.decodeIfPresent(SubscriptionTier.self, forKey: .subscriptionTier) ?? .base
        points = try container.decode(Int.self, forKey: .points)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastSeen = try container.decode(Date.self, forKey: .lastSeen)
    }
    
    init(id: String? = nil, uid: String, phone: String, fullName: String, nickname: String,
         avatarURL: String? = nil, district: String? = nil, school: String? = nil,
         role: UserRole = .student, isPremium: Bool = false, premiumUntil: Date? = nil,
         subscriptionTier: SubscriptionTier = .base, points: Int = 0,
         createdAt: Date = Date(), lastSeen: Date = Date()) {
        self.id = id
        self.uid = uid
        self.phone = phone
        self.fullName = fullName
        self.nickname = nickname
        self.avatarURL = avatarURL
        self.district = district
        self.school = school
        self.role = role
        self.isPremium = isPremium
        self.premiumUntil = premiumUntil
        self.subscriptionTier = subscriptionTier
        self.points = points
        self.createdAt = createdAt
        self.lastSeen = lastSeen
    }
}
