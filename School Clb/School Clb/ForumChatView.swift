//
//  ForumChatView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct ForumChatView: View {
    @ObservedObject var viewModel: SOSViewModel
    @State private var showAskQuestion = false
    @State private var selectedPost: ForumPost?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.forumPosts) { post in
                        ForumPostCard(post: post, viewModel: viewModel) {
                            selectedPost = post
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 80)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .refreshable {
                await viewModel.refresh()
            }
            
            // Кнопка задать вопрос
            Button(action: {
                showAskQuestion = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Задать вопрос")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(Color(hex: "#E84E1B"))
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            }
            .padding(20)
        }
        .sheet(isPresented: $showAskQuestion) {
            AskQuestionView(viewModel: viewModel)
        }
        .sheet(item: $selectedPost) { post in
            PostDetailView(postId: post.id, viewModel: viewModel) // ✅ Передаём только ID
        }
    }
}

// MARK: - Forum Post Card
struct ForumPostCard: View {
    let post: ForumPost
    @ObservedObject var viewModel: SOSViewModel
    let onTap: () -> Void
    @State private var showReportAlert = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Автор
                HStack(spacing: 12) {
                    // Аватар
                    Circle()
                        .fill(Color(hex: "#1B2A6B").opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(post.authorNickname.prefix(1).uppercased())
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.authorNickname)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                        
                        Text(post.timeAgo)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Кнопка жалобы
                    Button(action: {
                        showReportAlert = true
                    }) {
                        Image(systemName: "flag")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                }
                
                // Фото задания (если есть)
                if let imageData = post.questionImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else if let imageURL = post.questionImageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                    }
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Текст вопроса
                Text(post.questionText)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                
                // Статус модерации
                if !post.isModerated {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundColor(.orange)
                        Text("На модерации")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Divider()
                
                // Ответы
                HStack {
                    Image(systemName: "bubble.left.fill")
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    Text("\(post.answers.count) ответов")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    Spacer()
                    
                    if post.answers.count > 0 {
                        Text("Посмотреть →")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                    } else {
                        Text("Ответить →")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
        }
        .alert("Пожаловаться", isPresented: $showReportAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Пожаловаться", role: .destructive) {
                Task {
                    try? await viewModel.reportPost(post.id)
                }
            }
        } message: {
            Text("Вы действительно хотите пожаловаться на этот пост?")
        }
    }
}

// MARK: - Post Detail View
struct PostDetailView: View {
    let postId: String
    @ObservedObject var viewModel: SOSViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var answerText = ""
    @State private var isPosting = false
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    @State private var selectedImageData: Data?
    @State private var selectedVideoURL: URL?
    @State private var selectedDocumentURL: URL?
    @State private var selectedDocumentName: String?
    
    // ✅ Получаем актуальный пост из ViewModel
    private var post: ForumPost? {
        viewModel.forumPosts.first(where: { $0.id == postId })
    }
    
    var body: some View {
        NavigationStack {
            if let post = post {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Вопрос
                            VStack(alignment: .leading, spacing: 12) {
                                // Автор
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(hex: "#E84E1B").opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text(post.authorNickname.prefix(1).uppercased())
                                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "#E84E1B"))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(post.authorNickname)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(Color(hex: "#E84E1B"))
                                        
                                        Text(post.timeAgo)
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                // Фото (если есть)
                                if let imageData = post.questionImageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else if let imageURL = post.questionImageURL, let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 200)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                // Текст
                                Text(post.questionText)
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineSpacing(6)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            // Ответы
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ОТВЕТЫ (\(post.answers.count))")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.gray)
                                
                                ForEach(post.answers) { answer in
                                    AnswerBubble(answer: answer, postId: post.id, viewModel: viewModel)
                                }
                                
                                if post.answers.isEmpty {
                                    Text("Пока нет ответов. Будьте первым!")
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity)
                                        .padding(40)
                                }
                            }
                        }
                        .padding(20)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    
                    // Поле ввода ответа
                    ChatInputBar(
                        messageText: $answerText,
                        selectedImageData: $selectedImageData,
                        selectedVideoURL: $selectedVideoURL,
                        selectedDocumentURL: $selectedDocumentURL,
                        selectedDocumentName: $selectedDocumentName,
                        accentColor: Color(hex: "#E84E1B"),
                        placeholder: "Ваш ответ...",
                        isSending: isPosting,
                        onSend: postAnswer
                    )
                }
                .navigationTitle("Вопрос")
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
                }
                .onDisappear {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        tabBarVisibility.isHidden = false
                    }
                }
            } else {
                Text("Пост не найден")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func postAnswer() {
        guard !answerText.isEmpty || selectedImageData != nil || selectedVideoURL != nil || selectedDocumentURL != nil, let post = post else { return }
        
        isPosting = true
        let text = answerText
        let imageData = selectedImageData
        let videoURL = selectedVideoURL
        let documentURL = selectedDocumentURL
        let documentName = selectedDocumentName
        
        answerText = ""
        selectedImageData = nil
        selectedVideoURL = nil
        selectedDocumentURL = nil
        selectedDocumentName = nil
        
        Task {
            do {
                try await viewModel.postAnswer(
                    to: post.id,
                    text: text,
                    authorNickname: "Вы",
                    imageData: imageData,
                    videoURL: videoURL,
                    documentURL: documentURL,
                    documentName: documentName
                )
                hideKeyboard()
            } catch {
                print("Error posting answer: \(error)")
            }
            isPosting = false
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Answer Bubble
struct AnswerBubble: View {
    let answer: ForumAnswer
    let postId: String
    @ObservedObject var viewModel: SOSViewModel
    @State private var isLiked = false
    
    // Проверка, является ли это мой ответ
    private var isCurrentUser: Bool {
        answer.authorNickname == "Вы"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 8) {
                // Автор
                HStack(spacing: 8) {
                    if !isCurrentUser {
                        Circle()
                            .fill(Color(hex: "#E84E1B").opacity(0.2))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text(answer.authorNickname.prefix(1).uppercased())
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#E84E1B"))
                            )
                        
                        Text(answer.authorNickname)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                    }
                    
                    Spacer()
                    
                    // Лайки
                    Button(action: {
                        if !isLiked {
                            viewModel.likeAnswer(postId: postId, answerId: answer.id)
                            isLiked = true
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .gray)
                            Text("\(answer.likes)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Изображение (если есть)
                if let imageData = answer.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                // Текст ответа
                if !answer.text.isEmpty {
                    Text(answer.text)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(isCurrentUser ? .white : .primary)
                        .multilineTextAlignment(isCurrentUser ? .trailing : .leading)
                        .lineSpacing(4)
                        .padding(12)
                        .background(isCurrentUser ? Color(hex: "#E84E1B") : Color.white)
                        .cornerRadius(12)
                }
            }
            .frame(maxWidth: 280, alignment: isCurrentUser ? .trailing : .leading)
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
}

#Preview {
    ForumChatView(viewModel: SOSViewModel())
}
