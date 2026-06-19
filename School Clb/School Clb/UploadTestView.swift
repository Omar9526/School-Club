//
//  UploadTestView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import PhotosUI

struct UploadTestView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCourse = ""
    @State private var selectedLevel = ""
    @State private var selectedLesson = ""
    @State private var questions: [TestQuestion] = []
    @State private var showAddQuestion = false
    @State private var isUploading = false
    
    let courses = ["ЖРТ кыргыз тилинде", "ОРТ на русском", "ХИМБИО кыргыз", "ХИМБИО русском"]
    let levels = ["А деңгээли", "В деңгээли", "С деңгээли"]
    let lessons = ["Сабак 1", "Сабак 2", "Сабак 3"] // TODO: Load from Firestore
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Селекторы
                Form {
                    Section("ВЫБОР УРОКА") {
                        Picker("Курс", selection: $selectedCourse) {
                            Text("Выберите курс").tag("")
                            ForEach(courses, id: \.self) { Text($0).tag($0) }
                        }
                        
                        Picker("Уровень", selection: $selectedLevel) {
                            Text("Выберите уровень").tag("")
                            ForEach(levels, id: \.self) { Text($0).tag($0) }
                        }
                        .disabled(selectedCourse.isEmpty)
                        
                        Picker("Урок", selection: $selectedLesson) {
                            Text("Выберите урок").tag("")
                            ForEach(lessons, id: \.self) { Text($0).tag($0) }
                        }
                        .disabled(selectedLevel.isEmpty)
                    }
                }
                .frame(height: 250)
                
                // Список вопросов
                if !questions.isEmpty {
                    List {
                        ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                            QuestionRow(question: question, number: index + 1)
                        }
                        .onDelete(perform: deleteQuestions)
                    }
                }
                
                Spacer()
                
                // Кнопки
                VStack(spacing: 12) {
                    Button(action: { showAddQuestion = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Добавить вопрос")
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#1B2A6B"))
                        .cornerRadius(12)
                    }
                    .disabled(selectedLesson.isEmpty)
                    
                    if !questions.isEmpty {
                        Button(action: saveTest) {
                            if isUploading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Сохранить все (\(questions.count))")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hex: "#E84E1B"))
                        .cornerRadius(12)
                        .disabled(isUploading)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Загрузить тест")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddQuestion) {
                AddQuestionView { question in
                    questions.append(question)
                }
            }
        }
    }
    
    private func deleteQuestions(at offsets: IndexSet) {
        questions.remove(atOffsets: offsets)
    }
    
    private func saveTest() {
        isUploading = true
        
        Task {
            // TODO: Batch write to Firestore
            for (index, question) in questions.enumerated() {
                print("Saving question \(index + 1): \(question.questionText)")
            }
            
            try? await Task.sleep(for: .seconds(2))
            
            isUploading = false
            dismiss()
        }
    }
}

// MARK: - Question Row
struct QuestionRow: View {
    let question: TestQuestion
    let number: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Вопрос \(number)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
                
                Text("✓ \(question.correctAnswer)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
            }
            
            if question.type == .image {
                Text("📷 Вопрос-изображение")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.gray)
            } else {
                Text(question.questionText)
                    .font(.system(size: 13, design: .rounded))
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Question View
struct AddQuestionView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (TestQuestion) -> Void
    
    @State private var questionType: QuestionType = .text
    @State private var questionText = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var optionA = ""
    @State private var optionB = ""
    @State private var optionC = ""
    @State private var optionD = ""
    @State private var correctAnswer = "A"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("ТИП ВОПРОСА") {
                    Picker("Тип", selection: $questionType) {
                        Text("Текст").tag(QuestionType.text)
                        Text("Изображение").tag(QuestionType.image)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("ВОПРОС") {
                    if questionType == .text {
                        TextField("Текст вопроса", text: $questionText, axis: .vertical)
                            .lineLimit(3...6)
                    } else {
                        if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                        }
                        
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                Text("Выбрать фото")
                            }
                        }
                        .onChange(of: selectedPhoto) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                }
                
                Section("ВАРИАНТЫ ОТВЕТА") {
                    TextField("А)", text: $optionA)
                    TextField("Б)", text: $optionB)
                    TextField("В)", text: $optionC)
                    TextField("Г)", text: $optionD)
                }
                
                Section("ПРАВИЛЬНЫЙ ОТВЕТ") {
                    Picker("Правильный", selection: $correctAnswer) {
                        Text("А").tag("A")
                        Text("Б").tag("B")
                        Text("В").tag("C")
                        Text("Г").tag("D")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Добавить вопрос")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Добавить") {
                        saveQuestion()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var canSave: Bool {
        let hasQuestion = questionType == .text ? !questionText.isEmpty : selectedImageData != nil
        return hasQuestion && !optionA.isEmpty && !optionB.isEmpty && !optionC.isEmpty && !optionD.isEmpty
    }
    
    private func saveQuestion() {
        let question = TestQuestion(
            id: UUID().uuidString,
            type: questionType,
            questionText: questionType == .text ? questionText : "",
            questionImageData: questionType == .image ? selectedImageData : nil,
            optionA: optionA,
            optionB: optionB,
            optionC: optionC,
            optionD: optionD,
            correctAnswer: correctAnswer
        )
        
        onSave(question)
        dismiss()
    }
}

// MARK: - Test Question Model
struct TestQuestion: Identifiable {
    let id: String
    let type: QuestionType
    let questionText: String
    let questionImageData: Data?
    let optionA: String
    let optionB: String
    let optionC: String
    let optionD: String
    let correctAnswer: String
}

#Preview {
    UploadTestView()
}
