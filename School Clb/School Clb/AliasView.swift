//
//  AliasView.swift
//  School Club
//
//  Created on 16.06.2026
//

import SwiftUI
import Combine

/// Игра "Элиас" (Alias) — объяснение слов без использования однокоренных
/// Команды, таймер, счёт
struct AliasView: View {
    @StateObject private var viewModel = AliasViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5F5").ignoresSafeArea()
                
                switch viewModel.gameState {
                case .setup:
                    setupView
                case .playing:
                    playingView
                case .finished:
                    finishedView
                }
            }
            .navigationTitle("Элиас")
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
    
    // MARK: - Setup View
    private var setupView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Иконка
            ZStack {
                Circle()
                    .fill(Color(hex: "#FFE600").opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#FFE600"))
            }
            
            VStack(spacing: 12) {
                Text("Игра «Элиас»")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Объясняй слова команде!")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            // Правила
            VStack(alignment: .leading, spacing: 12) {
                Text("ПРАВИЛА")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                
                RuleRow(text: "Объясни слово без однокоренных")
                RuleRow(text: "Команда угадывает за 60 секунд")
                RuleRow(text: "1 слово = 1 балл команде")
                RuleRow(text: "Пропустить можно, но −1 балл")
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Настройки
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Время на раунд: \(viewModel.roundTime) сек")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Stepper("", value: $viewModel.roundTime, in: 30...120, step: 30)
                        .labelsHidden()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Целевой счёт: \(viewModel.targetScore)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Stepper("", value: $viewModel.targetScore, in: 10...50, step: 5)
                        .labelsHidden()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Button(action: {
                viewModel.startGame()
            }) {
                Text("НАЧАТЬ ИГРУ")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#FFE600"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        VStack(spacing: 0) {
            // Счёт команд
            HStack {
                VStack(spacing: 4) {
                    Text("КОМАНДА 1")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.team1Score)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#E84E1B"))
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 60)
                
                VStack(spacing: 4) {
                    Text("КОМАНДА 2")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.team2Score)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 20)
            .background(Color.white)
            
            Spacer()
            
            // Текущее слово
            VStack(spacing: 24) {
                // Таймер
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.timeRemaining) / CGFloat(viewModel.roundTime))
                        .stroke(
                            viewModel.timeRemaining <= 10 ? Color.red : Color(hex: "#FFE600"),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: viewModel.timeRemaining)
                    
                    Text("\(viewModel.timeRemaining)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.timeRemaining <= 10 ? .red : Color(hex: "#1B2A6B"))
                }
                
                // Слово
                Text(viewModel.currentWord)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                    .multilineTextAlignment(.center)
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#FFE600").opacity(0.2))
                    .cornerRadius(20)
                
                // Счёт раунда
                Text("Угадано в раунде: \(viewModel.roundScore)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Кнопки
            HStack(spacing: 16) {
                // Пропустить
                Button(action: {
                    viewModel.skipWord()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.forward.circle.fill")
                            .font(.system(size: 40))
                        
                        Text("ПРОПУСТИТЬ")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Угадали
                Button(action: {
                    viewModel.correctWord()
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                        
                        Text("УГАДАЛИ")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Finished View
    private var finishedView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Color(hex: "#FFE600"))
                
                Text(viewModel.winnerText)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                HStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("КОМАНДА 1")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("\(viewModel.team1Score)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                    }
                    
                    Text(":")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 8) {
                        Text("КОМАНДА 2")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                        
                        Text("\(viewModel.team2Score)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.playAgain()
                }) {
                    Text("ИГРАТЬ ЕЩЁ")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#FFE600"))
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

// MARK: - Alias ViewModel
@MainActor
class AliasViewModel: ObservableObject {
    @Published var gameState: AliasGameState = .setup
    @Published var roundTime = 60
    @Published var targetScore = 30
    @Published var team1Score = 0
    @Published var team2Score = 0
    @Published var currentTeam = 1
    @Published var timeRemaining = 60
    @Published var currentWord = ""
    @Published var roundScore = 0
    
    private var timer: Timer?
    private var words: [String] = []
    private var usedWords: Set<String> = []
    
    var winnerText: String {
        if team1Score > team2Score {
            return "ПОБЕДИЛА КОМАНДА 1!"
        } else if team2Score > team1Score {
            return "ПОБЕДИЛА КОМАНДА 2!"
        } else {
            return "НИЧЬЯ!"
        }
    }
    
    // MARK: - Start Game
    func startGame() {
        loadWords()
        team1Score = 0
        team2Score = 0
        currentTeam = 1
        roundScore = 0
        startRound()
    }
    
    // MARK: - Load Words
    private func loadWords() {
        words = [
            "Школа", "Учитель", "Книга", "Компьютер", "Телефон",
            "Музыка", "Спорт", "Футбол", "Баскетбол", "Кино",
            "Ресторан", "Кафе", "Парк", "Библиотека", "Музей",
            // ... TODO: добавить больше слов
        ]
        usedWords.removeAll()
    }
    
    // MARK: - Start Round
    private func startRound() {
        gameState = .playing
        timeRemaining = roundTime
        roundScore = 0
        nextWord()
        startTimer()
    }
    
    // MARK: - Timer
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endRound()
                }
            }
        }
    }
    
    // MARK: - Next Word
    private func nextWord() {
        // Выбрать случайное неиспользованное слово
        let availableWords = words.filter { !usedWords.contains($0) }
        
        if let word = availableWords.randomElement() {
            currentWord = word
            usedWords.insert(word)
        } else {
            // Все слова использованы, сбросить
            usedWords.removeAll()
            currentWord = words.randomElement() ?? "Слово"
        }
    }
    
    // MARK: - Correct Word
    func correctWord() {
        roundScore += 1
        nextWord()
    }
    
    // MARK: - Skip Word
    func skipWord() {
        roundScore -= 1
        nextWord()
    }
    
    // MARK: - End Round
    private func endRound() {
        timer?.invalidate()
        
        // Добавить очки команде
        if currentTeam == 1 {
            team1Score += roundScore
        } else {
            team2Score += roundScore
        }
        
        // Проверить победу
        if team1Score >= targetScore || team2Score >= targetScore {
            gameState = .finished
        } else {
            // Передать ход другой команде
            currentTeam = currentTeam == 1 ? 2 : 1
            
            // TODO: Показать промежуточный экран перед следующим раундом
            startRound()
        }
    }
    
    // MARK: - Play Again
    func playAgain() {
        gameState = .setup
        team1Score = 0
        team2Score = 0
        currentTeam = 1
        roundScore = 0
        usedWords.removeAll()
    }
}

// MARK: - Alias Models
enum AliasGameState {
    case setup
    case playing
    case finished
}

#Preview {
    AliasView()
}
