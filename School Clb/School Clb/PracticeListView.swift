//
//  PracticeListView.swift
//  School Club
//
//  Created on 22.06.2026
//

import SwiftUI

struct PracticeListView: View {
    let course: Course
    @StateObject private var viewModel = LessonsViewModel()
    
    var title: String {
        course.contentLanguage == "RU" ? "Пробные тесты" : "Сынамык тесттер"
    }
    
    var subtitle: String {
        course.contentLanguage == "RU" ? "Выберите пробный тест" : "Сынамык тестти тандаңыз"
    }
    
    // Mock данные пробных тестов
    var practiceTests: [PracticeTest] {
        [
            PracticeTest(
                id: "practice-1",
                numberKg: "№1",
                numberRu: "№1",
                titleKg: "Сынамык тест №1",
                titleRu: "Пробный тест №1",
                descriptionKg: "ЖРТнын толук сынамык тести",
                descriptionRu: "Полноценный пробный тест ОРТ",
                questionCount: 100
            ),
            PracticeTest(
                id: "practice-2",
                numberKg: "№2",
                numberRu: "№2",
                titleKg: "Сынамык тест №2",
                titleRu: "Пробный тест №2",
                descriptionKg: "ЖРТнын толук сынамык тести",
                descriptionRu: "Полноценный пробный тест ОРТ",
                questionCount: 100
            ),
            PracticeTest(
                id: "practice-3",
                numberKg: "№3",
                numberRu: "№3",
                titleKg: "Сынамык тест №3",
                titleRu: "Пробный тест №3",
                descriptionKg: "ЖРТнын толук сынамык тести",
                descriptionRu: "Полноценный пробный тест ОРТ",
                questionCount: 100
            )
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок
                VStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#FFE600"))
                    
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                // Список пробных тестов
                ForEach(practiceTests) { test in
                    NavigationLink(destination: PracticeTestView(
                        lesson: test.toLesson(),
                        viewModel: viewModel
                    )) {
                        PracticeTestListCard(test: test, courseLanguage: course.contentLanguage)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(hex: "#F5F5F5"))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Practice Test Model
struct PracticeTest: Identifiable {
    let id: String
    let numberKg: String
    let numberRu: String
    let titleKg: String
    let titleRu: String
    let descriptionKg: String
    let descriptionRu: String
    let questionCount: Int
    
    func toLesson() -> Lesson {
        Lesson(
            id: id,
            levelId: "practice",
            title: titleRu,
            titleKg: titleKg,
            titleRu: titleRu,
            order: 0,
            isFree: true,
            isPracticeTest: true,
            videoURL: "https://example.com/practice-video.mp4",
            description: descriptionRu,
            descriptionKg: descriptionKg,
            descriptionRu: descriptionRu,
            subject: .text
        )
    }
}

// MARK: - Practice Test Card
struct PracticeTestListCard: View {
    let test: PracticeTest
    let courseLanguage: String
    
    var displayTitle: String {
        courseLanguage == "RU" ? test.titleRu : test.titleKg
    }
    
    var displayDescription: String {
        courseLanguage == "RU" ? test.descriptionRu : test.titleKg
    }
    
    var questionsText: String {
        courseLanguage == "RU" ? "\(test.questionCount) вопросов" : "\(test.questionCount) суроо"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка с номером
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FFE600").opacity(0.3), Color(hex: "#FFE600").opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#FFE600"))
                    
                    Text(courseLanguage == "RU" ? test.numberRu : test.numberKg)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                }
            }
            
            // Информация
            VStack(alignment: .leading, spacing: 6) {
                Text(displayTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(questionsText)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(courseLanguage == "RU" ? "180 мин" : "180 мүн")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#FFE600").opacity(0.3), lineWidth: 2)
        )
    }
}

#Preview {
    NavigationStack {
        PracticeListView(
            course: Course(
                id: "1",
                title: "ЖРТ кыргыз тилинде",
                titleKg: "ЖРТ кыргыз тилинде",
                titleRu: "ОРТ на кыргызском",
                order: 1,
                category: .ort,
                contentLanguage: "KG"
            )
        )
    }
}
