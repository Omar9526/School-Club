//
//  PracticeTestView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct PracticeTestView: View {
    let lesson: Lesson
    @ObservedObject var viewModel: LessonsViewModel
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var isAnswerChecked = false
    @State private var correctAnswers = 0
    @State private var showResults = false
    @State private var userAnswers: [(questionId: String, userAnswer: String, correctAnswer: String)] = []
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
                // Детальные результаты с разбором
                PracticeTestResultsView(
                    correctAnswers: correctAnswers,
                    totalQuestions: viewModel.questions.count,
                    questions: viewModel.questions,
                    userAnswers: userAnswers,
                    lesson: lesson,
                    onDismiss: { dismiss() }
                )
            } else if let question = currentQuestion {
                VStack(spacing: 0) {
                    // Шапка с прогрессом
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "#FFE600"))
                            
                            Text("СЫНАМЫК ТЕСТ")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                            
                            Spacer()
                        }
                        
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
                                    .fill(Color(hex: "#FFE600"))
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
                                if let imageURL = question.questionImageURL, let url = URL(string: imageURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 200)
                                            .overlay(ProgressView())
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            } else {
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
                            VStack(spacing: 12) {
                                AnswerButton(
                                    letter: "А",
                                    text: question.optionA,
                                    isSelected: selectedAnswer == "A",
                                    isCorrect: isAnswerChecked && question.correctAnswer == "A",
                                    isWrong: isAnswerChecked && selectedAnswer == "A" && question.correctAnswer != "A",
                                    action: { selectAnswer("A") }
                                )
                                
                                AnswerButton(
                                    letter: "Б",
                                    text: question.optionB,
                                    isSelected: selectedAnswer == "B",
                                    isCorrect: isAnswerChecked && question.correctAnswer == "B",
                                    isWrong: isAnswerChecked && selectedAnswer == "B" && question.correctAnswer != "B",
                                    action: { selectAnswer("B") }
                                )
                                
                                AnswerButton(
                                    letter: "В",
                                    text: question.optionC,
                                    isSelected: selectedAnswer == "C",
                                    isCorrect: isAnswerChecked && question.correctAnswer == "C",
                                    isWrong: isAnswerChecked && selectedAnswer == "C" && question.correctAnswer != "C",
                                    action: { selectAnswer("C") }
                                )
                                
                                AnswerButton(
                                    letter: "Г",
                                    text: question.optionD,
                                    isSelected: selectedAnswer == "D",
                                    isCorrect: isAnswerChecked && question.correctAnswer == "D",
                                    isWrong: isAnswerChecked && selectedAnswer == "D" && question.correctAnswer != "D",
                                    action: { selectAnswer("D") }
                                )
                            }
                            
                            // Кнопка
                            if isAnswerChecked {
                                Button(action: nextQuestion) {
                                    Text(currentQuestionIndex < viewModel.questions.count - 1 ? "Следующий вопрос" : "Показать результаты")
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
                                        .background(selectedAnswer != nil ? Color(hex: "#FFE600") : Color.gray)
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
        userAnswers.append((questionId: question.id, userAnswer: selected, correctAnswer: question.correctAnswer))
        
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
            showResults = true
        }
    }
}

// MARK: - Practice Test Results View
struct PracticeTestResultsView: View {
    let correctAnswers: Int
    let totalQuestions: Int
    let questions: [Question]
    let userAnswers: [(questionId: String, userAnswer: String, correctAnswer: String)]
    let lesson: Lesson
    let onDismiss: () -> Void
    
    var percentage: Int {
        Int((Double(correctAnswers) / Double(totalQuestions)) * 100)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Общий результат
                VStack(spacing: 16) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(hex: "#FFE600"))
                    
                    Text("\(percentage)%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    Text("\(correctAnswers) из \(totalQuestions) правильных")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text("Пробный тест завершён")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                }
                .padding(32)
                .background(Color.white)
                .cornerRadius(16)
                
                // Разбор вопросов
                VStack(alignment: .leading, spacing: 16) {
                    Text("РАЗБОР ВОПРОСОВ")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    ForEach(Array(questions.enumerated()), id: \.element.id) { index, question in
                        if let userAnswer = userAnswers.first(where: { $0.questionId == question.id }) {
                            QuestionReviewCard(
                                questionNumber: index + 1,
                                question: question,
                                userAnswer: userAnswer.userAnswer,
                                isCorrect: userAnswer.userAnswer == userAnswer.correctAnswer
                            )
                        }
                    }
                }
                
                // Видеоразбор
                if lesson.videoURL != nil {
                    NavigationLink(destination: VideoLessonView(lesson: lesson, isTheory: false)) {
                        HStack(spacing: 16) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "#E84E1B"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Видеоразбор теста")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#1B2A6B"))
                                
                                Text("Подробный разбор всех вопросов")
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

// MARK: - Question Review Card
struct QuestionReviewCard: View {
    let questionNumber: Int
    let question: Question
    let userAnswer: String
    let isCorrect: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            HStack {
                Text("Вопрос \(questionNumber)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
                
                if isCorrect {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Правильно")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.green)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("Неправильно")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Вопрос
            if question.type == .text {
                Text(question.questionText ?? "")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Divider()
            
            // Ответы
            VStack(alignment: .leading, spacing: 8) {
                if !isCorrect {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                            .frame(width: 20)
                        Text("Ваш ответ: \(userAnswer)")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .frame(width: 20)
                    Text("Правильный ответ: \(question.correctAnswer)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(16)
        .background(isCorrect ? Color.green.opacity(0.05) : Color.red.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        PracticeTestView(
            lesson: Lesson(
                id: "practice",
                levelId: "1",
                title: "СЫНАМЫК ТЕСТ №1",
                order: 0,
                isFree: true,
                isPracticeTest: true,
                videoURL: "https://example.com/video.mp4",
                description: "Пробный тест",
                subject: .text
            ),
            viewModel: LessonsViewModel()
        )
    }
}
