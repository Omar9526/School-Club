//
//  UploadLessonView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct UploadLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCourse: String = ""
    @State private var selectedLevel: String = ""
    @State private var titleKG = ""
    @State private var titleRU = ""
    @State private var descriptionKG = ""
    @State private var descriptionRU = ""
    @State private var isFree = false
    @State private var selectedVideoURL: URL?
    @State private var isUploading = false
    @State private var showVideoPicker = false
    
    let courses = ["ЖРТ кыргыз тилинде", "ОРТ на русском", "ХИМБИО кыргыз", "ХИМБИО русском"]
    let levels = ["А деңгээли", "В деңгээли", "С деңгээли"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("КУРС И УРОВЕНЬ") {
                    Picker("Курс", selection: $selectedCourse) {
                        Text("Выберите курс").tag("")
                        ForEach(courses, id: \.self) { course in
                            Text(course).tag(course)
                        }
                    }
                    
                    Picker("Уровень", selection: $selectedLevel) {
                        Text("Выберите уровень").tag("")
                        ForEach(levels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .disabled(selectedCourse.isEmpty)
                }
                
                Section("НАЗВАНИЕ УРОКА") {
                    TextField("Название (кыргызча)", text: $titleKG)
                    TextField("Название (русский)", text: $titleRU)
                }
                
                Section("ВИДЕО") {
                    if let videoURL = selectedVideoURL {
                        HStack {
                            Image(systemName: "video.fill")
                                .foregroundColor(Color(hex: "#1B2A6B"))
                            Text(videoURL.lastPathComponent)
                                .font(.system(size: 14, design: .rounded))
                                .lineLimit(1)
                            Spacer()
                            Button("Удалить") {
                                selectedVideoURL = nil
                            }
                            .foregroundColor(.red)
                        }
                    } else {
                        Button(action: { showVideoPicker = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Выбрать видео")
                            }
                        }
                    }
                }
                
                Section("ОПИСАНИЕ") {
                    TextField("Описание (кыргызча)", text: $descriptionKG, axis: .vertical)
                        .lineLimit(3...6)
                    
                    TextField("Описание (русский)", text: $descriptionRU, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("ДОСТУП") {
                    Toggle("Бесплатный урок", isOn: $isFree)
                }
            }
            .navigationTitle("Загрузить урок")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        saveLesson()
                    }
                    .disabled(!canSave || isUploading)
                }
            }
            .fileImporter(
                isPresented: $showVideoPicker,
                allowedContentTypes: [.movie, .video],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedVideoURL = url
                    }
                case .failure(let error):
                    print("Video picker error: \(error)")
                }
            }
        }
    }
    
    private var canSave: Bool {
        !selectedCourse.isEmpty && !selectedLevel.isEmpty &&
        !titleKG.isEmpty && !titleRU.isEmpty &&
        selectedVideoURL != nil
    }
    
    private func saveLesson() {
        isUploading = true
        
        Task {
            // TODO: Upload video to Firebase Storage
            // TODO: Save lesson data to Firestore
            
            try? await Task.sleep(for: .seconds(2))
            
            print("Lesson saved: \(titleKG)")
            
            isUploading = false
            dismiss()
        }
    }
}

#Preview {
    UploadLessonView()
}
