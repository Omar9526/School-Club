//
//  PrivateChatsView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import PhotosUI
import Combine

struct PrivateChatsView: View {
    @ObservedObject var viewModel: SOSViewModel
    @State private var searchText = ""
    @State private var selectedChat: PrivateChat?
    
    var filteredChats: [PrivateChat] {
        if searchText.isEmpty {
            return viewModel.privateChats
        }
        return viewModel.privateChats.filter {
            $0.participantName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Поиск
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Поиск чатов...", text: $searchText)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .systemGroupedBackground))
            
            if filteredChats.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredChats) { chat in
                            Button(action: {
                                selectedChat = chat
                            }) {
                                PrivateChatRow(chat: chat)
                            }
                            
                            if chat.id != filteredChats.last?.id {
                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                }
                .background(Color(uiColor: .systemBackground))
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Личные чаты")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedChat) { chat in
            PrivateChatDetailView(chat: chat, viewModel: viewModel)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#34C759"))
            
            Text("Нет чатов")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(searchText.isEmpty
                 ? "Начните общение с друзьями и учителями"
                 : "Чаты не найдены"
            )
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Private Chat Row
struct PrivateChatRow: View {
    @ObservedObject var chat: PrivateChat
    
    var body: some View {
        HStack(spacing: 12) {
            // Аватар
            Circle()
                .fill(Color(hex: "#34C759").opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay(
                    Text(chat.participantName.prefix(1).uppercased())
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#34C759"))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.participantName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if chat.isTeacher {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#2196F3"))
                    }
                }
                
                Text(chat.lastMessage)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(chat.timeAgo)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                
                if chat.unreadCount > 0 {
                    Text("\(chat.unreadCount)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color(hex: "#34C759"))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemBackground))
    }
}

// MARK: - Private Chat Detail View
struct PrivateChatDetailView: View {
    @ObservedObject var chat: PrivateChat
    @ObservedObject var viewModel: SOSViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var isSending = false
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @State private var selectedImageData: Data?
    @State private var selectedVideoURL: URL?
    @State private var selectedDocumentURL: URL?
    @State private var selectedDocumentName: String?
    
    // Вычисляемое свойство для получения актуальных сообщений из viewModel
    private var currentMessages: [PrivateMessage] {
        viewModel.privateChats.first(where: { $0.id == chat.id })?.messages ?? []
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Сообщения
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(currentMessages) { message in
                                PrivateMessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .padding(.bottom, 20)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    .onChange(of: currentMessages.count) { _, _ in
                        if let lastMessage = currentMessages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Поле ввода
                ChatInputBar(
                    messageText: $messageText,
                    selectedImageData: $selectedImageData,
                    selectedVideoURL: $selectedVideoURL,
                    selectedDocumentURL: $selectedDocumentURL,
                    selectedDocumentName: $selectedDocumentName,
                    accentColor: Color(hex: "#34C759"),
                    placeholder: "Сообщение...",
                    isSending: isSending,
                    onSend: sendMessage
                )
            }
            .navigationTitle(chat.participantName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.2)) {
                    tabBarVisibility.isHidden = true
                }
                viewModel.markPrivateChatAsRead(chat.id)
            }
            .onDisappear {
                withAnimation(.easeInOut(duration: 0.2)) {
                    tabBarVisibility.isHidden = false
                }
            }
        }
    }
    
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
                try await viewModel.sendPrivateMessage(
                    chatID: chat.id,
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

// MARK: - Private Message Bubble
struct PrivateMessageBubble: View {
    let message: PrivateMessage
    
    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Изображение (если есть)
                if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .cornerRadius(12)
                }
                
                // Текст сообщения
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(message.isCurrentUser ? Color.white : Color.primary) // ✅ Явный белый цвет
                        .multilineTextAlignment(message.isCurrentUser ? .trailing : .leading)
                        .padding(12)
                        .background(
                            message.isCurrentUser
                            ? Color(hex: "#34C759")
                            : Color(uiColor: .systemBackground)
                        )
                        .cornerRadius(16)
                }
                
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

// MARK: - Private Chat Model
class PrivateChat: Identifiable, ObservableObject {
    let id: String
    let participantName: String
    let participantUID: String
    let lastMessage: String
    let lastMessageTime: Date
    @Published var unreadCount: Int  // ✅ @Published для реактивности
    let isTeacher: Bool
    var messages: [PrivateMessage]
    
    init(id: String, participantName: String, participantUID: String, lastMessage: String, lastMessageTime: Date, unreadCount: Int, isTeacher: Bool, messages: [PrivateMessage]) {
        self.id = id
        self.participantName = participantName
        self.participantUID = participantUID
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.unreadCount = unreadCount
        self.isTeacher = isTeacher
        self.messages = messages
    }
    
    var timeAgo: String {
        lastMessageTime.relativeRu()
    }
}

// MARK: - Private Message Model
struct PrivateMessage: Identifiable {
    let id: String
    let text: String
    let senderUID: String
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
        PrivateChatsView(viewModel: SOSViewModel())
    }
}
