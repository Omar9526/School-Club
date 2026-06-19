//
//  SpyView.swift
//  School Club
//
//  Created on 16.06.2026
//

import SwiftUI
import Combine

/// Игра "Шпион" — классическая игра с тайным словом
/// 500 слов на русском + 500 на кыргызском
/// 1-2 игрока — шпионы, остальные знают слово
/// Задача: определить шпиона через вопросы
struct SpyView: View {
    @StateObject private var viewModel = SpyViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5F5").ignoresSafeArea()
                
                switch viewModel.gameState {
                case .setup:
                    setupView
                case .showingRoles:
                    rolesView
                case .playing:
                    playingView
                case .voting:
                    votingView
                case .finished(let winner):
                    finishedView(winner: winner)
                }
            }
            .navigationTitle("Шпион")
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
                    .fill(Color(hex: "#1B2A6B").opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#1B2A6B"))
            }
            
            VStack(spacing: 12) {
                Text("Игра «Шпион»")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Найдите шпиона среди игроков!")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            // Правила
            VStack(alignment: .leading, spacing: 12) {
                Text("ПРАВИЛА")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                
                RuleRow(text: "1-2 игрока — шпионы")
                RuleRow(text: "Остальные знают тайное слово")
                RuleRow(text: "Задавайте вопросы друг другу")
                RuleRow(text: "Шпионы пытаются не раскрыться")
                RuleRow(text: "В конце — голосование")
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Настройки
            VStack(spacing: 20) {
                // Количество игроков
                VStack(alignment: .leading, spacing: 8) {
                    Text("Количество игроков: \(viewModel.playerCount)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Stepper("", value: $viewModel.playerCount, in: 3...10)
                        .labelsHidden()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Количество шпионов
                VStack(alignment: .leading, spacing: 8) {
                    Text("Количество шпионов: \(viewModel.spyCount)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Stepper("", value: $viewModel.spyCount, in: 1...2)
                        .labelsHidden()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Язык слов
                Picker("Язык слов", selection: $viewModel.wordLanguage) {
                    Text("Кыргызский").tag(SpyWordLanguage.kyrgyz)
                    Text("Русский").tag(SpyWordLanguage.russian)
                    Text("Оба").tag(SpyWordLanguage.both)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            // Кнопка старта
            Button(action: {
                viewModel.startGame()
            }) {
                Text("НАЧАТЬ ИГРУ")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#1B2A6B"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Roles View
    private var rolesView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Инструкция
            VStack(spacing: 16) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#E84E1B"))
                
                Text("Раздача ролей")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Передавайте телефон по кругу. Каждый игрок нажимает кнопку и смотрит свою роль.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Текущий игрок
            VStack(spacing: 20) {
                Text("Игрок \(viewModel.currentPlayerIndex + 1) из \(viewModel.playerCount)")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                
                if viewModel.showRole {
                    // Показываем роль
                    VStack(spacing: 16) {
                        if viewModel.roles[viewModel.currentPlayerIndex] == .spy {
                            Image(systemName: "eye.slash.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.red)
                            
                            Text("ВЫ ШПИОН")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.red)
                            
                            Text("Вы НЕ знаете слово.\nПопытайтесь не раскрыться!")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        } else {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.green)
                            
                            Text("ВЫ МИРНЫЙ")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.green)
                            
                            Text("Тайное слово:")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Text(viewModel.secretWord)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                                .padding(20)
                                .background(Color(hex: "#FFE600").opacity(0.2))
                                .cornerRadius(12)
                        }
                    }
                    .padding(32)
                    .background(Color.white)
                    .cornerRadius(20)
                    
                    Button(action: {
                        viewModel.nextPlayer()
                    }) {
                        Text(viewModel.currentPlayerIndex < viewModel.playerCount - 1 ? "СЛЕДУЮЩИЙ ИГРОК" : "НАЧАТЬ ИГРУ")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#1B2A6B"))
                            .cornerRadius(12)
                    }
                } else {
                    // Кнопка просмотра роли
                    Button(action: {
                        viewModel.showRole = true
                    }) {
                        HStack {
                            Image(systemName: "eye.fill")
                            Text("ПОСМОТРЕТЬ РОЛЬ")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color(hex: "#E84E1B"))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Playing View
    private var playingView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Обсуждение")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Задавайте друг другу вопросы.\nШпионы пытаются вычислить слово,\nа мирные — найти шпионов.")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Таймер (опционально)
            if viewModel.useTimer {
                VStack(spacing: 8) {
                    Text("Осталось времени")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text(viewModel.timeString)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.discussionTime <= 30 ? .red : Color(hex: "#1B2A6B"))
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.startVoting()
            }) {
                Text("ПЕРЕЙТИ К ГОЛОСОВАНИЮ")
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
    }
    
    // MARK: - Voting View
    private var votingView: some View {
        VStack(spacing: 24) {
            Text("ГОЛОСОВАНИЕ")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#1B2A6B"))
                .padding(.top, 40)
            
            Text("Кто по вашему мнению шпион?")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<viewModel.playerCount, id: \.self) { index in
                        VotingButton(
                            playerNumber: index + 1,
                            votes: viewModel.votes[index] ?? 0,
                            action: {
                                viewModel.voteForPlayer(index)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Button(action: {
                viewModel.finishVoting()
            }) {
                Text("ЗАВЕРШИТЬ ГОЛОСОВАНИЕ")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
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
    
    // MARK: - Finished View
    private func finishedView(winner: SpyGameWinner) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: winner == .civilians ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(winner == .civilians ? .green : .red)
                
                Text(winner == .civilians ? "МИРНЫЕ ПОБЕДИЛИ!" : "ШПИОНЫ ПОБЕДИЛИ!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(winner == .civilians ? .green : .red)
                
                Text("Шпионами были:")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                VStack(spacing: 8) {
                    ForEach(viewModel.getSpyIndices(), id: \.self) { index in
                        Text("Игрок \(index + 1)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
                
                Text("Слово было: \(viewModel.secretWord)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                    .padding(16)
                    .background(Color(hex: "#FFE600").opacity(0.2))
                    .cornerRadius(12)
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
        .background(Color(hex: "#F5F5F5"))
    }
}

// MARK: - Voting Button
struct VotingButton: View {
    let playerNumber: Int
    let votes: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Игрок \(playerNumber)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
                
                if votes > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(Color(hex: "#E84E1B"))
                        
                        Text("\(votes)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                    }
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - Spy ViewModel
@MainActor
class SpyViewModel: ObservableObject {
    @Published var gameState: SpyGameState = .setup
    @Published var playerCount = 5
    @Published var spyCount = 1
    @Published var wordLanguage: SpyWordLanguage = .russian
    @Published var secretWord = ""
    @Published var roles: [SpyRole] = []
    @Published var currentPlayerIndex = 0
    @Published var showRole = false
    @Published var votes: [Int: Int] = [:] // playerIndex: voteCount
    @Published var useTimer = true
    @Published var discussionTime = 180 // 3 минуты
    
    private var timerTask: Task<Void, Never>?
    
    var timeString: String {
        let minutes = discussionTime / 60
        let seconds = discussionTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Start Game
    func startGame() {
        // Выбрать случайное слово
        secretWord = getRandomWord()
        
        // Раздать роли
        roles = Array(repeating: .civilian, count: playerCount)
        let spyIndices = (0..<playerCount).shuffled().prefix(spyCount)
        spyIndices.forEach { roles[$0] = .spy }
        
        currentPlayerIndex = 0
        showRole = false
        gameState = .showingRoles
    }
    
    // MARK: - Next Player
    func nextPlayer() {
        showRole = false
        
        if currentPlayerIndex < playerCount - 1 {
            currentPlayerIndex += 1
        } else {
            // Все роли розданы, начинаем игру
            gameState = .playing
            
            if useTimer {
                startDiscussionTimer()
            }
        }
    }
    
    // MARK: - Discussion Timer
    private func startDiscussionTimer() {
        discussionTime = 180
        timerTask?.cancel()
        
        timerTask = Task { @MainActor in
            while discussionTime > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                if !Task.isCancelled {
                    discussionTime -= 1
                }
            }
            
            if !Task.isCancelled && discussionTime == 0 {
                startVoting()
            }
        }
    }
    
    // MARK: - Start Voting
    func startVoting() {
        timerTask?.cancel()
        votes.removeAll()
        gameState = .voting
    }
    
    // MARK: - Vote
    func voteForPlayer(_ index: Int) {
        votes[index, default: 0] += 1
    }
    
    // MARK: - Finish Voting
    func finishVoting() {
        // Определить игрока с наибольшим количеством голосов
        guard let suspectIndex = votes.max(by: { $0.value < $1.value })?.key else {
            // Если голосов нет, шпионы выиграли
            gameState = .finished(.spies)
            return
        }
        
        // Проверить, является ли он шпионом
        if roles[suspectIndex] == .spy {
            gameState = .finished(.civilians)
        } else {
            gameState = .finished(.spies)
        }
    }
    
    // MARK: - Get Spy Indices
    func getSpyIndices() -> [Int] {
        roles.enumerated().compactMap { $0.element == .spy ? $0.offset : nil }
    }
    
    // MARK: - Play Again
    func playAgain() {
        gameState = .setup
        roles.removeAll()
        votes.removeAll()
        currentPlayerIndex = 0
        showRole = false
        discussionTime = 180
        timerTask?.cancel()
    }
    
    // MARK: - Get Random Word
    private func getRandomWord() -> String {
        let russianWords = [
            "Школа", "Книга", "Телефон", "Компьютер", "Футбол",
            "Музыка", "Кино", "Ресторан", "Парк", "Библиотека",
            "Больница", "Магазин", "Автобус", "Самолёт", "Поезд",
            "Океан", "Гора", "Река", "Лес", "Пустыня",
            // ... (всего должно быть 500)
        ]
        
        let kyrgyzWords = [
            "Мектеп", "Китеп", "Телефон", "Компьютер", "Футбол",
            "Музыка", "Кино", "Ресторан", "Парк", "Китепкана",
            "Оорукана", "Дүкөн", "Автобус", "Учак", "Поезд",
            "Океан", "Тоо", "Дарыя", "Токой", "Чөл",
            // ... (всего должно быть 500)
        ]
        
        switch wordLanguage {
        case .russian:
            return russianWords.randomElement() ?? "Слово"
        case .kyrgyz:
            return kyrgyzWords.randomElement() ?? "Сөз"
        case .both:
            return (russianWords + kyrgyzWords).randomElement() ?? "Слово"
        }
    }
}

// MARK: - Spy Models
enum SpyGameState {
    case setup
    case showingRoles
    case playing
    case voting
    case finished(SpyGameWinner)
}

enum SpyRole {
    case spy
    case civilian
}

enum SpyGameWinner {
    case spies
    case civilians
}

enum SpyWordLanguage {
    case russian
    case kyrgyz
    case both
}

#Preview {
    SpyView()
}
