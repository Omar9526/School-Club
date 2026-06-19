//
//  EditorDashboardView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct EditorDashboardView: View {
    @State private var showUploadLesson = false
    @State private var showUploadTest = false
    @State private var showModeration = false
    @State private var showDiscount = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок
                    headerSection
                    
                    // Меню редактора
                    VStack(spacing: 16) {
                        EditorMenuButton(
                            icon: "video.badge.plus",
                            title: "Загрузить урок",
                            subtitle: "Добавить новый видеоурок",
                            color: "#1B2A6B"
                        ) {
                            showUploadLesson = true
                        }
                        
                        EditorMenuButton(
                            icon: "doc.badge.plus",
                            title: "Загрузить тест",
                            subtitle: "Добавить вопросы к уроку",
                            color: "#E84E1B"
                        ) {
                            showUploadTest = true
                        }
                        
                        EditorMenuButton(
                            icon: "shield.checkered",
                            title: "Модерация аккаунтов",
                            subtitle: "Управление пользователями",
                            color: "#AF52DE"
                        ) {
                            showModeration = true
                        }
                        
                        EditorMenuButton(
                            icon: "percent",
                            title: "Назначить скидку",
                            subtitle: "Скидки на премиум подписку",
                            color: "#FFE600"
                        ) {
                            showDiscount = true
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Панель редактора")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showUploadLesson) {
            UploadLessonView()
        }
        .sheet(isPresented: $showUploadTest) {
            UploadTestView()
        }
        .sheet(isPresented: $showModeration) {
            ModerationView()
        }
        .sheet(isPresented: $showDiscount) {
            DiscountView()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.key.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#1B2A6B"))
            
            Text("Панель редактора")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#1B2A6B"))
            
            Text("Управление контентом и пользователями")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
    }
}

// MARK: - Editor Menu Button
struct EditorMenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: color).opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: color))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    Text(subtitle)
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
}

#Preview {
    EditorDashboardView()
}
