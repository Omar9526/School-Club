//
//  BreakView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct BreakView: View {
    @StateObject private var viewModel = BreakViewModel()
    @State private var selectedDifficulty: QuizDifficulty = .easy
    @State private var showQuiz = false
    @State private var showDuel = false
    
    // Групповые игры
    @State private var showKahoot = false
    @State private var showSpy = false
    @State private var showAlias = false
    @State private var showMafia = false
    @State private var showCrocodile = false
    @State private var showOther = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1) РАЗ НА РАЗ
                    duelCard
                    
                    // 2) ВИКТОРИНА СКУЛ КЛАБ
                    quizCard
                    
                    // 3) ГРУППОВЫЕ ИГРЫ
                    groupGamesSection
                }
                .padding(20)
                .padding(.bottom, 100) // ✅ Отступ снизу, чтобы контент не заезжал под таб-бар
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Брейк")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showQuiz) {
            QuizView(
                questions: viewModel.loadQuizQuestions(difficulty: selectedDifficulty, subject: nil),
                title: "Викторина",
                difficulty: selectedDifficulty
            )
        }
        .fullScreenCover(isPresented: $showDuel) {
            DuelView()
        }
        .fullScreenCover(isPresented: $showKahoot) {
            KahootView()
        }
        .fullScreenCover(isPresented: $showSpy) {
            SpyView()
        }
        .fullScreenCover(isPresented: $showAlias) {
            AliasView()
        }
        .fullScreenCover(isPresented: $showMafia) {
            MafiaView()
        }
        .fullScreenCover(isPresented: $showCrocodile) {
            CrocodileView()
        }
        .fullScreenCover(isPresented: $showOther) {
            ComingSoonView()
        }
    }
    
    // MARK: - Duel Card
    private var duelCard: some View {
        Button(action: {
            showDuel = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.2.badge.gearshape")
                        .font(.system(size: 36))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("РАЗ НА РАЗ")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                        
                        Text("Играть с кем-то из друзей")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B").opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("НАЧАТЬ")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#1B2A6B"))
                        .cornerRadius(10)
                        .shadow(color: Color(hex: "#1B2A6B").opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color(hex: "#1B2A6B").opacity(0.2), Color(hex: "#1B2A6B").opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - Quiz Card
    private var quizCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "#E84E1B"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ВИКТОРИНА СКУЛ КЛАБ")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    Text("Разные тесты с зарабатыванием баллов")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B").opacity(0.7))
                }
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach([QuizDifficulty.easy, .medium, .hard], id: \.self) { difficulty in
                    Button(action: { selectedDifficulty = difficulty }) {
                        Text(difficulty.rawValue)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedDifficulty == difficulty ? .white : Color(hex: "#1B2A6B"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(selectedDifficulty == difficulty ? Color(hex: "#1B2A6B") : Color(hex: "#1B2A6B").opacity(0.08))
                            .cornerRadius(8)
                    }
                }
            }
            
            Button(action: {
                showQuiz = true
            }) {
                Text("НАЧАТЬ")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#E84E1B"))
                    .cornerRadius(10)
                    .shadow(color: Color(hex: "#E84E1B").opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Group Games Section
    private var groupGamesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ГРУППОВЫЕ ИГРЫ")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                GroupGameTile(
                    icon: "moon.stars.fill",
                    title: "Мафия",
                    action: { showMafia = true }
                )
                
                GroupGameTile(
                    icon: "timer",
                    title: "Кахут",
                    action: { showKahoot = true }
                )
                
                GroupGameTile(
                    icon: "hand.point.up.left.fill",
                    title: "Крокодил",
                    action: { showCrocodile = true }
                )
                
                GroupGameTile(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Элиас",
                    action: { showAlias = true }
                )
                
                GroupGameTile(
                    icon: "eye.slash.fill",
                    title: "Шпион",
                    action: { showSpy = true }
                )
                
                GroupGameTile(
                    icon: "ellipsis",
                    title: "Прочее",
                    action: { showOther = true }
                )
            }
        }
    }
}

// MARK: - Group Game Tile
struct GroupGameTile: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#1B2A6B").opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - Coming Soon View
struct ComingSoonView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "clock.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Скоро")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Здесь будут другие игры")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Закрыть")
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
            .navigationTitle("Прочее")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Crocodile View (Placeholder)
struct CrocodileView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "hand.point.up.left.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("Крокодил")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("В разработке")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Закрыть")
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
            .navigationTitle("Крокодил")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}



#Preview {
    BreakView()
}
