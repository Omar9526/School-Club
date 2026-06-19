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
    @StateObject private var tabBarVisibility = TabBarVisibility() // ✅ Управление видимостью таб-бара
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Контент выбранного таба
            TabContent(selectedTab: selectedTab)
                .environmentObject(authViewModel)
                .environmentObject(tabBarVisibility) // ✅ Передаём в дочерние view
            
            // Кастомный TabBar — показываем только если не скрыт
            if !tabBarVisibility.isHidden {
                CustomTabBar(selectedTab: $selectedTab)
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

// MARK: - Custom TabBar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
            // [1] УРОКИ
            TabBarButton(
                title: L10n.tabLessons,
                icon: "book.fill",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            // [2] ДВИЖ
            TabBarButton(
                title: L10n.tabMovement,
                icon: "flame.fill",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            // [3] БРЕЙК
            TabBarButton(
                title: L10n.tabBreak,
                icon: "gamecontroller.fill",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
            
            // [4] ЧАТ
            TabBarButton(
                title: L10n.tabChat,
                icon: "message.fill",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
            
            // [5] ПРОФИЛЬ
            TabBarButton(
                title: L10n.tabProfile,
                icon: "person.fill",
                isSelected: selectedTab == 4,
                action: { selectedTab = 4 }
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Blur эффект для современного вида
                if #available(iOS 15.0, *) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                } else {
                    Rectangle()
                        .fill(Color(uiColor: .systemBackground))
                }
                
                // Верхняя тонкая линия-разделитель
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#FFE600").opacity(0.3),
                                    Color(hex: "#E84E1B").opacity(0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                    
                    Spacer()
                }
            }
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
            radius: 12,
            x: 0,
            y: -4
        )
    }
}

// MARK: - TabBar Button
struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Фон для активного таба
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FFE600"),
                                        Color(hex: "#FFD000")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 32)
                            .shadow(
                                color: Color(hex: "#FFE600").opacity(0.4),
                                radius: 8,
                                x: 0,
                                y: 2
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Иконка
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(
                            isSelected
                            ? LinearGradient(
                                colors: [Color(hex: "#1B2A6B"), Color(hex: "#2A3A7B")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            : LinearGradient(
                                colors: [Color.secondary, Color.secondary],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                .frame(height: 32)
                
                // Текст
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(TabBarButtonStyle())
    }
}

// Кастомный стиль для плавного нажатия
struct TabBarButtonStyle: ButtonStyle {
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
