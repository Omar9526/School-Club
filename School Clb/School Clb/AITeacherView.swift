//
//  AITeacherView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import PhotosUI
import Combine

struct AITeacherView: View {
    @ObservedObject var viewModel: SOSViewModel
    @State private var messageText = ""
    @State private var isSending = false
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @State private var selectedImageData: Data?
    @State private var selectedVideoURL: URL?
    @State private var selectedDocumentURL: URL?
    @State private var selectedDocumentName: String?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if viewModel.aiMessages.isEmpty {
                            welcomeMessage
                        }
                        ForEach(viewModel.aiMessages) { message in
                            AIMessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .onChange(of: viewModel.aiMessages.count) { _, _ in
                    if let lastMessage = viewModel.aiMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }

            ChatInputBar(
                messageText: $messageText,
                selectedImageData: $selectedImageData,
                selectedVideoURL: $selectedVideoURL,
                selectedDocumentURL: $selectedDocumentURL,
                selectedDocumentName: $selectedDocumentName,
                accentColor: Color(hex: "#9C27B0"),
                placeholder: "Задайте вопрос...",
                isSending: isSending,
                onSend: sendMessage
            )
        }
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
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#9C27B0"))
            
            Text("ИИ Преподаватель")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#9C27B0"))
            
            Text("Задайте вопрос и я помогу с решением!")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
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
        hideKeyboard()
        
        Task {
            do {
                _ = try await viewModel.sendMessageToAI(
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

// MARK: - AI Message Bubble
struct AIMessageBubble: View {
    let message: AIMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isUser {
                Spacer()
            }
            
            // Иконка ИИ (только для чужих)
            if !message.isUser {
                Circle()
                    .fill(Color(hex: "#9C27B0").opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "#9C27B0"))
                    )
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                // Фото (если есть)
                if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Текст
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(message.isUser ? .white : .primary)
                        .multilineTextAlignment(message.isUser ? .trailing : .leading)
                        .padding(12)
                        .background(message.isUser ? Color(hex: "#9C27B0") : Color(uiColor: .systemBackground))
                        .cornerRadius(16)
                }
                
                // Время
                Text(message.timeAgo)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

#Preview {
    AITeacherView(viewModel: SOSViewModel())
        .environmentObject(TabBarVisibility()) // ✅ Добавлен для Preview
}
