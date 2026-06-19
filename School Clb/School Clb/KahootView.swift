//
//  KahootView.swift
//  School Club
//
//  Created on 16.06.2026
//

import SwiftUI
import Combine

/// Игра "Кахут" — быстрые ответы на вопросы
/// Чем быстрее ответ, тем больше баллов: 1-е место → 5б, 2-е → 4б, 3-е → 3б
/// Можно играть группой или командами по коду доступа
struct KahootView: View {
    @StateObject private var viewModel = KahootViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5F5").ignoresSafeArea()
                
                switch viewModel.gameState {
                case .lobby:
                    lobbyView
                case .playing(let question):
                    playingView(question: question)
                case .leaderboard:
                    leaderboardView
                case .finished:
                    finishedView
                }
            }
            .navigationTitle("Кахут")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Выйти") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Lobby View
    private var lobbyView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Иконка
            ZStack {
                Circle()
                    .fill(Color(hex: "#E84E1B").opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "timer")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#E84E1B"))
            }
            
            VStack(spacing: 12) {
                Text("Быстрая викторина")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Отвечайте правильно и быстро!")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            // Правила
            VStack(alignment: .leading, spacing: 12) {
                Text("ПРАВИЛА")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                
                RuleRow(text: "10 вопросов подряд")
                RuleRow(text: "Чем быстрее ответ → тем больше баллов")
                RuleRow(text: "1-е место → 5 баллов")
                RuleRow(text: "2-е место → 4 балла")
                RuleRow(text: "3-е место → 3 балла")
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Режимы игры
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.startSoloGame()
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("ИГРАТЬ ОДНОМУ")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#E84E1B"))
                    .cornerRadius(12)
                }
                
                Button(action: {
                    viewModel.createGroupGame()
                }) {
                    HStack {
                        Image(systemName: "person.3.fill")
                        Text("СОЗДАТЬ ГРУППОВУЮ ИГРУ")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(Color(hex: "#1B2A6B"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hex: "#1B2A6B"), lineWidth: 2)
                    )
                }
                
                // Код доступа к игре (если создана)
                if let gameCode = viewModel.gameCode {
                    VStack(spacing: 8) {
                        Text("КОД ИГРЫ")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text(gameCode)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                            .tracking(8)
                        
                        Text("Игроки: \(viewModel.players.count)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#FFE600").opacity(0.2))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Playing View
    private func playingView(question: KahootQuestion) -> some View {
        VStack(spacing: 0) {
            // Таймер и прогресс
            VStack(spacing: 12) {
                HStack {
                    // Таймер
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(viewModel.timeRemaining) / 20.0)
                            .stroke(
                                viewModel.timeRemaining <= 5 ? Color.red : Color(hex: "#E84E1B"),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: viewModel.timeRemaining)
                        
                        Text("\(viewModel.timeRemaining)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.timeRemaining <= 5 ? .red : Color(hex: "#1B2A6B"))
                    }
                    
                    Spacer()
                    
                    // Прогресс
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Вопрос \(viewModel.currentQuestionIndex + 1)/10")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("Очки: \(viewModel.totalScore)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#FFE600"))
                    }
                }
                
                // Прогресс-бар
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(Color(hex: "#E84E1B"))
                            .frame(
                                width: geometry.size.width * CGFloat(viewModel.currentQuestionIndex + 1) / 10.0,
                                height: 6
                            )
                            .cornerRadius(3)
                            .animation(.easeInOut, value: viewModel.currentQuestionIndex)
                    }
                }
                .frame(height: 6)
            }
            .padding(20)
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Вопрос
                    Text(question.text)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                        .multilineTextAlignment(.center)
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#E84E1B").opacity(0.1), Color.white],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(16)
                    
                    // Варианты (крупные кнопки 2x2)
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            KahootAnswerButton(
                                letter: "А",
                                text: question.optionA,
                                color: "#E84E1B",
                                isSelected: viewModel.selectedAnswer == "A",
                                isCorrect: viewModel.showResult && question.correctAnswer == "A",
                                isWrong: viewModel.showResult && viewModel.selectedAnswer == "A" && question.correctAnswer != "A",
                                action: { viewModel.selectAnswer("A") }
                            )
                            
                            KahootAnswerButton(
                                letter: "Б",
                                text: question.optionB,
                                color: "#1B2A6B",
                                isSelected: viewModel.selectedAnswer == "B",
                                isCorrect: viewModel.showResult && question.correctAnswer == "B",
                                isWrong: viewModel.showResult && viewModel.selectedAnswer == "B" && question.correctAnswer != "B",
                                action: { viewModel.selectAnswer("B") }
                            )
                        }
                        
                        HStack(spacing: 12) {
                            KahootAnswerButton(
                                letter: "В",
                                text: question.optionC,
                                color: "#FFE600",
                                isSelected: viewModel.selectedAnswer == "C",
                                isCorrect: viewModel.showResult && question.correctAnswer == "C",
                                isWrong: viewModel.showResult && viewModel.selectedAnswer == "C" && question.correctAnswer != "C",
                                action: { viewModel.selectAnswer("C") }
                            )
                            
                            KahootAnswerButton(
                                letter: "Г",
                                text: question.optionD,
                                color: "#34C759",
                                isSelected: viewModel.selectedAnswer == "D",
                                isCorrect: viewModel.showResult && question.correctAnswer == "D",
                                isWrong: viewModel.showResult && viewModel.selectedAnswer == "D" && question.correctAnswer != "D",
                                action: { viewModel.selectAnswer("D") }
                            )
                        }
                    }
                }
                .padding(20)
            }
        }
    }
    
    // MARK: - Leaderboard View
    private var leaderboardView: some View {
        VStack(spacing: 24) {
            Text("ЛИДЕРБОРД")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#1B2A6B"))
                .padding(.top, 40)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                        LeaderboardRow(
                            rank: index + 1,
                            player: player,
                            isCurrentUser: player.id == "current-user"
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Button(action: {
                viewModel.nextQuestion()
            }) {
                Text("ПРОДОЛЖИТЬ")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#E84E1B"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(Color(hex: "#F5F5F5"))
    }
    
    // MARK: - Finished View
    private var finishedView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Результат
            VStack(spacing: 16) {
                if viewModel.finalRank <= 3 {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 100))
                        .foregroundColor(viewModel.medalColor)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                }
                
                Text("Место: #\(viewModel.finalRank)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Набрано очков: \(viewModel.totalScore)")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                if viewModel.earnedPoints > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(hex: "#FFE600"))
                        
                        Text("+\(viewModel.earnedPoints) баллов")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#FFE600"))
                    }
                    .padding(20)
                    .background(Color(hex: "#FFE600").opacity(0.1))
                    .cornerRadius(16)
                }
            }
            
            Spacer()
            
            // Кнопки
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.playAgain()
                }) {
                    Text("ИГРАТЬ ЕЩЁ")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#E84E1B"))
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
        .background(Color(hex: "#F5F5F5"))
    }
}

