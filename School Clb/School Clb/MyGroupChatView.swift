//
//  MyGroupChatView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import PhotosUI

struct MyGroupChatView: View {
    @ObservedObject var viewModel: SOSViewModel
    let group: StudentGroup
    @State private var messageText = ""
    @State private var isSending = false
    @State private var selectedImageData: Data?
    @State private var selectedVideoURL: URL?
    @State private var selectedDocumentURL: URL?
    @State private var selectedDocumentName: String?
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    // Computed property for messages
    private var messages: [GroupMessage] {
        viewModel.groupMessages[group.id] ?? []
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Сообщения
            ScrollViewReader { proxy in
                ScrollView {
                    messagesList
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .onChange(of: messages.count) { _, _ in
                    scrollToLastMessage(proxy: proxy)
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            
            // Поле ввода
            ChatInputBar(
                messageText: $messageText,
                selectedImageData: $selectedImageData,
                selectedVideoURL: $selectedVideoURL,
                selectedDocumentURL: $selectedDocumentURL,
                selectedDocumentName: $selectedDocumentName,
                accentColor: Color(hex: "#1B2A6B"),
                placeholder: "Сообщение...",
                isSending: isSending,
                onSend: sendMessage
            )
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2)) {
                tabBarVisibility.isHidden = true
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.2)) {
                tabBarVisibility.isHidden = false
            }
        }
    }
    
    // MARK: - Hide Keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // MARK: - Welcome Message
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#2196F3"))
            
            Text(group.name)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            if let description = group.description {
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Text("Общайтесь с вашей группой, делитесь новостями и помогайте друг другу!")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: - Messages List
    private var messagesList: some View {
        LazyVStack(spacing: 16) {
            // Приветствие
            if messages.isEmpty {
                welcomeMessage
            }
            
            // Сообщения
            ForEach(messages) { message in
                GroupMessageBubble(message: message)
                    .id(message.id)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .padding(.bottom, 20)
    }
    
    // MARK: - Scroll Helper
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let lastMessage = messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    // MARK: - Send Message
    private func sendMessage() {
        guard !messageText.isEmpty || selectedImageData != nil || selectedVideoURL != nil || selectedDocumentURL != nil else { return }
        
        isSending = true
        let text = messageText
        let imageData = selectedImageData
        let videoURL = selectedVideoURL
        let documentURL = selectedDocumentURL
        let documentName = selectedDocumentName
        
        messageText = ""
        selectedImageData = nil
        selectedVideoURL = nil
        selectedDocumentURL = nil
        selectedDocumentName = nil
        
        Task {
            do {
                try await viewModel.sendGroupMessage(
                    groupID: group.id,
                    text: text,
                    imageData: imageData,
                    videoURL: videoURL,
                    documentURL: documentURL,
                    documentName: documentName
                )
            } catch {
                print("Error sending message: \(error)")
            }
            isSending = false
        }
    }
}

// MARK: - Group Message Bubble
struct GroupMessageBubble: View {
    let message: GroupMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isCurrentUser {
                Spacer()
            }
            
            // Аватар (только для чужих)
            if !message.isCurrentUser {
                Circle()
                    .fill(Color(hex: "#1B2A6B").opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(message.authorNickname.prefix(1).uppercased())
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                    )
            }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Имя автора (если не текущий пользователь)
                if !message.isCurrentUser {
                    Text(message.authorNickname)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                }
                
                // Изображение (если есть)
                if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Текст сообщения (если есть)
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(message.isCurrentUser ? Color.white : Color.primary)
                        .multilineTextAlignment(message.isCurrentUser ? .trailing : .leading)
                        .padding(12)
                        .background(
                            message.isCurrentUser
                            ? Color(hex: "#1B2A6B")
                            : Color(uiColor: .systemBackground)
                        )
                        .cornerRadius(16)
                }
                
                // Время
                Text(message.timeAgo)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 280, alignment: message.isCurrentUser ? .trailing : .leading)
            
            if !message.isCurrentUser {
                Spacer()
            }
        }
    }
}

// MARK: - Group Message Model
struct GroupMessage: Identifiable {
    let id: String
    let text: String
    let authorNickname: String
    let authorUID: String
    let timestamp: Date
    let isCurrentUser: Bool
    let imageData: Data?
    let videoURL: URL?
    let documentURL: URL?
    let documentName: String?
    
    var timeAgo: String {
        timestamp.relativeRu()
    }
}

#Preview {
    NavigationStack {
        MyGroupChatView(
            viewModel: SOSViewModel(),
            group: StudentGroup(
                id: "1",
                name: "Ортголики",
                description: "Группа студентов School Club",
                membersCount: 25,
                unreadCount: 30,
                lastMessage: "Привет всем!",
                lastMessageTime: Date()
            )
        )
        .environmentObject(TabBarVisibility()) // ✅ Добавлен для Preview
    }
}
