//
//  BottleView.swift
//  School Club
//
//  Created on 16.06.2026
//

import SwiftUI
import Combine

/// Игра "Бутылочка" — классическая игра с вращением бутылки
/// Анимация вращения, выбор на кого указала бутылка
struct BottleView: View {
    @StateObject private var viewModel = BottleViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5F5").ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Игроки по кругу
                    ZStack {
                        ForEach(Array(viewModel.players.enumerated()), id: \.element.id) { index, player in
                            PlayerCircleView(
                                player: player,
                                angle: viewModel.angleForPlayer(index: index)
                            )
                        }
                        
                        // Бутылка в центре
                        Image(systemName: "arrowtriangle.up.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "#E84E1B"))
                            .rotationEffect(.degrees(viewModel.bottleRotation))
                            .animation(.easeInOut(duration: 3), value: viewModel.bottleRotation)
                    }
                    .frame(width: 300, height: 300)
                    
                    Spacer()
                    
                    // Результат
                    if let selectedPlayer = viewModel.selectedPlayer {
                        VStack(spacing: 12) {
                            Text("Выпало на:")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Text(selectedPlayer.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#E84E1B"))
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(12)
                    }
                    
                    // Кнопка вращения
                    Button(action: {
                        viewModel.spinBottle()
                    }) {
                        Text(viewModel.isSpinning ? "Крутится..." : "КРУТИТЬ БУТЫЛКУ")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(viewModel.isSpinning ? Color.gray : Color(hex: "#E84E1B"))
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.isSpinning)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Бутылочка")
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
}

// MARK: - Player Circle View
struct PlayerCircleView: View {
    let player: BottlePlayer
    let angle: Double
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(Color(hex: "#1B2A6B").opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(player.name.prefix(1))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                )
            
            Text(player.name)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
        }
        .offset(
            x: cos(angle * .pi / 180) * 120,
            y: sin(angle * .pi / 180) * 120
        )
    }
}

// MARK: - Bottle ViewModel
@MainActor
class BottleViewModel: ObservableObject {
    @Published var players: [BottlePlayer] = []
    @Published var bottleRotation: Double = 0
    @Published var isSpinning = false
    @Published var selectedPlayer: BottlePlayer?
    
    init() {
        // Mock игроки
        players = [
            BottlePlayer(id: "1", name: "Айдай"),
            BottlePlayer(id: "2", name: "Бекжан"),
            BottlePlayer(id: "3", name: "Динара"),
            BottlePlayer(id: "4", name: "Эркин"),
            BottlePlayer(id: "5", name: "Жанара"),
            BottlePlayer(id: "6", name: "Нурбек")
        ]
    }
    
    // MARK: - Angle for Player
    func angleForPlayer(index: Int) -> Double {
        let anglePerPlayer = 360.0 / Double(players.count)
        return Double(index) * anglePerPlayer - 90 // -90 чтобы первый был сверху
    }
    
    // MARK: - Spin Bottle
    func spinBottle() {
        guard !isSpinning else { return }
        
        isSpinning = true
        selectedPlayer = nil
        
        // Случайное вращение (3-5 полных оборотов + случайный угол)
        let fullRotations = Double.random(in: 3...5)
        let randomAngle = Double.random(in: 0...360)
        bottleRotation += (fullRotations * 360) + randomAngle
        
        // Через 3 секунды определяем результат
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.determineSelectedPlayer()
            self.isSpinning = false
        }
    }
    
    // MARK: - Determine Selected Player
    private func determineSelectedPlayer() {
        let normalizedRotation = bottleRotation.truncatingRemainder(dividingBy: 360)
        let anglePerPlayer = 360.0 / Double(players.count)
        
        // Определить на кого указывает бутылка (с учётом что 0° = вверх)
        var selectedIndex = Int((normalizedRotation + anglePerPlayer / 2) / anglePerPlayer)
        selectedIndex = selectedIndex % players.count
        
        selectedPlayer = players[selectedIndex]
    }
}

// MARK: - Bottle Player
struct BottlePlayer: Identifiable {
    let id: String
    let name: String
}

#Preview {
    BottleView()
}
