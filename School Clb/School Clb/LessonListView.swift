//
//  LessonListView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct LessonListView: View {
    let level: CourseLevel
    @ObservedObject var viewModel: LessonsViewModel
    let isPremium: Bool
    
    @State private var showPremiumAlert = false
    @State private var showPremium = false
    @State private var refreshView = false
    
    var displayTitle: String {
        guard let course = viewModel.selectedCourse else { return level.title }
        return course.contentLanguage == "RU" ? level.titleRu : level.titleKg
    }
    
    var courseLanguage: String {
        viewModel.selectedCourse?.contentLanguage ?? "KG"
    }
    
    var premiumRequiredTitle: String {
        courseLanguage == "RU" ? "Премиум требуется" : "Премиум керек"
    }
    
    var okButton: String {
        courseLanguage == "RU" ? "OK" : "Макул"
    }
    
    var buyPremiumButton: String {
        courseLanguage == "RU" ? "Купить Премиум" : "Премиум сатып алуу"
    }
    
    var premiumMessage: String {
        courseLanguage == "RU" ? "Этот урок доступен только для премиум-подписчиков" : "Бул сабак премиум жазылуучулар үчүн гана жеткиликтүү"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // СЫНАМЫК ТЕСТ вверху
                if let practiceTest = viewModel.lessons.first(where: { $0.isPracticeTest }) {
                    PracticeTestCard(lesson: practiceTest, viewModel: viewModel)
                }
                
                // Список уроков
                ForEach(viewModel.lessons.filter { !$0.isPracticeTest }) { lesson in
                    LessonCard(
                        lesson: lesson,
                        isPremium: isPremium,
                        viewModel: viewModel,
                        onLockedTap: { showPremiumAlert = true }
                    )
                }
            }
            .padding(20)
        }
        .background(Color(hex: "#F5F5F5"))
        .navigationTitle(displayTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadLessons(for: level)
        }
        .alert(premiumRequiredTitle, isPresented: $showPremiumAlert) {
            Button(okButton, role: .cancel) { }
            Button(buyPremiumButton) {
                showPremium = true
            }
        } message: {
            Text(premiumMessage)
        }
        .sheet(isPresented: $showPremium) {
            PremiumView()
        }
        .id(refreshView)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshView.toggle()
        }
    }
}

// MARK: - Practice Test Card
struct PracticeTestCard: View {
    let lesson: Lesson
    @ObservedObject var viewModel: LessonsViewModel
    
    var body: some View {
        NavigationLink(destination: PracticeTestView(lesson: lesson, viewModel: viewModel)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#FFE600"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                        
                        Text("Пробный тест для оценки уровня")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#FFE600").opacity(0.2), Color(hex: "#FFE600").opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#FFE600").opacity(0.5), lineWidth: 2)
            )
        }
    }
}

// MARK: - Lesson Card
struct LessonCard: View {
    let lesson: Lesson
    let isPremium: Bool
    @ObservedObject var viewModel: LessonsViewModel
    let onLockedTap: () -> Void
    
    var canAccess: Bool {
        lesson.isFree || isPremium
    }
    
    var displayTitle: String {
        guard let course = viewModel.selectedCourse else { return lesson.title }
        return course.contentLanguage == "RU" ? lesson.titleRu : lesson.titleKg
    }
    
    var courseLanguage: String {
        viewModel.selectedCourse?.contentLanguage ?? "KG"
    }
    
    var videoLessonText: String {
        courseLanguage == "RU" ? "ВИДЕОУРОК" : "ВИДЕОСАБАК"
    }
    
    var theoryText: String {
        courseLanguage == "RU" ? "теория" : "теория"
    }
    
    var doTestText: String {
        courseLanguage == "RU" ? "РЕШИТЬ ТЕСТ" : "ТЕСТ ИШТӨӨ"
    }
    
    var videoAnalysisText: String {
        courseLanguage == "RU" ? "+ видеоразбор" : "+ видеоталдоо"
    }
    
    var testAloneText: String {
        courseLanguage == "RU" ? "ТЕСТ — самостоятельно" : "ТЕСТ — өз алдынча иштөө"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок урока
            HStack {
                Text(displayTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
                
                if !canAccess {
                    Image(systemName: "lock.fill")
                        .foregroundColor(Color(hex: "#E84E1B"))
                }
            }
            
            // Кнопки: ВИДЕОСАБАК и ТЕСТ ИШТӨӨ
            HStack(spacing: 12) {
                // ВИДЕОСАБАК (теория)
                if canAccess {
                    NavigationLink(destination: VideoLessonView(lesson: lesson, isTheory: true)) {
                        LessonButton(
                            title: videoLessonText,
                            subtitle: theoryText,
                            icon: "play.circle.fill",
                            color: Color(hex: "#1B2A6B")
                        )
                    }
                } else {
                    Button(action: onLockedTap) {
                        LessonButton(
                            title: videoLessonText,
                            subtitle: theoryText,
                            icon: "lock.fill",
                            color: Color.gray
                        )
                    }
                }
                
                // ТЕСТ ИШТӨӨ
                if canAccess {
                    NavigationLink(destination: TestView(lesson: lesson, viewModel: viewModel, hasVideoAnalysis: true)) {
                        LessonButton(
                            title: doTestText,
                            subtitle: videoAnalysisText,
                            icon: "checkmark.circle.fill",
                            color: Color(hex: "#E84E1B")
                        )
                    }
                } else {
                    Button(action: onLockedTap) {
                        LessonButton(
                            title: doTestText,
                            subtitle: videoAnalysisText,
                            icon: "lock.fill",
                            color: Color.gray
                        )
                    }
                }
            }
            
            // ТЕСТ — өз алдынча
            if canAccess {
                NavigationLink(destination: TestView(lesson: lesson, viewModel: viewModel, hasVideoAnalysis: false)) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(Color(hex: "#FFE600"))
                        
                        Text(testAloneText)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .background(Color(hex: "#FFE600").opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                Button(action: onLockedTap) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        
                        Text(testAloneText)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Lesson Button
struct LessonButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationStack {
        LessonListView(
            level: CourseLevel(id: "1", courseId: "1", title: "А деңгээли", titleKg: "А деңгээли", titleRu: "Уровень А", minScore: 0, maxScore: 120, order: 1, totalLessons: 24, freeLessons: 6),
            viewModel: LessonsViewModel(),
            isPremium: false
        )
    }
}
