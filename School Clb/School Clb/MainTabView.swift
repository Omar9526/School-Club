//
//  MainTabView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import Combine

// MARK: - TabBar Visibility Manager
class TabBarVisibility: ObservableObject {
    @Published var isHidden = false
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var refreshView = false
    @StateObject private var tabBarVisibility = TabBarVisibility()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Контент выбранного таба
            TabContent(selectedTab: selectedTab)
                .environmentObject(authViewModel)
                .environmentObject(tabBarVisibility)
            
            // Плавающий таб-бар капсулой — показываем только если не скрыт
            if !tabBarVisibility.isHidden {
                FloatingTabBar(selectedTab: $selectedTab)
                    .id(refreshView)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshView.toggle()
        }
    }
}

// MARK: - Tab Content
struct TabContent: View {
    let selectedTab: Int
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                LessonsView()
            case 1:
                MovementView()
            case 2:
                BreakView()
            case 3:
                ChatView()
            case 4:
                ProfileView()
            default:
                LessonsView()
            }
        }
    }
}

// MARK: - Floating TabBar (Капсула)
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    
    let tabs: [(title: String, icon: String)] = [
        (L10n.tabLessons, "book.fill"),
        (L10n.tabMovement, "flame.fill"),
        (L10n.tabBreak, "gamecontroller.fill"),
        (L10n.tabChat, "message.fill"),
        (L10n.tabProfile, "person.fill")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                FloatingTabButton(
                    title: tabs[index].title,
                    icon: tabs[index].icon,
                    isSelected: selectedTab == index,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = index
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.12),
                    radius: 16,
                    x: 0,
                    y: 4
                )
        )
        .padding(.horizontal, 16) // ✅ Отступ по бокам от краёв экрана
        .padding(.bottom, 12) // ✅ Приподнят над низом
    }
}

// MARK: - Floating Tab Button
struct FloatingTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // ✅ Синяя подложка-пилюля под активной иконкой
                    if isSelected {
                        Capsule()
                            .fill(Color(hex: "#1B2A6B").opacity(0.12))
                            .frame(width: 52, height: 32)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Иконка
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? Color(hex: "#1B2A6B") : Color.gray)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .frame(height: 32)
                
                // Текст
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color(hex: "#1B2A6B") : Color.gray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(FloatingTabButtonStyle())
    }
}

// Кастомный стиль для плавного нажатия
struct FloatingTabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
