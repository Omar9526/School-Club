//
//  CourseLevelsView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct CourseLevelsView: View {
    let course: Course
    @ObservedObject var viewModel: LessonsViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var refreshView = false
    
    // Используем язык контента КУРСА, а не интерфейса!
    var displayTitle: String {
        course.contentLanguage == "RU" ? course.titleRu : course.titleKg
    }
    
    var navigationTitle: String {
        course.contentLanguage == "RU" ? "Уровни" : "Деңгээлдер"
    }
    
    var selectLevelText: String {
        course.contentLanguage == "RU" ? "Выберите уровень для начала обучения" : "Окууну баштоо үчүн деңгээлди тандаңыз"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок курса
                VStack(spacing: 8) {
                    Text(displayTitle)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                        .multilineTextAlignment(.center)
                    
                    Text(selectLevelText)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)
                
                // Уровни
                ForEach(viewModel.levels) { level in
                    NavigationLink(destination: LessonListView(level: level, viewModel: viewModel, isPremium: profileViewModel.user?.isPremium ?? false)) {
                        LevelCard(level: level, isPremium: profileViewModel.user?.isPremium ?? false, courseLanguage: course.contentLanguage)
                    }
                }
                
                // Пробные тесты
                NavigationLink(destination: PracticeListView(course: course)) {
                    PracticeTestsCard(courseLanguage: course.contentLanguage)
                }
            }
            .padding(20)
        }
        .background(Color(hex: "#F5F5F5"))
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadLevels(for: course)
        }
        .id(refreshView)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshView.toggle()
        }
    }
}

// MARK: - Level Card
struct LevelCard: View {
    let level: CourseLevel
    let isPremium: Bool
    let courseLanguage: String // "KG" или "RU"
    
    var displayTitle: String {
        courseLanguage == "RU" ? level.titleRu : level.titleKg
    }
    
    var pointsWord: String {
        courseLanguage == "RU" ? "балл" : "упай"
    }
    
    var lessonsText: String {
        if courseLanguage == "RU" {
            let count = level.totalLessons
            let lastDigit = count % 10
            let lastTwoDigits = count % 100
            
            if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
                return "\(count) уроков"
            } else if lastDigit == 1 {
                return "\(count) урок"
            } else if lastDigit >= 2 && lastDigit <= 4 {
                return "\(count) урока"
            } else {
                return "\(count) уроков"
            }
        } else {
            return "\(level.totalLessons) сабак"
        }
    }
    
    var freeWord: String {
        courseLanguage == "RU" ? "бесплатно" : "акысыз"
    }
    
    var premiumWord: String {
        courseLanguage == "RU" ? "премиум" : "премиум"
    }
    
    var progressWord: String {
        courseLanguage == "RU" ? "Прогресс" : "Прогресс"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок уровня
            HStack {
                Text(displayTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            
            // Диапазон баллов
            Text("\(level.minScore)-\(level.maxScore) \(pointsWord)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            // Информация об уроках
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    Text(lessonsText)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "lock.open.fill")
                        .foregroundColor(.green)
                    Text("\(level.freeLessons) \(freeWord)")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                if !isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .foregroundColor(Color(hex: "#E84E1B"))
                        Text("\(level.totalLessons - level.freeLessons) \(premiumWord)")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Прогресс бар (заглушка)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(progressWord): 0%")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(Color(hex: "#1B2A6B"))
                            .frame(width: geometry.size.width * 0, height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Practice Tests Card
struct PracticeTestsCard: View {
    let courseLanguage: String
    
    var title: String {
        courseLanguage == "RU" ? "Пробные тесты" : "Сынамык тесттер"
    }
    
    var subtitle: String {
        courseLanguage == "RU" ? "Полноценные пробные тесты ОРТ" : "ЖРТнын толук сынамык тесттери"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#FFE600").opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#FFE600"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#FFE600"), lineWidth: 2)
        )
        .shadow(color: Color(hex: "#FFE600").opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        CourseLevelsView(
            course: Course(id: "1", title: "ЖРТ кыргыз тилинде", titleKg: "ЖРТ кыргыз тилинде", titleRu: "ОРТ на кыргызском", order: 1, category: .ort, contentLanguage: "KG"),
            viewModel: LessonsViewModel()
        )
    }
}
