//
//  TestView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct TestView: View {
    let lesson: Lesson
    @ObservedObject var viewModel: LessonsViewModel
    let hasVideoAnalysis: Bool
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var isAnswerChecked = false
    @State private var correctAnswers = 0
    @State private var showResults = false
    @State private var userAnswers: [String] = []
    @Environment(\.dismiss) private var dismiss
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < viewModel.questions.count else { return nil }
        return viewModel.questions[currentQuestionIndex]
    }
    
    var progress: Double {
        Double(currentQuestionIndex + 1) / Double(viewModel.questions.count)
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F5F5").ignoresSafeArea()
            
            if showResults {
                // Результаты теста
                TestResultsView(
                    correctAnswers: correctAnswers,
                    totalQuestions: viewModel.questions.count,
                    hasVideoAnalysis: hasVideoAnalysis,
                    lesson: lesson,
                    onDismiss: { dismiss() }
                )
            } else if let question = currentQuestion {
                VStack(spacing: 0) {
                    // Прогресс-бар
                    VStack(spacing: 8) {
                        HStack {
                            Text("Вопрос \(currentQuestionIndex + 1) из \(viewModel.questions.count)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                Rectangle()
                                    .fill(Color(hex: "#1B2A6B"))
                                    .frame(width: geometry.size.width * progress, height: 8)
                                    .cornerRadius(4)
                                    .animation(.easeInOut, value: progress)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(20)
                    .background(Color.white)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            // Вопрос
                            if question.type == .image {
                                // Вопрос-картинка (для математики/химии/биологии)
                                if let imageURL = question.questionImageURL, let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 200)
                                            .overlay(
                                                ProgressView()
                                            )
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            } else {
                                // Текстовый вопрос
                                Text(question.questionText ?? "")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(hex: "#1B2A6B"))
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(20)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            
                            // Варианты ответов
                            VStack(spacing: 8) {
                                AnswerButton(
                                    letter: "А",
                                    text: question.optionA,
                                    isSelected: selectedAnswer == "A",
                                    isCorrect: isAnswerChecked && question.correctAnswer == "A",
                                    isWrong: isAnswerChecked && selectedAnswer == "A" && question.correctAnswer != "A",
                                    showCorrectAnswer: !hasVideoAnalysis,
                                    action: { selectAnswer("A") }
                                )
                                
                                AnswerButton(
                                    letter: "Б",
                                    text: question.optionB,
                                    isSelected: selectedAnswer == "B",
                                    isCorrect: isAnswerChecked && question.correctAnswer == "B",
                                    isWrong: isAnswerChecked && selectedAnswer == "B" && question.correctAnswer != "B",
                                    showCorrectAnswer: !hasVideoAnalysis,
                                    action: { selectAnswer("B") }
                                )
                                
                                AnswerButton(
                                    letter: "В",
                                    text: question.optionC,
                                    isSelected: selectedAnswer == "C",
                                    isCorrect: isAnswerChecked && question.correctAnswer == "C",
                                    isWrong: isAnswerChecked && selectedAnswer == "C" && question.correctAnswer != "C",
                                    showCorrectAnswer: !hasVideoAnalysis,
                                    action: { selectAnswer("C") }
                                )
                                
                                AnswerButton(
                                    letter: "Г",
                                    text: question.optionD,
                                    isSelected: selectedAnswer == "D",
                                    isCorrect: isAnswerChecked && question.correctAnswer == "D",
                                    isWrong: isAnswerChecked && selectedAnswer == "D" && question.correctAnswer != "D",
                                    showCorrectAnswer: !hasVideoAnalysis,
                                    action: { selectAnswer("D") }
                                )
                            }
                            
                            // Кнопка проверки/следующий вопрос
                            if isAnswerChecked {
                                Button(action: nextQuestion) {
                                    Text(currentQuestionIndex < viewModel.questions.count - 1 ? "Следующий вопрос" : "Завершить тест")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color(hex: "#1B2A6B"))
                                        .cornerRadius(12)
                                }
                            } else {
                                Button(action: checkAnswer) {
                                    Text("Проверить")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(selectedAnswer != nil ? Color(hex: "#1B2A6B") : Color.gray)
                                        .cornerRadius(12)
                                }
                                .disabled(selectedAnswer == nil)
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(lesson.title)
        .onAppear {
            viewModel.loadQuestions(for: lesson)
        }
    }
    
    // MARK: - Actions
    private func selectAnswer(_ answer: String) {
        guard !isAnswerChecked else { return }
        selectedAnswer = answer
    }
    
    private func checkAnswer() {
        guard let selected = selectedAnswer, let question = currentQuestion else { return }
        
        isAnswerChecked = true
        userAnswers.append(selected)
        
        if selected == question.correctAnswer {
            correctAnswers += 1
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < viewModel.questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            isAnswerChecked = false
        } else {
            // Сохраняем прогресс
            viewModel.saveProgress(lessonId: lesson.id, score: correctAnswers, totalQuestions: viewModel.questions.count)
            showResults = true
        }
    }
}

// MARK: - Answer Button
struct AnswerButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let showCorrectAnswer: Bool  // ✅ Новый параметр
    let action: () -> Void
    
    var backgroundColor: Color {
        if showCorrectAnswer && isCorrect {
            return Color.green.opacity(0.1)
        } else if isWrong {
            return Color.red.opacity(0.1)
        } else if isSelected {
            return Color(hex: "#1B2A6B").opacity(0.05)
        } else {
            return Color.white
        }
    }
    
    var borderColor: Color {
        if showCorrectAnswer && isCorrect {
            return Color.green
        } else if isWrong {
            return Color.red
        } else if isSelected {
            return Color(hex: "#1B2A6B")
        } else {
            return Color(hex: "#1B2A6B").opacity(0.2)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Буква варианта
                Text(letter)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor((showCorrectAnswer && isCorrect) ? .white : (isWrong ? .white : .white))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill((showCorrectAnswer && isCorrect) ? Color.green : (isWrong ? Color.red : Color(hex: "#1B2A6B")))
                    )
                
                // Текст ответа
                Text(text)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Иконка результата
                if showCorrectAnswer && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                }
            }
            .padding(10)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .disabled((showCorrectAnswer && isCorrect) || isWrong)
    }
}

