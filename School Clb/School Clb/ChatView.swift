//
//  ChatView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = SOSViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var refreshView = false
    
    var chatTitle: String {
        AppLanguage.current == "RU" ? "Чат" : "Чат"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 1. МОИ ГРУППЫ / СТАТЬ СТУДЕНТОМ
                    if profileViewModel.user?.hasStudentAccess == true {
                        // Показываем карточку "Мои группы"
                        ChatSectionCard(
                            title: "МОИ ГРУППЫ",
                            subtitle: "",
                            description: "Общайтесь с вашими группами",
                            icon: "person.3.fill",
                            color: "#2196F3",
                            badgeCount: 30,
                            isLocked: false,
                            destination: AnyView(MyGroupsListView(viewModel: viewModel))
                        )
                    } else {
                        // Показываем карточку "Стать студентом"
                        BecomeStudentCard()
                    }
                    
                    // 2. ФОРУМ СКУЛ КЛАБ
                    ChatSectionCard(
                        title: "ФОРУМ СКУЛ КЛАБ",
                        subtitle: "",
                        description: "Задавайте вопросы и помогайте другим",
                        icon: "bubble.left.and.bubble.right.fill",
                        color: "#E84E1B",
                        badgeCount: nil,
                        isLocked: !(profileViewModel.user?.hasProAccess ?? false),
                        destination: AnyView(ForumChatView(viewModel: viewModel))
                    )
                    
                    // 3. ИИ-ПРЕПОДАВАТЕЛЬ
                    ChatSectionCard(
                        title: "ИИ-ПРЕПОДАВАТЕЛЬ",
                        subtitle: "",
                        description: "Спросите у искусственного интеллекта",
                        icon: "brain.head.profile",
                        color: "#9C27B0",
                        badgeCount: nil,
                        isLocked: !(profileViewModel.user?.hasProAccess ?? false),
                        destination: AnyView(AITeacherView(viewModel: viewModel))
                    )
                    
                    // 4. ЛИЧНЫЕ ЧАТЫ
                    ChatSectionCard(
                        title: "ЛИЧНЫЕ ЧАТЫ",
                        subtitle: "",
                        description: "Общайтесь с друзьями и учителями",
                        icon: "message.fill",
                        color: "#34C759",
                        badgeCount: 5,
                        isLocked: !(profileViewModel.user?.hasProAccess ?? false),
                        destination: AnyView(PrivateChatsView(viewModel: viewModel))
                    )
                }
                .padding(20)
                .padding(.bottom, 90) // ✅ Отступ под плавающий таб-бар
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(chatTitle)
            .navigationBarTitleDisplayMode(.inline)
            .id(refreshView)
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                refreshView.toggle()
            }
        }
    }
}

// MARK: - Chat Section Card
struct ChatSectionCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: String
    let badgeCount: Int?
    let isLocked: Bool
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                // Иконка с градиентом
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: color).opacity(0.2),
                                    Color(hex: color).opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(hex: color))
                    
                    // Badge с количеством
                    if let count = badgeCount, count > 0, !isLocked {
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.red)
                            .clipShape(Capsule())
                            .offset(x: 20, y: -20)
                    }
                    
                    // Замочек если заблокировано
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 20, y: 20)
                    }
                }
                
                // Текст
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(isLocked ? .secondary : .primary)
                        .lineLimit(1)
                    
                    Text(description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Стрелка
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .disabled(isLocked)
    }
}

// MARK: - Become Student Card
struct BecomeStudentCard: View {
    var body: some View {
        Link(destination: URL(string: "https://schoolclub.kg/enroll")!) {
            VStack(spacing: 16) {
                // Иконка
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#2196F3").opacity(0.2),
                                    Color(hex: "#2196F3").opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(Color(hex: "#2196F3"))
                }
                
                VStack(spacing: 8) {
                    Text("СТАТЬ СТУДЕНТОМ")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("SCHOOL CLUB")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#2196F3"))
                    
                    Text("Присоединяйтесь к нашей группе «Ортголики» и получите доступ к групповому чату")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                HStack {
                    Image(systemName: "link")
                    Text("Записаться")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(hex: "#2196F3"))
                .cornerRadius(12)
            }
            .padding(20)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

#Preview {
    ChatView()
}
