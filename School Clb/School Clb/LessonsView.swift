//
//  LessonsView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct LessonsView: View {
    @StateObject private var viewModel = LessonsViewModel()
    @State private var showInfoSection: InfoSection?
    @State private var refreshView = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Инфо-кнопки
                infoButtonsRow
                
                // Список всех курсов
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.courses) { course in
                            NavigationLink(destination: CourseLevelsView(course: course, viewModel: viewModel)) {
                                CourseCard(course: course)
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 90) // ✅ Отступ под плавающий таб-бар
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
        .sheet(item: $showInfoSection) { section in
            InfoSectionView(section: section)
        }
    }
    
    // MARK: - Info Buttons Row
    private var infoButtonsRow: some View {
        VStack(spacing: 12) {
            // Подпись под заголовком
            Text("Выберите курс")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            // Три инфо-кнопки
            HStack(spacing: 12) {
                InfoButton(
                    title: "SC",
                    icon: "graduationcap.fill",
                    color: "#1B2A6B",
                    action: { showInfoSection = .sc }
                )
                
                InfoButton(
                    title: "ЖРТ жөнүндө",
                    icon: "book.fill",
                    color: "#E84E1B",
                    action: { showInfoSection = .ortKg }
                )
                
                InfoButton(
                    title: "Все про ОРТ",
                    icon: "book.fill",
                    color: "#FFE600",
                    action: { showInfoSection = .ortRu }
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Info Button
struct InfoButton: View {
    let title: String
    let icon: String
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: color))
                
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(hex: color).opacity(0.1))
            .cornerRadius(10)
        }
    }
}

// MARK: - Info Section Enum
enum InfoSection: String, Identifiable {
    case sc = "SC"
    case ortKg = "ЖРТ жөнүндө"
    case ortRu = "Все про ОРТ"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .sc: return "graduationcap.fill"
        case .ortKg, .ortRu: return "book.fill"
        }
    }
    
    var color: String {
        switch self {
        case .sc: return "#1B2A6B"
        case .ortKg: return "#E84E1B"
        case .ortRu: return "#FFE600"
        }
    }
}

// MARK: - Info Section View
struct InfoSectionView: View {
    let section: InfoSection
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: section.icon)
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: section.color))
                
                Text(section.rawValue)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Скоро здесь будет информация")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Закрыть")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#1B2A6B"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle(section.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
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
