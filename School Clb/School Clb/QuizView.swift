//
//  QuizView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct QuizView: View {
    let questions: [Question]
    let title: String
    let difficulty: QuizDifficulty
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var isAnswerChecked = false
    @State private var correctAnswers = 0
    @State private var showResults = false
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5F5").ignoresSafeArea()
                
                if showResults {
                    // Результаты
                    QuizResultsView(
                        correctAnswers: correctAnswers,
                        totalQuestions: questions.count,
                        difficulty: difficulty,
                        onDismiss: { dismiss() }
                    )
                } else if let question = currentQuestion {
                    VStack(spacing: 0) {
                        // Таймер и прогресс
                        VStack(spacing: 12) {
                            // Таймер
                            HStack {
                                Image(systemName: "timer")
                                    .foregroundColor(timeRemaining <= 10 ? .red : Color(hex: "#1B2A6B"))
                                
                                Text("\(timeRemaining)s")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(timeRemaining <= 10 ? .red : Color(hex: "#1B2A6B"))
                                
                                Spacer()
                                
                                Text("Вопрос \(currentQuestionIndex + 1)/\(questions.count)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            
                            // Прогресс-бар
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 6)
                                        .cornerRadius(3)
                                    
                                    Rectangle()
                                        .fill(Color(hex: "#FFE600"))
                                        .frame(width: geometry.size.width * progress, height: 6)
                                        .cornerRadius(3)
                                        .animation(.easeInOut, value: progress)
                                }
                            }
                            .frame(height: 6)
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
                                    QuizAnswerButton(
                                        letter: "А",
                                        text: question.optionA,
                                        isSelected: selectedAnswer == "A",
                                        isCorrect: isAnswerChecked && question.correctAnswer == "A",
                                        isWrong: isAnswerChecked && selectedAnswer == "A" && question.correctAnswer != "A",
                                        action: { selectAnswer("A") }
                                    )
                                    
                                    QuizAnswerButton(
                                        letter: "Б",
                                        text: question.optionB,
                                        isSelected: selectedAnswer == "B",
                                        isCorrect: isAnswerChecked && question.correctAnswer == "B",
                                        isWrong: isAnswerChecked && selectedAnswer == "B" && question.correctAnswer != "B",
                                        action: { selectAnswer("B") }
                                    )
                                    
                                    QuizAnswerButton(
                                        letter: "В",
                                        text: question.optionC,
                                        isSelected: selectedAnswer == "C",
                                        isCorrect: isAnswerChecked && question.correctAnswer == "C",
                                        isWrong: isAnswerChecked && selectedAnswer == "C" && question.correctAnswer != "C",
                                        action: { selectAnswer("C") }
                                    )
                                    
                                    QuizAnswerButton(
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
                                        Text(currentQuestionIndex < questions.count - 1 ? "Следующий" : "Завершить")
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
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Выйти") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Timer
    private func startTimer() {
        timeRemaining = 30
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Время вышло
                if !isAnswerChecked {
                    nextQuestion()
                }
            }
        }
    }
    
    // MARK: - Actions
    private func selectAnswer(_ answer: String) {
        guard !isAnswerChecked else { return }
        selectedAnswer = answer
    }
    
    private func checkAnswer() {
        guard let selected = selectedAnswer, let question = currentQuestion else { return }
        
        timer?.invalidate()
        isAnswerChecked = true
        
        if selected == question.correctAnswer {
            correctAnswers += 1
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            isAnswerChecked = false
            startTimer()
        } else {
            timer?.invalidate()
            showResults = true
        }
    }
}

// MARK: - Quiz Answer Button
struct QuizAnswerButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isCorrect {
            return Color.green.opacity(0.2)
        } else if isWrong {
            return Color.red.opacity(0.2)
        } else if isSelected {
            return Color(hex: "#FFE600").opacity(0.2)
        } else {
            return Color.white
        }
    }
    
    var borderColor: Color {
        if isCorrect {
            return Color.green
        } else if isWrong {
            return Color.red
        } else if isSelected {
            return Color(hex: "#FFE600")
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(letter)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isCorrect ? .green : (isWrong ? .red : Color(hex: "#1B2A6B")))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isCorrect ? Color.green.opacity(0.2) : (isWrong ? Color.red.opacity(0.2) : Color(hex: "#F5F5F5")))
                    )
                
                Text(text)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .disabled(isCorrect || isWrong)
    }
}

// MARK: - Quiz Results View
struct QuizResultsView: View {
    let correctAnswers: Int
    let totalQuestions: Int
    let difficulty: QuizDifficulty
    let onDismiss: () -> Void
    
    @StateObject private var pointsService = PointsService.shared
    @State private var hasAddedPoints = false
    
    var percentage: Int {
        Int((Double(correctAnswers) / Double(totalQuestions)) * 100)
    }
    
    // Оценка по системе: 70%→3, 80%→4, 90%→5
    var grade: Int? {
        if percentage >= 90 {
            return 5
        } else if percentage >= 80 {
            return 4
        } else if percentage >= 70 {
            return 3
        } else {
            return nil
        }
    }
    
    // Баллы: 1-10 в зависимости от процента и сложности
    var earnedPoints: Int {
        guard let grade = grade else { return 0 }
        
        let basePoints: Int
        switch grade {
        case 5: basePoints = 10
        case 4: basePoints = 7
        case 3: basePoints = 5
        default: basePoints = 0
        }
        
        // Множитель сложности
        let difficultyMultiplier: Double = {
            switch difficulty {
            case .easy: return 1.0
            case .medium: return 1.3
            case .hard: return 1.5
            }
        }()
        
        return min(10, Int(Double(basePoints) * difficultyMultiplier))
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Результат
            VStack(spacing: 16) {
                Image(systemName: grade != nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(grade != nil ? .green : Color(hex: "#E84E1B"))
                
                Text("\(percentage)%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("\(correctAnswers) из \(totalQuestions) правильных")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                // Оценка
                if let grade = grade {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("Оценка:")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Text("\(grade)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                        }
                        
                        Text("Отлично! 🎉")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.green)
                        
                        // Баллы
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(hex: "#FFE600"))
                            
                            Text("+\(earnedPoints) баллов")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#FFE600"))
                        }
                    }
                    .padding(20)
                    .background(Color(hex: "#FFE600").opacity(0.1))
                    .cornerRadius(16)
                    .onAppear {
                        addPointsOnce()
                    }
                } else {
                    Text("Попробуйте ещё раз")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#E84E1B"))
                }
            }
            
            Spacer()
            
            // Кнопка
            Button(action: onDismiss) {
                Text("Завершить")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#1B2A6B"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "#F5F5F5"))
    }
    
    // MARK: - Add Points Once
    private func addPointsOnce() {
        guard !hasAddedPoints, earnedPoints > 0 else { return }
        
        pointsService.addPoints(
            earnedPoints,
            source: .quizComplete,
            details: "Викторина (\(difficulty.rawValue)): \(percentage)%, оценка \(grade ?? 0)"
        )
        
        hasAddedPoints = true
    }
}

#Preview {
    QuizView(
        questions: [
            Question(id: "1", lessonId: "quiz", order: 1, type: .text, questionText: "Тестовый вопрос?", questionImageURL: nil, optionA: "А", optionB: "Б", optionC: "В", optionD: "Г", correctAnswer: "A")
        ],
        title: "Викторина",
        difficulty: .easy
    )
}