// MARK: - Test Results View
struct TestResultsView: View {
    let correctAnswers: Int
    let totalQuestions: Int
    let hasVideoAnalysis: Bool
    let lesson: Lesson
    let onDismiss: () -> Void
    
    var percentage: Int {
        Int((Double(correctAnswers) / Double(totalQuestions)) * 100)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Результат
                VStack(spacing: 16) {
                    Image(systemName: percentage >= 70 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(percentage >= 70 ? .green : Color(hex: "#E84E1B"))
                    
                    Text("\(percentage)%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    Text("\(correctAnswers) из \(totalQuestions) правильных")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    if percentage >= 70 {
                        Text("Отличный результат! 🎉")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.green)
                    } else {
                        Text("Нужно больше практики")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                    }
                }
                .padding(32)
                .background(Color.white)
                .cornerRadius(16)
                
                // Видеоразбор (если есть)
                if hasVideoAnalysis, let _ = lesson.videoAnalysisURL {
                    NavigationLink(destination: VideoLessonView(lesson: lesson, isTheory: false)) {
                        HStack(spacing: 16) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "#E84E1B"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Видеоразбор теста")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#1B2A6B"))
                                
                                Text("Разберите свои ошибки")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding(16)
                        .background(Color(hex: "#E84E1B").opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                // Кнопка завершения
                Button(action: onDismiss) {
                    Text("Завершить")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#1B2A6B"))
                        .cornerRadius(12)
                }
            }
            .padding(20)
        }
        .background(Color(hex: "#F5F5F5"))
    }
}

#Preview {
    NavigationStack {
        TestView(
            lesson: Lesson(
                id: "1",
                levelId: "1",
                title: "Сабак 1",
                order: 1,
                isFree: true,
                isPracticeTest: false,
                videoURL: "https://example.com/video.mp4",
                videoAnalysisURL: "https://example.com/analysis.mp4",
                description: "Test",
                subject: .text
            ),
            viewModel: LessonsViewModel(),
            hasVideoAnalysis: true
        )
    }
}