// MARK: - Kahoot Answer Button
struct KahootAnswerButton: View {
    let letter: String
    let text: String
    let color: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(letter)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(text)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding(12)
            .background(
                Group {
                    if isCorrect {
                        Color.green
                    } else if isWrong {
                        Color.red
                    } else {
                        Color(hex: color)
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 4)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .disabled(isCorrect || isWrong)
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let rank: Int
    let player: KahootPlayer
    let isCurrentUser: Bool
    
    var medalColor: Color {
        switch rank {
        case 1: return Color(hex: "#FFD700") // Золото
        case 2: return Color(hex: "#C0C0C0") // Серебро
        case 3: return Color(hex: "#CD7F32") // Бронза
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Место
            ZStack {
                Circle()
                    .fill(rank <= 3 ? medalColor : Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                Text("\(rank)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(rank <= 3 ? .white : .gray)
            }
            
            // Имя
            Text(player.name)
                .font(.system(size: 16, weight: isCurrentUser ? .bold : .semibold, design: .rounded))
                .foregroundColor(isCurrentUser ? Color(hex: "#E84E1B") : .primary)
            
            Spacer()
            
            // Очки
            Text("\(player.score)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#FFE600"))
        }
        .padding(16)
        .background(isCurrentUser ? Color(hex: "#E84E1B").opacity(0.1) : Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Kahoot ViewModel
@MainActor
class KahootViewModel: ObservableObject {
    @Published var gameState: KahootGameState = .lobby
    @Published var currentQuestionIndex = 0
    @Published var timeRemaining = 20
    @Published var selectedAnswer: String?
    @Published var showResult = false
    @Published var totalScore = 0
    @Published var gameCode: String?
    @Published var players: [KahootPlayer] = []
    @Published var finalRank = 0
    
    private var questions: [KahootQuestion] = []
    private var timer: Timer?
    private let pointsService = PointsService.shared
    private var answerStartTime: Date?
    
    var earnedPoints: Int {
        // 1-е место → 5б, 2-е → 4б, 3-е → 3б
        switch finalRank {
        case 1: return 5
        case 2: return 4
        case 3: return 3
        default: return 0
        }
    }
    
    var medalColor: Color {
        switch finalRank {
        case 1: return Color(hex: "#FFD700") // Золото
        case 2: return Color(hex: "#C0C0C0") // Серебро
        case 3: return Color(hex: "#CD7F32") // Бронза
        default: return .gray
        }
    }
    
    // MARK: - Start Solo Game
    func startSoloGame() {
        loadQuestions()
        players = [
            KahootPlayer(id: "current-user", name: "Вы", score: 0),
            KahootPlayer(id: "bot1", name: "Бекжан", score: 0),
            KahootPlayer(id: "bot2", name: "Айдай", score: 0),
            KahootPlayer(id: "bot3", name: "Динара", score: 0),
            KahootPlayer(id: "bot4", name: "Эркин", score: 0)
        ]
        startGame()
    }
    
    // MARK: - Create Group Game
    func createGroupGame() {
        gameCode = generateGameCode()
        loadQuestions()
        
        // Mock: добавить текущего пользователя
        players = [
            KahootPlayer(id: "current-user", name: "Вы", score: 0)
        ]
        
        // TODO: Ждать других игроков через Firestore
    }
    
    // MARK: - Load Questions
    private func loadQuestions() {
        questions = (1...10).map { i in
            KahootQuestion(
                id: "kahoot-\(i)",
                text: "Вопрос \(i): Столица Кыргызстана?",
                optionA: "Бишкек",
                optionB: "Ош",
                optionC: "Джалал-Абад",
                optionD: "Нарын",
                correctAnswer: "A"
            )
        }
    }
    
    // MARK: - Start Game
    private func startGame() {
        currentQuestionIndex = 0
        totalScore = 0
        gameState = .playing(questions[0])
        answerStartTime = Date()
        startTimer()
    }
    
    // MARK: - Timer
    private func startTimer() {
        timeRemaining = 20
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    // Время вышло
                    if !self.showResult {
                        self.checkAnswer(forced: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Select Answer
    func selectAnswer(_ answer: String) {
        guard !showResult else { return }
        selectedAnswer = answer
        checkAnswer(forced: false)
    }
    
    // MARK: - Check Answer
    private func checkAnswer(forced: Bool) {
        timer?.invalidate()
        showResult = true
        
        guard let question = questions[safe: currentQuestionIndex] else { return }
        
        // Подсчёт очков на основе скорости ответа
        if selectedAnswer == question.correctAnswer {
            let timeBonus = forced ? 0 : (timeRemaining * 50) // Бонус за скорость
            let questionScore = 1000 + timeBonus
            totalScore += questionScore
            
            // Обновить счёт игрока
            if let index = players.firstIndex(where: { $0.id == "current-user" }) {
                players[index].score = totalScore
            }
        }
        
        // Симуляция ответов ботов
        simulateBotAnswers()
        
        // Показать лидерборд через 2 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showLeaderboard()
        }
    }
    
    // MARK: - Simulate Bot Answers
    private func simulateBotAnswers() {
        for i in 1..<players.count {
            // Боты отвечают с разной скоростью и точностью
            let isCorrect = Bool.random()
            let randomScore = isCorrect ? Int.random(in: 800...1200) : 0
            players[i].score += randomScore
        }
        
        // Сортировать игроков по очкам
        players.sort { $0.score > $1.score }
    }
    
    // MARK: - Show Leaderboard
    private func showLeaderboard() {
        gameState = .leaderboard
    }
    
    // MARK: - Next Question
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
            showResult = false
            answerStartTime = Date()
            
            if let nextQuestion = questions[safe: currentQuestionIndex] {
                gameState = .playing(nextQuestion)
                startTimer()
            }
        } else {
            finishGame()
        }
    }
    
    // MARK: - Finish Game
    private func finishGame() {
        timer?.invalidate()
        
        // Определить финальное место
        if let userIndex = players.firstIndex(where: { $0.id == "current-user" }) {
            finalRank = userIndex + 1
        }
        
        // Начислить баллы
        if earnedPoints > 0 {
            pointsService.addPoints(
                earnedPoints,
                source: .kahootWin,
                details: "Кахут: место #\(finalRank), очков \(totalScore)"
            )
        }
        
        gameState = .finished
    }
    
    // MARK: - Play Again
    func playAgain() {
        gameState = .lobby
        currentQuestionIndex = 0
        selectedAnswer = nil
        showResult = false
        totalScore = 0
        gameCode = nil
        players.removeAll()
        finalRank = 0
    }
    
    // MARK: - Generate Game Code
    private func generateGameCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}

// MARK: - Kahoot Models
enum KahootGameState {
    case lobby
    case playing(KahootQuestion)
    case leaderboard
    case finished
}

struct KahootQuestion: Identifiable {
    let id: String
    let text: String
    let optionA: String
    let optionB: String
    let optionC: String
    let optionD: String
    let correctAnswer: String
}

struct KahootPlayer: Identifiable {
    let id: String
    let name: String
    var score: Int
}

#Preview {
    KahootView()
}
