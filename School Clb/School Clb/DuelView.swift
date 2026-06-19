//
//  DuelView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import Combine

struct DuelView: View {
    @StateObject private var viewModel = DuelViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5F5").ignoresSafeArea()
                
                switch viewModel.state {
                case .searching:
                    searchingView
                case .ready(let opponent):
                    readyView(opponent: opponent)
                case .playing(let opponent, let question):
                    playingView(opponent: opponent, question: question)
                case .result(let result):
                    resultView(result: result)
                }
            }
            .navigationTitle("Раз на раз")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.startMatchmaking()
        }
    }
    
    // MARK: - Searching View
    private var searchingView: some View {
        VStack(spacing: 32) {
            ProgressView()
                .scaleEffect(2)
                .tint(Color(hex: "#1B2A6B"))
            
            Text("Ищем соперника...")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#1B2A6B"))
            
            Text("Подождите немного")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Ready View
    private func readyView(opponent: DuelOpponent) -> some View {
        VStack(spacing: 40) {
            // Противники
            HStack(spacing: 40) {
                // Я
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#1B2A6B").opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Text("ВЫ")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                    }
                    
                    Text("Вы")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                }
                
                // VS
                Text("VS")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#E84E1B"))
                
                // Соперник
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E84E1B").opacity(0.2))
                            .frame(width: 100, height: 100)
                        
                        Text(opponent.name.prefix(1).uppercased())
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                    }
                    
                    Text(opponent.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#E84E1B"))
                }
            }
            
            // Правила
            VStack(alignment: .leading, spacing: 12) {
                Text("ПРАВИЛА")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                
                RuleRow(text: "5 вопросов подряд")
                RuleRow(text: "Кто быстрее ответит правильно → +1 балл")
                RuleRow(text: "Побеждает тот, кто набрал больше баллов")
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            
            Spacer()
            
            // Кнопка старта
            Text("Начинаем через \(viewModel.countdown)...")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#1B2A6B"))
        }
        .padding(20)
    }
    
    // MARK: - Playing View
    private func playingView(opponent: DuelOpponent, question: Question) -> some View {
        VStack(spacing: 0) {
            // Счёт
            HStack {
                // Мой счёт
                VStack(spacing: 4) {
                    Text("ВЫ")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.myScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 50)
                
                // Счёт соперника
                VStack(spacing: 4) {
                    Text(opponent.name.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.opponentScore)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#E84E1B"))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 20)
            .background(Color.white)
            
            // Прогресс вопросов
            HStack(spacing: 8) {
                Text("Вопрос \(viewModel.currentQuestionNumber)/5")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { index in
                        Circle()
                            .fill(index <= viewModel.currentQuestionNumber ? Color(hex: "#FFE600") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(hex: "#F5F5F5"))
            
            ScrollView {
                VStack(spacing: 24) {
                    // Вопрос
                    Text(question.questionText ?? "")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(12)
                    
                    // Варианты
                    VStack(spacing: 12) {
                        DuelAnswerButton(
                            letter: "А",
                            text: question.optionA,
                            isSelected: viewModel.selectedAnswer == "A",
                            isCorrect: viewModel.showResult && question.correctAnswer == "A",
                            isWrong: viewModel.showResult && viewModel.selectedAnswer == "A" && question.correctAnswer != "A",
                            action: { viewModel.selectAnswer("A") }
                        )
                        
                        DuelAnswerButton(
                            letter: "Б",
                            text: question.optionB,
                            isSelected: viewModel.selectedAnswer == "B",
                            isCorrect: viewModel.showResult && question.correctAnswer == "B",
                            isWrong: viewModel.showResult && viewModel.selectedAnswer == "B" && question.correctAnswer != "B",
                            action: { viewModel.selectAnswer("B") }
                        )
                        
                        DuelAnswerButton(
                            letter: "В",
                            text: question.optionC,
                            isSelected: viewModel.selectedAnswer == "C",
                            isCorrect: viewModel.showResult && question.correctAnswer == "C",
                            isWrong: viewModel.showResult && viewModel.selectedAnswer == "C" && question.correctAnswer != "C",
                            action: { viewModel.selectAnswer("C") }
                        )
                        
                        DuelAnswerButton(
                            letter: "Г",
                            text: question.optionD,
                            isSelected: viewModel.selectedAnswer == "D",
                            isCorrect: viewModel.showResult && question.correctAnswer == "D",
                            isWrong: viewModel.showResult && viewModel.selectedAnswer == "D" && question.correctAnswer != "D",
                            action: { viewModel.selectAnswer("D") }
                        )
                    }
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Result View
    private func resultView(result: DuelResult) -> some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Результат
            VStack(spacing: 20) {
                Image(systemName: result.isWinner ? "trophy.fill" : "flag.fill")
                    .font(.system(size: 100))
                    .foregroundColor(result.isWinner ? Color(hex: "#FFE600") : Color.gray)
                
                Text(result.isWinner ? "ПОБЕДА!" : (result.isDraw ? "НИЧЬЯ" : "ПОРАЖЕНИЕ"))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(result.isWinner ? Color(hex: "#1B2A6B") : (result.isDraw ? .gray : Color(hex: "#E84E1B")))
                
                HStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("ВЫ")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("\(result.myScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                    }
                    
                    Text(":")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        Text(result.opponentName.uppercased())
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("\(result.opponentScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                    }
                }
                
                if result.isWinner {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#FFE600"))
                        
                        Text("+\(result.earnedPoints) баллов")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#FFE600"))
                    }
                    .padding(16)
                    .background(Color(hex: "#FFE600").opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
            
            // Кнопки
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.startMatchmaking()
                }) {
                    Text("ИГРАТЬ ЕЩЁ")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#1B2A6B"))
                        .cornerRadius(12)
                }
                
                Button(action: { dismiss() }) {
                    Text("Выйти")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Rule Row
struct RuleRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "#1B2A6B"))
            
            Text(text)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Duel Answer Button
struct DuelAnswerButton: View {
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
            return Color(hex: "#1B2A6B").opacity(0.1)
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
            return Color(hex: "#1B2A6B")
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(letter)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isCorrect ? .green : (isWrong ? .red : (isSelected ? .white : Color(hex: "#1B2A6B"))))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isCorrect ? Color.green.opacity(0.2) : (isWrong ? Color.red.opacity(0.2) : (isSelected ? Color(hex: "#1B2A6B") : Color(hex: "#F5F5F5"))))
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

// MARK: - Duel ViewModel
@MainActor
class DuelViewModel: ObservableObject {
    @Published var state: DuelState = .searching
    @Published var myScore = 0
    @Published var opponentScore = 0
    @Published var currentQuestionNumber = 1
    @Published var countdown = 3
    @Published var selectedAnswer: String?
    @Published var showResult = false
    
    private var questions: [Question] = []
    private let pointsService = PointsService.shared
    
    func startMatchmaking() {
        state = .searching
        myScore = 0
        opponentScore = 0
        currentQuestionNumber = 1
        
        // Симуляция поиска соперника
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let opponent = DuelOpponent(id: "opp1", name: "Бекжан", rating: 1250)
            self.state = .ready(opponent)
            self.startCountdown(opponent: opponent)
        }
    }
    
    private func startCountdown(opponent: DuelOpponent) {
        countdown = 3
        Task {
            for _ in 1..<countdown {
                try? await Task.sleep(for: .seconds(1))
                self.countdown -= 1
            }
            
            self.loadQuestions()
            self.startGame(opponent: opponent)
        }
    }
    
    private func loadQuestions() {
        // Mock вопросы
        questions = (1...5).map { i in
            Question(
                id: "duel-\(i)",
                lessonId: "duel",
                order: i,
                type: .text,
                questionText: "Дуэльный вопрос \(i)?",
                questionImageURL: nil,
                optionA: "Вариант А",
                optionB: "Вариант Б",
                optionC: "Вариант В",
                optionD: "Вариант Г",
                correctAnswer: ["A", "B", "C", "D"].randomElement()!
            )
        }
    }
    
    private func startGame(opponent: DuelOpponent) {
        guard let firstQuestion = questions.first else { return }
        state = .playing(opponent, firstQuestion)
    }
    
    func selectAnswer(_ answer: String) {
        guard !showResult, case .playing(let opponent, let question) = state else { return }
        
        selectedAnswer = answer
        showResult = true
        
        // Проверка ответа
        if answer == question.correctAnswer {
            myScore += 1
        }
        
        // Случайный ответ соперника
        if Bool.random() {
            opponentScore += 1
        }
        
        // Следующий вопрос через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.nextQuestion(opponent: opponent)
        }
    }
    
    private func nextQuestion(opponent: DuelOpponent) {
        if currentQuestionNumber < 5 {
            currentQuestionNumber += 1
            selectedAnswer = nil
            showResult = false
            
            if let nextQuestion = questions[safe: currentQuestionNumber - 1] {
                state = .playing(opponent, nextQuestion)
            }
        } else {
            showResults(opponent: opponent)
        }
    }
    
    private func showResults(opponent: DuelOpponent) {
        let isWinner = myScore > opponentScore
        let isDraw = myScore == opponentScore
        
        // Система начисления баллов: 1-10 в зависимости от счёта
        let earnedPoints: Int
        if isWinner {
            // Чем больше разница в счёте, тем больше баллов
            let scoreDifference = myScore - opponentScore
            earnedPoints = min(10, max(1, myScore + scoreDifference))
            
            // Начисляем баллы через PointsService
            pointsService.addPoints(
                earnedPoints,
                source: .duelWin,
                details: "Победа над \(opponent.name) со счётом \(myScore):\(opponentScore)"
            )
        } else {
            earnedPoints = 0
        }
        
        let result = DuelResult(
            isWinner: isWinner,
            isDraw: isDraw,
            myScore: myScore,
            opponentScore: opponentScore,
            opponentName: opponent.name,
            earnedPoints: earnedPoints
        )
        
        state = .result(result)
    }
}

// MARK: - Duel Models
enum DuelState: Sendable {
    case searching
    case ready(DuelOpponent)
    case playing(DuelOpponent, Question)
    case result(DuelResult)
}

struct DuelOpponent: Sendable {
    let id: String
    let name: String
    let rating: Int
}

struct DuelResult: Sendable {
    let isWinner: Bool
    let isDraw: Bool
    let myScore: Int
    let opponentScore: Int
    let opponentName: String
    let earnedPoints: Int
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    DuelView()
}
