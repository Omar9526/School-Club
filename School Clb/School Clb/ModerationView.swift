//
//  ModerationView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct ModerationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var users: [ModeratedUser] = []
    @State private var reports: [ForumReport] = []
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Табы
                Picker("", selection: $selectedTab) {
                    Text("Пользователи").tag(0)
                    Text("Жалобы").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Поиск
                if selectedTab == 0 {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Поиск по никнейму", text: $searchText)
                    }
                    .padding(12)
                    .background(Color(hex: "#F5F5F5"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Контент
                if selectedTab == 0 {
                    usersList
                } else {
                    reportsList
                }
            }
            .navigationTitle("Модерация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadMockData()
            }
        }
    }
    
    // MARK: - Users List
    private var usersList: some View {
        List {
            ForEach(filteredUsers) { user in
                UserRow(user: user) {
                    toggleBlockUser(user)
                }
            }
        }
    }
    
    // MARK: - Reports List
    private var reportsList: some View {
        List {
            ForEach(reports) { report in
                ReportRow(report: report) {
                    handleReport(report)
                }
            }
        }
    }
    
    private var filteredUsers: [ModeratedUser] {
        if searchText.isEmpty {
            return users
        }
        return users.filter { $0.nickname.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func loadMockData() {
        users = [
            ModeratedUser(id: "1", nickname: "Айдай", phone: "+996555123456", isBlocked: false),
            ModeratedUser(id: "2", nickname: "Бекжан", phone: "+996700987654", isBlocked: false),
            ModeratedUser(id: "3", nickname: "Спамер123", phone: "+996555000000", isBlocked: true)
        ]
        
        reports = [
            ForumReport(id: "1", postId: "post1", reporterNickname: "Айдай", reason: "Спам", createdAt: Date()),
            ForumReport(id: "2", postId: "post2", reporterNickname: "Бекжан", reason: "Неприемлемый контент", createdAt: Date().addingTimeInterval(-3600))
        ]
    }
    
    private func toggleBlockUser(_ user: ModeratedUser) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].isBlocked.toggle()
            // TODO: Update Firestore
            print("User \(user.nickname) blocked: \(users[index].isBlocked)")
        }
    }
    
    private func handleReport(_ report: ForumReport) {
        // TODO: Navigate to post or block user
        print("Handling report: \(report.id)")
    }
}

// MARK: - User Row
struct UserRow: View {
    let user: ModeratedUser
    let onToggleBlock: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: "#1B2A6B").opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(user.nickname.prefix(1).uppercased())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.nickname)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text(user.phone)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onToggleBlock) {
                Text(user.isBlocked ? "Разблокировать" : "Заблокировать")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(user.isBlocked ? .green : .red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(user.isBlocked ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .opacity(user.isBlocked ? 0.6 : 1.0)
    }
}

// MARK: - Report Row
struct ReportRow: View {
    let report: ForumReport
    let onHandle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Жалоба от: \(report.reporterNickname)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
                
                Text(report.timeAgo)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            Text(report.reason)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.primary)
            
            Button(action: onHandle) {
                Text("Проверить пост")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#E84E1B"))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Models
struct ModeratedUser: Identifiable {
    let id: String
    let nickname: String
    let phone: String
    var isBlocked: Bool
}

struct ForumReport: Identifiable {
    let id: String
    let postId: String
    let reporterNickname: String
    let reason: String
    let createdAt: Date
    
    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        let hours = Int(interval / 3600)
        if hours > 0 {
            return "\(hours) ч. назад"
        }
        return "недавно"
    }
}

#Preview {
    ModerationView()
}
