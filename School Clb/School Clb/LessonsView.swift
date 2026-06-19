//
//  LessonsView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @State private var selectedCategory: CourseCategory = .ort
    @State private var refreshView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Табы категорий
                categoryTabs
                
                // Список курсов
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(filteredCourses) { course in
                            NavigationLink(destination: CourseLevelsView(course: course, viewModel: viewModel)) {
                                CourseCard(course: course)
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100) // ✅ Отступ снизу, чтобы контент не заезжал под таб-бар
                }
                .background(Color(hex: "#F5F5F5"))
            }
            .navigationTitle(L10n.lessons)
            .navigationBarTitleDisplayMode(.inline)
            .id(refreshView)
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                refreshView.toggle()
            }
        }
    }
    
    // MARK: - Category Tabs
    private var categoryTabs: some View {
        HStack(spacing: 0) {
            CategoryTabButton(
                title: L10n.categoryORT,
                isSelected: selectedCategory == .ort,
                action: { selectedCategory = .ort }
            )
            
            CategoryTabButton(
                title: L10n.categoryHimBio,
                isSelected: selectedCategory == .himbio,
                action: { selectedCategory = .himbio }
            )
            
            CategoryTabButton(
                title: L10n.categoryOther,
                isSelected: selectedCategory == .other,
                action: { selectedCategory = .other }
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Filtered Courses
    private var filteredCourses: [Course] {
        viewModel.courses.filter { $0.category == selectedCategory }
    }
}

// MARK: - Category Tab Button
struct CategoryTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .regular, design: .rounded))
                .foregroundColor(isSelected ? Color(hex: "#1B2A6B") : .gray)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ? Color(hex: "#FFE600").opacity(0.2) : Color.clear
                )
                .cornerRadius(8)
        }
    }
}

// MARK: - Course Card
struct CourseCard: View {
    let course: Course
    
    var displayTitle: String {
        AppLanguage.current == "RU" ? course.titleRu : course.titleKg
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка
            ZStack {
                Circle()
                    .fill(Color(hex: "#1B2A6B").opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "book.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#1B2A6B"))
            }
            
            // Текст
            VStack(alignment: .leading, spacing: 4) {
                Text(displayTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("3 \(L10n.levelsCount) · \(L10n.lessonsCount(72))")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    LessonsView()
}
