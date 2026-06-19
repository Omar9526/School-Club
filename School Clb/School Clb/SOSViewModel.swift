//
//  SOSViewModel.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
class SOSViewModel: ObservableObject {
    @Published var forumPosts: [ForumPost] = []
    @Published var aiMessages: [AIMessage] = []
    @Published var groupMessages: [String: [GroupMessage]] = [:] // ✅ Словарь: groupID -> messages
    @Published var privateChats: [PrivateChat] = []
    @Published var myGroups: [StudentGroup] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadMockForumPosts()
        loadMockGroupMessages()
        loadMockPrivateChats()
        loadMockGroups()
    }
    
    // MARK: - Load Mock Forum Posts
    private func loadMockForumPosts() {
        forumPosts = [
            ForumPost(
                id: "1",
                authorUID: "user1",
                authorNickname: "Айдай",
                authorAvatarURL: nil,
                questionImageURL: nil,
                questionImageData: nil,
                questionText: "Помогите решить задачу по математике: найти производную функции f(x) = x³ + 2x² - 5x + 1",
                createdAt: Date().addingTimeInterval(-3600 * 2),
                isModerated: true,
                reportCount: 0,
                answers: [
                    ForumAnswer(id: "a1", authorUID: "user2", authorNickname: "Бекжан", text: "f'(x) = 3x² + 4x - 5", imageData: nil, videoURL: nil, documentURL: nil, documentName: nil, createdAt: Date().addingTimeInterval(-3600), likes: 5)
                ]
            ),
            ForumPost(
                id: "2",
                authorUID: "user3",
                authorNickname: "Динара",
                authorAvatarURL: nil,
                questionImageURL: nil,
                questionImageData: nil,
                questionText: "Кто знает формулу для площади трапеции?",
                createdAt: Date().addingTimeInterval(-3600 * 5),
                isModerated: true,
                reportCount: 0,
                answers: [
                    ForumAnswer(id: "a2", authorUID: "user4", authorNickname: "Эркин", text: "S = (a + b) / 2 * h, где a и b - основания, h - высота", imageData: nil, videoURL: nil, documentURL: nil, documentName: nil, createdAt: Date().addingTimeInterval(-3600 * 4), likes: 3),
                    ForumAnswer(id: "a3", authorUID: "user5", authorNickname: "Жанара", text: "Можно ещё разбить на прямоугольник и два треугольника", imageData: nil, videoURL: nil, documentURL: nil, documentName: nil, createdAt: Date().addingTimeInterval(-3600 * 3), likes: 1)
                ]
            ),
            ForumPost(
                id: "3",
                authorUID: "user6",
                authorNickname: "Азамат",
                authorAvatarURL: nil,
                questionImageURL: nil,
                questionImageData: nil,
                questionText: "Химия: как определить валентность элемента?",
                createdAt: Date().addingTimeInterval(-3600 * 24),
                isModerated: true,
                reportCount: 0,
                answers: []
            )
        ]
    }
    
    // MARK: - Post Question
    func postQuestion(
        imageData: Data?,
        questionText: String,
        authorNickname: String,
        videoURL: URL? = nil,
        documentURL: URL? = nil,
        documentName: String? = nil
    ) async throws {
        guard !questionText.isEmpty || imageData != nil || videoURL != nil || documentURL != nil else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Добавьте текст или файл"])
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Загрузить фото в Firebase Storage
        // TODO: Создать документ в Firestore
        
        // Симуляция
        try await Task.sleep(for: .seconds(1))
        
        let newPost = ForumPost(
            id: UUID().uuidString,
            authorUID: "current-user",
            authorNickname: authorNickname,
            authorAvatarURL: nil,
            questionImageURL: nil,
            questionImageData: imageData,
            questionText: questionText,
            createdAt: Date(),
            isModerated: false, // Ждёт модерации
            reportCount: 0,
            answers: []
        )
        
        forumPosts.insert(newPost, at: 0)
    }
    
    // MARK: - Post Answer
    func postAnswer(
        to postId: String,
        text: String,
        authorNickname: String,
        imageData: Data? = nil,
        videoURL: URL? = nil,
        documentURL: URL? = nil,
        documentName: String? = nil
    ) async throws {
        guard !text.isEmpty || imageData != nil || videoURL != nil || documentURL != nil else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Введите текст или прикрепите файл"])
        }
        
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Создать ответ в Firestore
        // TODO: Начислить +5 баллов автору
        
        try await Task.sleep(for: .seconds(0.5))
        
        let newAnswer = ForumAnswer(
            id: UUID().uuidString,
            authorUID: "current-user",
            authorNickname: authorNickname,
            text: text,
            imageData: imageData,
            videoURL: videoURL,
            documentURL: documentURL,
            documentName: documentName,
            createdAt: Date(),
            likes: 0
        )
        
        if let index = forumPosts.firstIndex(where: { $0.id == postId }) {
            forumPosts[index].answers.append(newAnswer)
        }
    }
    
    // MARK: - Like Answer
    func likeAnswer(postId: String, answerId: String) {
        // TODO: Обновить в Firestore
        // TODO: Начислить балл автору ответа
        
        if let postIndex = forumPosts.firstIndex(where: { $0.id == postId }),
           let answerIndex = forumPosts[postIndex].answers.firstIndex(where: { $0.id == answerId }) {
            forumPosts[postIndex].answers[answerIndex].likes += 1
        }
    }
    
    // MARK: - Report Post
    func reportPost(_ postId: String) async throws {
        // TODO: Увеличить reportCount в Firestore
        // TODO: Отправить уведомление модераторам
        
        if let index = forumPosts.firstIndex(where: { $0.id == postId }) {
            forumPosts[index].reportCount += 1
        }
    }
    
    // MARK: - AI Teacher
    func sendMessageToAI(text: String, imageData: Data?, videoURL: URL? = nil, documentURL: URL? = nil, documentName: String? = nil) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        // Добавляем сообщение пользователя
        let userMessage = AIMessage(
            id: UUID().uuidString,
            text: text,
            imageData: imageData,
            videoURL: videoURL,
            documentURL: documentURL,
            documentName: documentName,
            isUser: true,
            timestamp: Date()
        )
        aiMessages.append(userMessage)
        
        // TODO: Реальный запрос к Claude API
        // Пока симуляция
        try await Task.sleep(for: .seconds(1))
        
        let mockResponse = generateMockAIResponse(for: text)
        
        let aiMessage = AIMessage(
            id: UUID().uuidString,
            text: mockResponse,
            imageData: nil,
            videoURL: nil,
            documentURL: nil,
            documentName: nil,
            isUser: false,
            timestamp: Date()
        )
        aiMessages.append(aiMessage)
        
        return mockResponse
    }
    
    private func generateMockAIResponse(for question: String) -> String {
        if question.lowercased().contains("производная") || question.lowercased().contains("туунду") {
            return "Для нахождения производной функции f(x) = x³ + 2x² - 5x + 1, применим правило дифференцирования:\n\nf'(x) = 3x² + 4x - 5\n\nКаждый член умножается на степень и степень уменьшается на 1. Константа исчезает."
        } else if question.lowercased().contains("площадь") || question.lowercased().contains("аянт") {
            return "Для нахождения площади фигуры нужно использовать соответствующую формулу:\n\n• Прямоугольник: S = a × b\n• Треугольник: S = (a × h) / 2\n• Трапеция: S = (a + b) / 2 × h\n\nУточните, какая фигура вас интересует?"
        } else {
            return "Я готов помочь вам с решением задач! Пожалуйста, опишите задачу подробнее или прикрепите фото задания, и я постараюсь объяснить решение шаг за шагом."
        }
    }
    
    // MARK: - Refresh
    func refresh() async {
        isLoading = true
        
        try? await Task.sleep(for: .seconds(1))
        
        // TODO: Загрузить свежие данные из Firestore
        loadMockForumPosts()
        
        isLoading = false
    }
    
    // MARK: - Group Chat
    private func loadMockGroupMessages() {
        // ✅ Создаем сообщения для каждой группы отдельно
        
        // Ортголики (id: "1")
        groupMessages["1"] = [
            GroupMessage(
                id: "1-1",
                text: "Всем привет! Кто-нибудь делал домашку по математике?",
                authorNickname: "Айдай",
                authorUID: "user1",
                timestamp: Date().addingTimeInterval(-3600 * 2),
                isCurrentUser: false,
                imageData: nil,
                videoURL: nil,
                documentURL: nil,
                documentName: nil
            ),
            GroupMessage(
                id: "1-2",
                text: "Да, я уже сделал. Если нужна помощь - пишите!",
                authorNickname: "Бекжан",
                authorUID: "user2",
                timestamp: Date().addingTimeInterval(-3600),
                isCurrentUser: false,
                imageData: nil,
                videoURL: nil,
                documentURL: nil,
                documentName: nil
            )
        ]
        
        // Дизайнеры (id: "2")
        groupMessages["2"] = [
            GroupMessage(
                id: "2-1",
                text: "Привет! Кто хочет поработать над новым проектом?",
                authorNickname: "Динара",
                authorUID: "user3",
                timestamp: Date().addingTimeInterval(-7200),
                isCurrentUser: false,
                imageData: nil,
                videoURL: nil,
                documentURL: nil,
                documentName: nil
            )
        ]
        
        // Фотография (id: "3")
        groupMessages["3"] = [
            GroupMessage(
                id: "3-1",
                text: "Завтра планируется фотосессия в 15:00!",
                authorNickname: "Азамат",
                authorUID: "user4",
                timestamp: Date().addingTimeInterval(-5400),
                isCurrentUser: false,
                imageData: nil,
                videoURL: nil,
                documentURL: nil,
                documentName: nil
            )
        ]
    }
    
    func sendGroupMessage(
        groupID: String,
        text: String,
        imageData: Data? = nil,
        videoURL: URL? = nil,
        documentURL: URL? = nil,
        documentName: String? = nil
    ) async throws {
        guard !text.isEmpty || imageData != nil || videoURL != nil || documentURL != nil else { return }
        
        // TODO: Отправить в Firebase
        try await Task.sleep(for: .seconds(0.5))
        
        let newMessage = GroupMessage(
            id: UUID().uuidString,
            text: text,
            authorNickname: "Вы",
            authorUID: "current-user",
            timestamp: Date(),
            isCurrentUser: true,
            imageData: imageData,
            videoURL: videoURL,
            documentURL: documentURL,
            documentName: documentName
        )
        
        // ✅ Добавляем сообщение в конкретную группу
        if groupMessages[groupID] != nil {
            groupMessages[groupID]?.append(newMessage)
        } else {
            groupMessages[groupID] = [newMessage]
        }
    }
    
    // MARK: - Private Chats
    private func loadMockPrivateChats() {
        privateChats = [
            PrivateChat(
                id: "1",
                participantName: "Эркебулан (Учитель)",
                participantUID: "teacher1",
                lastMessage: "Не забудьте сдать домашнее задание до пятницы",
                lastMessageTime: Date().addingTimeInterval(-3600),
                unreadCount: 2,
                isTeacher: true,
                messages: [
                    PrivateMessage(id: "m1", text: "Здравствуйте!", senderUID: "current-user", timestamp: Date().addingTimeInterval(-7200), isCurrentUser: true, imageData: nil, videoURL: nil, documentURL: nil, documentName: nil),
                    PrivateMessage(id: "m2", text: "Привет! Как дела с учебой?", senderUID: "teacher1", timestamp: Date().addingTimeInterval(-5400), isCurrentUser: false, imageData: nil, videoURL: nil, documentURL: nil, documentName: nil),
                    PrivateMessage(id: "m3", text: "Не забудьте сдать домашнее задание до пятницы", senderUID: "teacher1", timestamp: Date().addingTimeInterval(-3600), isCurrentUser: false, imageData: nil, videoURL: nil, documentURL: nil, documentName: nil)
                ]
            ),
            PrivateChat(
                id: "2",
                participantName: "Динара",
                participantUID: "user3",
                lastMessage: "Окей, договорились!",
                lastMessageTime: Date().addingTimeInterval(-7200),
                unreadCount: 0,
                isTeacher: false,
                messages: [
                    PrivateMessage(id: "m4", text: "Привет! Пойдем вместе на обед?", senderUID: "user3", timestamp: Date().addingTimeInterval(-8000), isCurrentUser: false, imageData: nil, videoURL: nil, documentURL: nil, documentName: nil),
                    PrivateMessage(id: "m5", text: "Давай! В 13:00?", senderUID: "current-user", timestamp: Date().addingTimeInterval(-7500), isCurrentUser: true, imageData: nil, videoURL: nil, documentURL: nil, documentName: nil),
                    PrivateMessage(id: "m6", text: "Окей, договорились!", senderUID: "user3", timestamp: Date().addingTimeInterval(-7200), isCurrentUser: false, imageData: nil, videoURL: nil, documentURL: nil, documentName: nil)
                ]
            ),
            PrivateChat(
                id: "3",
                participantName: "Азамат",
                participantUID: "user6",
                lastMessage: "Можешь помочь с химией?",
                lastMessageTime: Date().addingTimeInterval(-86400),
                unreadCount: 1,
                isTeacher: false,
                messages: [
                    PrivateMessage(id: "m7", text: "Можешь помочь с химией?", senderUID: "user6", timestamp: Date().addingTimeInterval(-86400), isCurrentUser: false, imageData: nil, videoURL: nil, documentURL: nil, documentName: nil)
                ]
            )
        ]
    }
    
    func sendPrivateMessage(
        chatID: String,
        text: String,
        imageData: Data? = nil,
        videoURL: URL? = nil,
        documentURL: URL? = nil,
        documentName: String? = nil
    ) async throws {
        guard !text.isEmpty || imageData != nil || videoURL != nil || documentURL != nil else { return }
        
        // TODO: Отправить в Firebase
        try await Task.sleep(for: .seconds(0.5))
        
        if let chatIndex = privateChats.firstIndex(where: { $0.id == chatID }) {
            let newMessage = PrivateMessage(
                id: UUID().uuidString,
                text: text,
                senderUID: "current-user",
                timestamp: Date(),
                isCurrentUser: true,
                imageData: imageData,
                videoURL: videoURL,
                documentURL: documentURL,
                documentName: documentName
            )
            
            privateChats[chatIndex].messages.append(newMessage)
        }
    }
    
    // MARK: - Mark Chat As Read
    func markPrivateChatAsRead(_ chatID: String) {
        guard let index = privateChats.firstIndex(where: { $0.id == chatID }) else { return }
        privateChats[index].unreadCount = 0
    }
    
    // MARK: - My Groups
    private func loadMockGroups() {
        myGroups = [
            StudentGroup(
                id: "1",
                name: "Ортголики",
                description: "Основная группа студентов School Club",
                membersCount: 25,
                unreadCount: 30,
                lastMessage: "Супер, спасибо! Скину фото задачи чуть позже",
                lastMessageTime: Date().addingTimeInterval(-1800)
            ),
            StudentGroup(
                id: "2",
                name: "Дизайнеры",
                description: "Группа по предметно-ориентированному дизайну",
                membersCount: 15,
                unreadCount: 5,
                lastMessage: "Кто-нибудь знает где найти референсы?",
                lastMessageTime: Date().addingTimeInterval(-3600 * 2)
            ),
            StudentGroup(
                id: "3",
                name: "Фотография",
                description: "Изучаем искусство фотографии",
                membersCount: 18,
                unreadCount: 12,
                lastMessage: "Завтра будет практическое занятие!",
                lastMessageTime: Date().addingTimeInterval(-3600 * 5)
            )
        ]
    }
}

// MARK: - Models

struct ForumPost: Identifiable {
    let id: String
    let authorUID: String
    let authorNickname: String
    let authorAvatarURL: String?
    let questionImageURL: String?
    let questionImageData: Data?
    let questionText: String
    let createdAt: Date
    let isModerated: Bool
    var reportCount: Int
    var answers: [ForumAnswer]
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        let hours = Int(interval / 3600)
        let days = Int(interval / (3600 * 24))
        
        if days > 0 {
            return "\(days) дн. назад"
        } else if hours > 0 {
            return "\(hours) ч. назад"
        } else {
            return "только что"
        }
    }
}

struct ForumAnswer: Identifiable {
    let id: String
    let authorUID: String
    let authorNickname: String
    let text: String
    let imageData: Data?
    let videoURL: URL?
    let documentURL: URL?
    let documentName: String?
    let createdAt: Date
    var likes: Int
}

struct AIMessage: Identifiable {
    let id: String
    let text: String
    let imageData: Data?
    let videoURL: URL?
    let documentURL: URL?
    let documentName: String?
    let isUser: Bool
    let timestamp: Date
    
    var timeAgo: String {
        timestamp.relativeRu()
    }
}
