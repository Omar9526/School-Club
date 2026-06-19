//
//  MovementView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct MovementView: View {
    @StateObject private var viewModel = MovementViewModel()
    @StateObject private var pointsService = PointsService.shared
    
    @State private var showGroupGrades = false
    @State private var showTestHistory = false
    @State private var showSchedule = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // А) БАЛЛЫ МОЕЙ ГРУППЫ
                    groupPointsCard
                    
                    // Б) МОИ БАЛЛЫ
                    myPointsCard
                    
                    // В) ПОБЕДИТЕЛИ ГРУППЫ (фотографии)
                    winnersSection
                    
                    // Г) ОТМЕТКИ ГРУППЫ
                    actionButton(
                        icon: "chart.bar.doc.horizontal",
                        title: "ОТМЕТКИ ГРУППЫ",
                        action: { showGroupGrades = true }
                    )
                    
                    // Д) РЕЗУЛЬТАТЫ ТЕСТОВ
                    actionButton(
                        icon: "list.bullet.clipboard",
                        title: "РЕЗУЛЬТАТЫ ТЕСТОВ",
                        action: { showTestHistory = true }
                    )
                    
                    // Е) ВАШЕ РАСПИСАНИЕ
                    actionButton(
                        icon: "calendar",
                        title: "ВАШЕ РАСПИСАНИЕ",
                        action: { showSchedule = true }
                    )
                }
                .padding(20)
                .padding(.bottom, 100) // ✅ Отступ снизу, чтобы контент не заезжал под таб-бар
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Курс")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showGroupGrades) {
            MovementGroupGradesView()
        }
        .sheet(isPresented: $showTestHistory) {
            MovementTestHistoryView()
        }
        .sheet(isPresented: $showSchedule) {
            MovementScheduleView()
        }
    }
    
    // MARK: - А) БАЛЛЫ МОЕЙ ГРУППЫ
    private var groupPointsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("БАЛЛЫ МОЕЙ ГРУППЫ")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
            }
            
            Text("здесь баллы группы")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "#FFE600"))
                
                Text("\(viewModel.groupPoints)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#1B2A6B").opacity(0.1), Color(hex: "#1B2A6B").opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#1B2A6B").opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Б) МОИ БАЛЛЫ
    private var myPointsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#FFE600"))
                
                Text("МОИ БАЛЛЫ")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
            }
            
            Text("личные баллы с игр и уроков")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "#FFE600"))
                
                Text("\(pointsService.currentPoints)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#FFE600").opacity(0.15), Color(hex: "#FFE600").opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#FFE600").opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - В) ПОБЕДИТЕЛИ ГРУППЫ
    private var winnersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#E84E1B"))
                
                Text("ПОБЕДИТЕЛИ ГРУППЫ")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Text("фото")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            
                            Text("Победитель \(index + 1)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Action Button
    private func actionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                    .frame(width: 40)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Г) Movement Group Grades View
struct MovementGroupGradesView: View {
    @Environment(\.dismiss) private var dismiss
    
    let mockGrades: [(name: String, grade: String)] = [
        ("Айдай Омурова", "5.0"),
        ("Бекжан Токтогулов", "4.8"),
        ("Гульнара Сыдыкова", "4.5"),
        ("Данияр Асанов", "4.2"),
        ("Эльмира Жумабаева", "4.0"),
        ("Жаныбек Курманов", "3.8"),
        ("Замира Абдиева", "3.5")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(mockGrades, id: \.name) { student in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(student.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                            
                            Text("Средний балл")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(student.grade)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#FFE600"))
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Отметки группы")
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

// MARK: - Д) Movement Test History View
struct MovementTestHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    let mockResults: [(test: String, score: String, date: String)] = [
        ("Викторина: Легко", "8/10", "19 июня"),
        ("Викторина: Средне", "7/10", "18 июня"),
        ("Тест по математике", "9/10", "15 июня"),
        ("Викторина: Сложно", "6/10", "12 июня"),
        ("Тест по физике", "8/10", "10 июня")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(mockResults, id: \.test) { result in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(result.test)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                            
                            Spacer()
                            
                            Text(result.score)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#E84E1B"))
                        }
                        
                        Text(result.date)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Результаты тестов")
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

// MARK: - Е) Movement Schedule View
struct MovementScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Филиал
                    scheduleBlock(
                        icon: "building.2.fill",
                        title: "Филиал",
                        content: "School Club — Центральный филиал\nул. Московская, 123"
                    )
                    
                    // Дни
                    scheduleBlock(
                        icon: "calendar",
                        title: "Дни занятий",
                        content: "Понедельник, Среда, Пятница"
                    )
                    
                    // Время
                    scheduleBlock(
                        icon: "clock.fill",
                        title: "Время",
                        content: "14:00 — 17:00"
                    )
                    
                    // Преподаватель
                    scheduleBlock(
                        icon: "person.fill",
                        title: "Преподаватель",
                        content: "Асанов Бакыт Кубанычбекович"
                    )
                    
                    // Группа
                    scheduleBlock(
                        icon: "person.3.fill",
                        title: "Группа",
                        content: "Математика — Группа 7А"
                    )
                }
                .padding(20)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Ваше расписание")
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
    
    private func scheduleBlock(icon: String, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
            }
            
            Text(content)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    MovementView()
}
