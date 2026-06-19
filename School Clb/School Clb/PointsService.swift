//
//  PointsService.swift
//  School Club
//
//  Created on 16.06.2026
//

import SwiftUI
import Combine

/// Единая система начисления и управления баллами пользователя
@MainActor
class PointsService: ObservableObject {
    static let shared = PointsService()
    
    // MARK: - Published Properties
    @Published var currentPoints: Int = 0
    @Published var pointsHistory: [PointsTransaction] = []
    @Published var isLoading = false
    
    private let userDefaultsKey = "userTotalPoints"
    private let historyKey = "userPointsHistory"
    
    // MARK: - Init
    private init() {
        loadPoints()
        loadHistory()
    }
    
    // MARK: - Load from Storage
    private func loadPoints() {
        currentPoints = UserDefaults.standard.integer(forKey: userDefaultsKey)
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([PointsTransaction].self, from: data) {
            pointsHistory = decoded
        }
    }
    
    // MARK: - Add Points
    /// Добавить баллы пользователю
    /// - Parameters:
    ///   - amount: Количество баллов (1-10)
    ///   - source: Источник начисления
    ///   - details: Дополнительная информация (например, название игры)
    func addPoints(_ amount: Int, source: PointSource, details: String? = nil) {
        guard amount > 0 else { return }
        
        // Обновляем текущий счёт
        currentPoints += amount
        
        // Сохраняем в UserDefaults
        UserDefaults.standard.set(currentPoints, forKey: userDefaultsKey)
        
        // Создаём транзакцию
        let transaction = PointsTransaction(
            id: UUID().uuidString,
            amount: amount,
            source: source,
            details: details,
            date: Date()
        )
        
        // Добавляем в историю
        pointsHistory.insert(transaction, at: 0)
        
        // Сохраняем историю (последние 100 транзакций)
        if pointsHistory.count > 100 {
            pointsHistory = Array(pointsHistory.prefix(100))
        }
        
        saveHistory()
        
        // TODO: Отправить в Firebase когда будет подключён
        // TODO: Показать уведомление пользователю
        
        print("✅ Начислено \(amount) баллов из источника: \(source.displayName)")
    }
    
    // MARK: - Spend Points
    /// Потратить баллы (для будущей функции покупок)
    /// - Parameters:
    ///   - amount: Количество баллов
    ///   - reason: Причина траты
    /// - Returns: Успешность операции
    func spendPoints(_ amount: Int, reason: String) -> Bool {
        guard currentPoints >= amount else {
            print("❌ Недостаточно баллов для траты")
            return false
        }
        
        currentPoints -= amount
        UserDefaults.standard.set(currentPoints, forKey: userDefaultsKey)
        
        let transaction = PointsTransaction(
            id: UUID().uuidString,
            amount: -amount,
            source: .spent,
            details: reason,
            date: Date()
        )
        
        pointsHistory.insert(transaction, at: 0)
        saveHistory()
        
        print("✅ Потрачено \(amount) баллов на: \(reason)")
        return true
    }
    
    // MARK: - Save History
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(pointsHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    // MARK: - Reset (для тестирования)
    func resetPoints() {
        currentPoints = 0
        pointsHistory.removeAll()
        UserDefaults.standard.set(0, forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: historyKey)
        print("🔄 Баллы сброшены")
    }
    
    // MARK: - Get Points by Source
    /// Получить сумму баллов за определённый период из конкретного источника
    func getPointsSum(from source: PointSource, since date: Date) -> Int {
        return pointsHistory
            .filter { $0.source == source && $0.date >= date }
            .reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Point Source
/// Источники начисления баллов
enum PointSource: String, Codable {
    case duelWin = "duel_win"              // Победа в "Раз на раз"
    case quizComplete = "quiz_complete"    // Завершение викторины
    case kahootWin = "kahoot_win"          // Призовое место в Кахут
    case dailyChallenge = "daily_challenge" // Вызов дня
    case homework = "homework"             // Домашнее задание
    case lessonComplete = "lesson_complete" // Завершение урока (2 теста)
    case testPassed = "test_passed"        // Пробный тест
    case attendance = "attendance"         // Посещаемость
    case teacherBonus = "teacher_bonus"    // Бонус от учителя
    case spent = "spent"                   // Трата баллов
    
    var displayName: String {
        switch self {
        case .duelWin: return "Победа в дуэли"
        case .quizComplete: return "Викторина"
        case .kahootWin: return "Кахут"
        case .dailyChallenge: return "Вызов дня"
        case .homework: return "Домашнее задание"
        case .lessonComplete: return "Завершение урока"
        case .testPassed: return "Пробный тест"
        case .attendance: return "Посещаемость"
        case .teacherBonus: return "Бонус учителя"
        case .spent: return "Трата баллов"
        }
    }
    
    var icon: String {
        switch self {
        case .duelWin: return "person.2.badge.gearshape"
        case .quizComplete: return "brain.head.profile"
        case .kahootWin: return "trophy.fill"
        case .dailyChallenge: return "calendar.badge.exclamationmark"
        case .homework: return "book.fill"
        case .lessonComplete: return "checkmark.circle.fill"
        case .testPassed: return "doc.text.fill"
        case .attendance: return "person.fill.checkmark"
        case .teacherBonus: return "star.fill"
        case .spent: return "cart.fill"
        }
    }
    
    var color: String {
        switch self {
        case .duelWin: return "#1B2A6B"
        case .quizComplete: return "#FFE600"
        case .kahootWin: return "#E84E1B"
        case .dailyChallenge: return "#E84E1B"
        case .homework: return "#1B2A6B"
        case .lessonComplete: return "#34C759"
        case .testPassed: return "#1B2A6B"
        case .attendance: return "#34C759"
        case .teacherBonus: return "#FFE600"
        case .spent: return "#FF3B30"
        }
    }
}

// MARK: - Points Transaction
/// Запись о начислении/трате баллов
struct PointsTransaction: Identifiable, Codable {
    let id: String
    let amount: Int              // Положительное = начисление, отрицательное = трата
    let source: PointSource
    let details: String?         // Дополнительная информация
    let date: Date
    
    var isPositive: Bool {
        return amount > 0
    }
    
    var displayAmount: String {
        return isPositive ? "+\(amount)" : "\(amount)"
    }
}
