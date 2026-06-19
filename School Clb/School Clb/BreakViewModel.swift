//
//  BreakViewModel.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import Combine

class BreakViewModel: ObservableObject {
    @Published var myGroup: UserGroup?
    @Published var friends: [Friend] = []
    @Published var dailyChallenge: DailyChallenge?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @MainActor
    init() {
        loadMockData()
    }
    
    // MARK: - Load Mock Data
    private func loadMockData() {
        // Моя группа
        myGroup = UserGroup(
            id: "group-1",
            name: "Школа №42 - 11А",
            members: ["user1", "user2", "user3"],
            totalPoints: 1238,
            rank: 15
        )
        
        // Друзья
        friends = [
            Friend(id: "f1", name: "Айдай", avatarURL: nil, points: 450),
            Friend(id: "f2", name: "Бекжан", avatarURL: nil, points: 380),
            Friend(id: "f3", name: "Динара", avatarURL: nil, points: 520),
            Friend(id: "f4", name: "Эркин", avatarURL: nil, points: 410),
            Friend(id: "f5", name: "Жанара", avatarURL: nil, points: 490)
        ]
        
        // Вызов дня
        dailyChallenge = DailyChallenge(
            id: "challenge-today",
            date: Date(),
            question: Question(
                id: "daily-q1",
                lessonId: "daily",
                order: 1,
                type: .text,
                questionText: "Сколько планет в Солнечной системе?",
                questionImageURL: nil,
                optionA: "7",
                optionB: "8",
                optionC: "9",
                optionD: "10",
                correctAnswer: "B"
            ),
            participantsCount: 1523,
            rewardPoints: 10
        )
    }
    
    // MARK: - Daily Challenge
    func submitDailyChallenge(answer: String) -> Bool {
        guard let challenge = dailyChallenge else { return false }
        let isCorrect = answer == challenge.question.correctAnswer
        
        if isCorrect {
            // TODO: Сохранить в Firestore + добавить баллы
            myGroup?.totalPoints += challenge.rewardPoints
        }
        
        return isCorrect
    }
    
    // MARK: - Start Duel
    func startDuel() {
        // TODO: Matchmaking через Firestore
        print("Starting duel matchmaking...")
    }
    
    // MARK: - Load Quiz Questions
    func loadQuizQuestions(difficulty: QuizDifficulty, subject: String?) -> [Question] {
        // Mock вопросы
        var questions: [Question] = []
        
        for i in 1...5 {
            questions.append(Question(
                id: "quiz-\(i)",
                lessonId: "quiz",
                order: i,
                type: .text,
                questionText: "Вопрос \(i) сложности \(difficulty.rawValue)",
                questionImageURL: nil,
                optionA: "Вариант А",
                optionB: "Вариант Б",
                optionC: "Вариант В",
                optionD: "Вариант Г",
                correctAnswer: ["A", "B", "C", "D"].randomElement()!
            ))
        }
        
        return questions
    }
    
    // MARK: - Share Invite Link
    func shareInviteLink() {
        let inviteLink = "https://schoolclub.kg/invite/\(myGroup?.id ?? "default")"
        // TODO: Открыть UIActivityViewController для share
        print("Share link: \(inviteLink)")
    }
}

// MARK: - Models

struct UserGroup: Identifiable {
    let id: String
    var name: String
    var members: [String]
    var totalPoints: Int
    var rank: Int
}

struct Friend: Identifiable {
    let id: String
    let name: String
    let avatarURL: String?
    let points: Int
}

struct DailyChallenge: Identifiable {
    let id: String
    let date: Date
    let question: Question
    let participantsCount: Int
    let rewardPoints: Int
    
    var timeUntilNext: TimeInterval {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        let midnight = calendar.startOfDay(for: tomorrow)
        return midnight.timeIntervalSince(Date())
    }
}

enum QuizDifficulty: String {
    case easy = "Лёгкий"
    case medium = "Средний"
    case hard = "Сложный"
}

struct GameSubject: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: String
}
