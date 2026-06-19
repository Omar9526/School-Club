//
//  LessonsViewModel.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import Combine

@MainActor
class LessonsViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var selectedCourse: Course?
    @Published var levels: [CourseLevel] = []
    @Published var lessons: [Lesson] = []
    @Published var currentLesson: Lesson?
    @Published var questions: [Question] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadMockCourses()
    }
    
    // MARK: - Load Mock Courses (временно, потом заменим на Firebase)
    private func loadMockCourses() {
        courses = [
            Course(id: "1", title: "ЖРТ кыргыз тилинде", titleKg: "ЖРТ кыргыз тилинде", titleRu: "ОРТ на кыргызском", order: 1, category: .ort, contentLanguage: "KG"),
            Course(id: "2", title: "ОРТ на русском языке", titleKg: "ОРТ орус тилинде", titleRu: "ОРТ на русском языке", order: 2, category: .ort, contentLanguage: "RU"),
            Course(id: "3", title: "ХИМБИО кыргыз тилинде", titleKg: "ХИМБИО кыргыз тилинде", titleRu: "ХИМБИО на кыргызском", order: 3, category: .himbio, contentLanguage: "KG"),
            Course(id: "4", title: "ХИМБИО на русском", titleKg: "ХИМБИО орус тилинде", titleRu: "ХИМБИО на русском", order: 4, category: .himbio, contentLanguage: "RU"),
            Course(id: "5", title: "Башка предметтик тесттер", titleKg: "Башка предметтик тесттер", titleRu: "Другие предметные тесты", order: 5, category: .other, contentLanguage: "KG")
        ]
    }
    
    // MARK: - Load Levels
    func loadLevels(for course: Course) {
        selectedCourse = course
        
        // Mock данные
        levels = [
            CourseLevel(id: "1", courseId: course.id, title: "А деңгээли", titleKg: "А деңгээли", titleRu: "Уровень А", minScore: 0, maxScore: 120, order: 1, totalLessons: 24, freeLessons: 3),
            CourseLevel(id: "2", courseId: course.id, title: "В деңгээли", titleKg: "В деңгээли", titleRu: "Уровень В", minScore: 121, maxScore: 170, order: 2, totalLessons: 24, freeLessons: 3),
            CourseLevel(id: "3", courseId: course.id, title: "С деңгээли", titleKg: "С деңгээли", titleRu: "Уровень С", minScore: 171, maxScore: 245, order: 3, totalLessons: 24, freeLessons: 3)
        ]
    }
    
    // MARK: - Load Lessons
    func loadLessons(for level: CourseLevel) {
        isLoading = true
        
        // Mock данные
        var mockLessons: [Lesson] = []
        
        // Определяем язык контента курса
        let courseLanguage = selectedCourse?.contentLanguage ?? "KG"
        
        // Пробный тест
        mockLessons.append(Lesson(
            id: "practice-test",
            levelId: level.id,
            title: "СЫНАМЫК ТЕСТ №1",
            titleKg: "СЫНАМЫК ТЕСТ №1",
            titleRu: "ПРОБНЫЙ ТЕСТ №1",
            order: 0,
            isFree: true,
            isPracticeTest: true,
            videoURL: "https://example.com/practice-video.mp4",
            description: "Пробный тест для оценки вашего текущего уровня",
            descriptionKg: "Учурдагы деңгээлиңизди баалоо үчүн сынамык тест",
            descriptionRu: "Пробный тест для оценки вашего текущего уровня",
            subject: .text
        ))
        
        // Обычные уроки
        for i in 1...level.totalLessons {
            let lessonTitleKg = "Сабак \(i)"
            let lessonTitleRu = "Урок \(i)"
            let descriptionKg = "Сабактын сүрөттөмөсү \(i)"
            let descriptionRu = "Описание урока \(i)"
            
            mockLessons.append(Lesson(
                id: "lesson-\(i)",
                levelId: level.id,
                title: courseLanguage == "RU" ? lessonTitleRu : lessonTitleKg,
                titleKg: lessonTitleKg,
                titleRu: lessonTitleRu,
                order: i,
                isFree: i <= level.freeLessons,
                isPracticeTest: false,
                videoURL: "https://example.com/lesson-\(i).mp4",
                videoAnalysisURL: "https://example.com/lesson-\(i)-analysis.mp4",
                description: courseLanguage == "RU" ? descriptionRu : descriptionKg,
                descriptionKg: descriptionKg,
                descriptionRu: descriptionRu,
                subject: i % 3 == 0 ? .math : (i % 3 == 1 ? .chemistry : .text)
            ))
        }
        
        lessons = mockLessons
        isLoading = false
    }
    
    // MARK: - Load Questions
    func loadQuestions(for lesson: Lesson) {
        currentLesson = lesson
        
        // Mock вопросы
        var mockQuestions: [Question] = []
        
        for i in 1...10 {
            let type: QuestionType = lesson.subject == .text ? .text : .image
            
            mockQuestions.append(Question(
                id: "q-\(i)",
                lessonId: lesson.id,
                order: i,
                type: type,
                questionText: type == .text ? "Вопрос \(i): Какой правильный ответ?" : nil,
                questionImageURL: type == .image ? "https://example.com/question-\(i).png" : nil,
                optionA: "Вариант А",
                optionB: "Вариант Б",
                optionC: "Вариант В",
                optionD: "Вариант Г",
                correctAnswer: ["A", "B", "C", "D"].randomElement()!
            ))
        }
        
        questions = mockQuestions
    }
    
    // MARK: - Save Progress
    func saveProgress(lessonId: String, score: Int, totalQuestions: Int) {
        // TODO: Сохранение в Firestore users/{uid}/progress
        print("Progress saved: \(score)/\(totalQuestions) for lesson \(lessonId)")
    }
    
    // MARK: - Check Access
    func canAccessLesson(_ lesson: Lesson, isPremium: Bool) -> Bool {
        return lesson.isFree || isPremium
    }
}

