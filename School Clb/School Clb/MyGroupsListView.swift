//
//  MyGroupsListView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct MyGroupsListView: View {
    @ObservedObject var viewModel: SOSViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.myGroups) { group in
                    NavigationLink(destination: MyGroupChatView(viewModel: viewModel, group: group)) {
                        GroupCard(group: group)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 80)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Мои группы")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Group Card
struct GroupCard: View {
    let group: StudentGroup
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка группы
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
                    .frame(width: 60, height: 60)
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color(hex: "#2196F3"))
                
                // Badge с количеством новых
                if group.unreadCount > 0 {
                    Text("\(group.unreadCount)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .offset(x: 20, y: -20)
                }
            }
            
            // Информация о группе
            VStack(alignment: .leading, spacing: 6) {
                Text(group.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                if let lastMessage = group.lastMessage {
                    Text(lastMessage)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("Нет сообщений")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    Text("\(group.membersCount) участников")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
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
    }
}

// MARK: - Student Group Model
struct StudentGroup: Identifiable {
    let id: String
    let name: String
    let description: String?
    let membersCount: Int
    let unreadCount: Int
    let lastMessage: String?
    let lastMessageTime: Date?
}

#Preview {
    NavigationStack {
        MyGroupsListView(viewModel: SOSViewModel())
    }
}
