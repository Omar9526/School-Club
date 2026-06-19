//
//  PaymentViewModel.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import Combine

@MainActor
class PaymentViewModel: ObservableObject {
    @Published var selectedPlan: PremiumPlan?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var showSuccess = false
    
    // MARK: - Premium Plans
    let monthlyPlan = PremiumPlan(
        id: "monthly",
        type: .monthly,
        title: "Ежемесячная подписка",
        price: 299,
        originalPrice: 399,
        duration: "1 месяц",
        features: [
            "Доступ ко всем урокам",
            "Без рекламы",
            "Скачивание видео",
            "Приоритетная поддержка",
            "Эксклюзивные материалы"
        ]
    )
    
    let ortPlan = PremiumPlan(
        id: "until_ort",
        type: .untilORT,
        title: "До даты ОРТ",
        price: 1999,
        originalPrice: 2999,
        duration: "До 15 июля 2026",
        features: [
            "Все преимущества ежемесячной",
            "Гарантия до экзамена",
            "Индивидуальные консультации",
            "Пробные тесты без ограничений",
            "Скидка 33%"
        ]
    )
    
    // MARK: - Process Payment
    func processPayment(plan: PremiumPlan) async throws {
        isProcessing = true
        defer { isProcessing = false }
        
        // TODO: Реальная интеграция с платёжным шлюзом
        // Симуляция
        try await Task.sleep(for: .seconds(2))
        
        // TODO: Создать платёж в Firestore
        // TODO: Обновить статус пользователя
        
        showSuccess = true
    }
    
    // MARK: - Verify Payment
    func verifyPayment(transactionId: String) async throws -> Bool {
        // TODO: Проверка статуса оплаты
        try await Task.sleep(for: .seconds(1))
        return true
    }
    
    // MARK: - Upgrade User
    func upgradeUserToPremium(plan: PremiumPlan) async throws {
        // TODO: Обновить Firestore:
        // users/{uid}.isPremium = true
        // users/{uid}.premiumUntil = endDate
        // users/{uid}.subscriptionType = plan.type
        
        print("User upgraded to premium: \(plan.title)")
    }
}

// MARK: - Models

struct PremiumPlan: Identifiable {
    let id: String
    let type: SubscriptionType
    let title: String
    let price: Int
    let originalPrice: Int?
    let duration: String
    let features: [String]
    
    var hasDiscount: Bool {
        originalPrice != nil && originalPrice! > price
    }
    
    var discountPercentage: Int {
        guard let original = originalPrice, hasDiscount else { return 0 }
        return Int(Double(original - price) / Double(original) * 100)
    }
}

enum SubscriptionType: String {
    case monthly = "monthly"
    case untilORT = "until_ort"
}

struct Payment: Identifiable {
    let id: String
    let uid: String
    let amount: Int
    let type: SubscriptionType
    let startDate: Date
    let endDate: Date
    let status: PaymentStatus
    let discountApplied: Bool
    let createdAt: Date
}

enum PaymentStatus: String {
    case pending = "pending"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
}
