//
//  AskQuestionView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import PhotosUI

struct AskQuestionView: View {
    @ObservedObject var viewModel: SOSViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var questionText = ""
    @State private var selectedImageData: Data?
    @State private var selectedVideoURL: URL?
    @State private var selectedDocumentURL: URL?
    @State private var selectedDocumentName: String?
    @State private var isPosting = false
    @State private var showFilePicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Превью вложений
                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ФОТО ЗАДАНИЯ")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Button(action: {
                                    selectedImageData = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                        .background(Circle().fill(Color.white))
                                }
                                .padding(8)
                            }
                        }
                    } else {
                        // Кнопка добавления файла
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ФОТО ИЛИ ФАЙЛ")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showFilePicker = true
                            }) {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color(hex: "#E84E1B"))
                                    
                                    Text("Добавить фото или файл")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#E84E1B"))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(Color(hex: "#F5F5F5"))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Текст вопроса
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ОПИСАНИЕ (необязательно)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        TextField("Опишите ваш вопрос...", text: $questionText, axis: .vertical)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .padding(16)
                            .frame(minHeight: 100, alignment: .topLeading)
                            .background(Color.white)
                            .cornerRadius(12)
                            .lineLimit(5...10)
                    }
                    
                    // Инфо
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Вопрос пройдёт модерацию перед публикацией")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(20)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Задать вопрос")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: postQuestion) {
                        if isPosting {
                            ProgressView()
                        } else {
                            Text("ОТПРАВИТЬ")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                    }
                    .disabled(questionText.isEmpty && selectedImageData == nil || isPosting)
                }
            }
            .sheet(isPresented: $showFilePicker) {
                FilePickerSheet(
                    selectedImageData: $selectedImageData,
                    selectedVideoURL: $selectedVideoURL,
                    selectedDocumentURL: $selectedDocumentURL,
                    selectedDocumentName: $selectedDocumentName
                )
            }
        }
    }
    
    private func postQuestion() {
        isPosting = true
        
        Task {
            do {
                try await viewModel.postQuestion(
                    imageData: selectedImageData,
                    questionText: questionText,
                    authorNickname: "Вы",
                    videoURL: selectedVideoURL,
                    documentURL: selectedDocumentURL,
                    documentName: selectedDocumentName
                )
                dismiss()
            } catch {
                print("Error posting question: \(error)")
            }
            isPosting = false
        }
    }
}

// MARK: - File Picker Sheet
struct FilePickerSheet: View {
    @Binding var selectedImageData: Data?
    @Binding var selectedVideoURL: URL?
    @Binding var selectedDocumentURL: URL?
    @Binding var selectedDocumentName: String?
    @Environment(\.dismiss) private var dismiss
    
    @State private var showPhotoPicker = false
    @State private var showDocumentPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            List {
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
            }
            .navigationTitle("Выберите файл")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
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
                do {
                    let urls = try result.get()
                    guard let url = urls.first else { return }
                    
                    selectedDocumentURL = url
                    selectedDocumentName = url.lastPathComponent
                    selectedImageData = nil
                    selectedVideoURL = nil
                    dismiss()
                } catch {
                    print("Error selecting document: \(error)")
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        if UIImage(data: data) != nil {
                            selectedImageData = data
                            selectedVideoURL = nil
                            selectedDocumentURL = nil
                            selectedDocumentName = nil
                        }
                    }
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    AskQuestionView(viewModel: SOSViewModel())
}