// MARK: - Models

struct Course: Identifiable {
    let id: String
    let title: String
    let titleKg: String
    let titleRu: String
    let order: Int
    let category: CourseCategory
    let contentLanguage: String // "KG" или "RU" - язык контента курса
}

enum CourseCategory: String {
    case ort = "SC | ЖРТ жөнүндө"
    case himbio = "Все про ОРТ"
    case other = "Башка"
}

struct CourseLevel: Identifiable {
    let id: String
    let courseId: String
    let title: String
    let titleKg: String
    let titleRu: String
    let minScore: Int
    let maxScore: Int
    let order: Int
    let totalLessons: Int
    let freeLessons: Int
}

struct Lesson: Identifiable {
    let id: String
    let levelId: String
    let title: String
    let titleKg: String
    let titleRu: String
    let order: Int
    let isFree: Bool
    let isPracticeTest: Bool
    let videoURL: String?
    let videoAnalysisURL: String?
    let description: String
    let descriptionKg: String
    let descriptionRu: String
    let subject: SubjectType
    
    init(id: String, levelId: String, title: String, titleKg: String? = nil, titleRu: String? = nil, order: Int, isFree: Bool, isPracticeTest: Bool, videoURL: String?, videoAnalysisURL: String? = nil, description: String, descriptionKg: String? = nil, descriptionRu: String? = nil, subject: SubjectType) {
        self.id = id
        self.levelId = levelId
        self.title = title
        self.titleKg = titleKg ?? title
        self.titleRu = titleRu ?? title
        self.order = order
        self.isFree = isFree
        self.isPracticeTest = isPracticeTest
        self.videoURL = videoURL
        self.videoAnalysisURL = videoAnalysisURL
        self.description = description
        self.descriptionKg = descriptionKg ?? description
        self.descriptionRu = descriptionRu ?? description
        self.subject = subject
    }
}

enum SubjectType: String {
    case math = "math"
    case chemistry = "chemistry"
    case biology = "biology"
    case text = "text"
}

struct Question: Identifiable, Sendable {
    let id: String
    let lessonId: String
    let order: Int
    let type: QuestionType
    let questionText: String?
    let questionImageURL: String?
    let optionA: String
    let optionB: String
    let optionC: String
    let optionD: String
    let correctAnswer: String
}

enum QuestionType: String, Sendable {
    case text = "text"
    case image = "image"
}
