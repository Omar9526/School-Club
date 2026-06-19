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
    @Published var activityRating: Double = 0.68 // 68%
    @Published var userRank: Int = 47
    @Published var totalUsers: Int = 1250
    @Published var announcements: [Announcement] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Баллы теперь через PointsService
    private let pointsService = PointsService.shared
    
    var userPoints: Int {
        pointsService.currentPoints
    }
    
    init() {
        loadMockData()
    }
    
    // MARK: - Load Mock Data
    private func loadMockData() {
        announcements = [
            Announcement(
                id: "1",
                type: .award,
                title: "Наградили студентов",
                body: "15 лучших студентов получили сертификаты за отличную учёбу!",
                imageURL: nil,
                createdAt: Date().addingTimeInterval(-3600 * 24 * 2)
            ),
            Announcement(
                id: "2",
                type: .birthday,
                title: "🎂 С Днём Рождения!",
                body: "Поздравляем Айдай Омурову с Днём Рождения! Желаем успехов в учёбе!",
                imageURL: nil,
                createdAt: Date().addingTimeInterval(-3600 * 12)
            ),
            Announcement(
                id: "3",
                type: .news,
                title: "Новые уроки по физике",
                body: "Добавлены видеоуроки по теме 'Электричество и магнетизм'. Начните изучать прямо сейчас!",
                imageURL: nil,
                createdAt: Date().addingTimeInterval(-3600 * 6)
            ),
            Announcement(
                id: "4",
                type: .charity,
                title: "❤️ Благотворительная акция",
                body: "Школьники собрали 50,000 сом для помощи детскому дому. Спасибо всем участникам!",
                imageURL: nil,
                createdAt: Date().addingTimeInterval(-3600 * 24)
            ),
            Announcement(
                id: "5",
                type: .volunteer,
                title: "🙋 Волонтёры в действии",
                body: "Студенты провели субботник в парке. Присоединяйтесь к следующему мероприятию!",
                imageURL: nil,
                createdAt: Date().addingTimeInterval(-3600 * 48)
            ),
            Announcement(
                id: "6",
                type: .partner,
                title: "🤝 Новый партнёр",
                body: "Рады сообщить о партнёрстве с книжным магазином 'Раритет'. Скидка 15% для наших студентов!",
                imageURL: nil,
                createdAt: Date().addingTimeInterval(-3600 * 72)
            )
        ]
    }
    
    // MARK: - Add Points
    func addPoints(_ amount: Int, source: PointSource, details: String? = nil) {
        pointsService.addPoints(amount, source: source, details: details)
        objectWillChange.send() // Обновить UI
    }
    
    // MARK: - Spend Points
    func spendPoints(_ points: Int, on category: SpendCategory) throws {
        guard pointsService.spendPoints(points, reason: category.rawValue) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Недостаточно баллов"])
        }
        objectWillChange.send() // Обновить UI
        print("Spent \(points) points on \(category.rawValue)")
    }
    
    // MARK: - Update Activity
    func recordActivity() {
        // Увеличиваем рейтинг активности при каждом входе
        activityRating = min(1.0, activityRating + 0.01)
        // TODO: Обновить в Firestore
        print("Activity recorded. Rating: \(activityRating)")
    }
    
    // MARK: - Load Announcements
    func loadAnnouncements() {
        // TODO: Загрузка из Firestore
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
        }
    }
    
    // MARK: - Refresh
    func refresh() async {
        isLoading = true
        
        // Симуляция загрузки
        try? await Task.sleep(for: .seconds(1))
        
        // TODO: Загрузить свежие данные из Firestore
        loadMockData()
        
        isLoading = false
    }
}

// MARK: - Models

struct Announcement: Identifiable {
    let id: String
    let type: AnnouncementType
    let title: String
    let body: String
    let imageURL: String?
    let createdAt: Date
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        let hours = Int(interval / 3600)
        let days = Int(interval / (3600 * 24))
        
        if days > 0 {
            return "\(days) дн. назад"
        } else if hours > 0 {
            return "\(hours) ч. назад"
        } else {
            return "недавно"
        }
    }
}

enum AnnouncementType: String {
    case award = "🏆 Награда"
    case birthday = "🎂 День рождения"
    case news = "📢 Новость"
    case charity = "❤️ Благотворительность"
    case volunteer = "🙋 Волонтёрство"
    case partner = "🤝 Партнёры"
    
    var color: String {
        switch self {
        case .award: return "#FFE600"
        case .birthday: return "#FF69B4"
        case .news: return "#1B2A6B"
        case .charity: return "#E84E1B"
        case .volunteer: return "#34C759"
        case .partner: return "#007AFF"
        }
    }
    
    var icon: String {
        switch self {
        case .award: return "trophy.fill"
        case .birthday: return "gift.fill"
        case .news: return "megaphone.fill"
        case .charity: return "heart.fill"
        case .volunteer: return "hand.raised.fill"
        case .partner: return "handshake.fill"
        }
    }
}

enum SpendCategory: String {
    case partners = "Партнёры"
    case giveToGroup = "Отдать группе"
    case raffle = "Розыгрыш"
    case merch = "Книги, мерч"
    case charity = "Благотворить"
    case discount = "Скидка в SC"
}
