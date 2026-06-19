//
//  MovementViewModel.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import Combine

@MainActor
final class MovementViewModel: ObservableObject {
    // Баллы группы (mock)
    @Published var groupPoints: Int = 1238
    
    // Баллы через PointsService
    private let pointsService = PointsService.shared
    
    var userPoints: Int {
        pointsService.currentPoints
    }
    
    init() {
        // Инициализация не требуется для текущей версии
    }
    
    // MARK: - Spend Points
    /// Потратить баллы на категорию
    /// - Parameters:
    ///   - points: Количество баллов
    ///   - category: Категория траты
    /// - Throws: SpendPointsError если недостаточно баллов
    func spendPoints(_ points: Int, on category: SpendCategory) throws {
        let success = pointsService.spendPoints(points, reason: category.rawValue)
        if !success {
            throw SpendPointsError.insufficientPoints
        }
    }
}

// MARK: - Spend Points Error
enum SpendPointsError: LocalizedError {
    case insufficientPoints
    
    var errorDescription: String? {
        switch self {
        case .insufficientPoints:
            return "Недостаточно баллов для совершения покупки"
        }
    }
}

// MARK: - Сохранённые модели для совместимости
enum SpendCategory: String {
    case partners = "Партнёры"
    case giveToGroup = "Отдать группе"
    case raffle = "Розыгрыш"
    case merch = "Книги, мерч"
    case charity = "Благотворить"
    case discount = "Скидка в SC"
}
