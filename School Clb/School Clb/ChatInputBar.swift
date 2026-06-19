//
//  ChatInputBar.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Chat Input Bar
struct ChatInputBar: View {
    @Binding var messageText: String
    @Binding var selectedImageData: Data?
    @Binding var selectedVideoURL: URL?
    @Binding var selectedDocumentURL: URL?
    @Binding var selectedDocumentName: String?
    let accentColor: Color
    let placeholder: String
    let isSending: Bool
    let onSend: () -> Void
    
    @State private var showPhotoPicker = false
    @State private var showDocumentPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 0) {
            // Превью вложений
            if selectedImageData != nil || selectedVideoURL != nil || selectedDocumentURL != nil {
                attachmentPreview
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
            }
            
            HStack(spacing: 12) {
                // Кнопка прикрепления с меню
                Menu {
                    Button(action: {
                        showPhotoPicker = true
                    }) {
                        Label("Фото или видео", systemImage: "photo.on.rectangle")
                    }
                    
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        Label("Документ", systemImage: "doc")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(accentColor)
                }
                
                TextField(placeholder, text: $messageText, axis: .vertical)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                    .tint(accentColor)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(20)
                    .lineLimit(1...4)
                    .frame(minHeight: 44)
                
                Button(action: onSend) {
                    if isSending {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(canSend ? accentColor : .gray)
                    }
                }
                .disabled(!canSend || isSending)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(Color(uiColor: .systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -2)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhoto,
            matching: .any(of: [.images, .videos]),
            photoLibrary: .shared()
        )
        .fileImporter(
            isPresented: $showDocumentPicker,
            allowedContentTypes: [.pdf, .plainText, .png, .jpeg],
            allowsMultipleSelection: false
        ) { result in
            handleDocumentSelection(result)
        }
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    if UIImage(data: data) != nil {
                        selectedImageData = data
                        selectedVideoURL = nil
                        selectedDocumentURL = nil
                        selectedDocumentName = nil
                    } else {
                        selectedVideoURL = nil
                        selectedImageData = data
                        selectedDocumentURL = nil
                        selectedDocumentName = nil
                    }
                }
            }
        }
    }
    
    private var canSend: Bool {
        !messageText.isEmpty || selectedImageData != nil || selectedVideoURL != nil || selectedDocumentURL != nil
    }
    
    // MARK: - Attachment Preview
    private var attachmentPreview: some View {
        HStack {
            if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if selectedVideoURL != nil {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(accentColor)
                    Text("Видео")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if let documentName = selectedDocumentName {
                HStack(spacing: 8) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 24))
                        .foregroundColor(accentColor)
                    Text(documentName)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .lineLimit(1)
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color(uiColor: .tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Spacer()
            
            Button(action: clearAttachments) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 24))
            }
        }
        .padding(8)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(8)
    }
    
    private func clearAttachments() {
        selectedImageData = nil
        selectedVideoURL = nil
        selectedDocumentURL = nil
        selectedDocumentName = nil
    }
    
    private func handleDocumentSelection(_ result: Result<[URL], Error>) {
        do {
            let urls = try result.get()
            guard let url = urls.first else { return }
            
            selectedDocumentURL = url
            selectedDocumentName = url.lastPathComponent
            selectedImageData = nil
            selectedVideoURL = nil
        } catch {
            print("Error selecting document: \(error)")
        }
    }
}

// MARK: - Chat Attachment Model
struct ChatAttachment {
    let imageData: Data?
    let videoURL: URL?
    let documentURL: URL?
    let documentName: String?
}

// MARK: - Message Bubble with Attachment
struct MessageBubbleContent: View {
    let text: String
    let attachment: ChatAttachment?
    let accentColor: Color
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 8) {
            // Изображение
            if let imageData = attachment?.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 250)
                    .cornerRadius(12)
            }
            
            // Видео превью
            if attachment?.videoURL != nil {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 200, height: 150)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                }
            }
            
            // Документ
            if let documentName = attachment?.documentName {
                HStack(spacing: 8) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isCurrentUser ? .white : accentColor)
                    
                    Text(documentName)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(isCurrentUser ? .white : .primary)
                        .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: 250, alignment: .leading)
                .background(
                    isCurrentUser
                    ? accentColor.opacity(0.8)
                    : Color(uiColor: .tertiarySystemBackground)
                )
                .cornerRadius(12)
            }
            
            // Текст сообщения
            if !text.isEmpty {
                Text(text)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(isCurrentUser ? Color.white : Color.primary)
                    .multilineTextAlignment(isCurrentUser ? .trailing : .leading)
                    .padding(12)
                    .background(
                        isCurrentUser
                        ? accentColor
                        : Color(uiColor: .systemBackground)
                    )
                    .cornerRadius(16)
            }
        }
        .frame(maxWidth: 280, alignment: isCurrentUser ? .trailing : .leading)
    }
}
