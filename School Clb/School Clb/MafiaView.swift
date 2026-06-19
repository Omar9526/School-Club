//
//  MafiaView.swift
//  School Club
//
//  Created on 16.06.2026
//

import SwiftUI
import Combine

/// Игра "Мафия" — классическая психологическая игра
/// Роли: мафия, мирный, доктор, шериф
/// Смена дня и ночи, голосование
/// TODO: Полная реализация требует сложной логики
struct MafiaView: View {
    @StateObject private var viewModel = MafiaViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F5F5F5").ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Заглушка
                    VStack(spacing: 20) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 100))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                        
                        Text("Игра «Мафия»")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                        
                        Text("В разработке")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Планируется:")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.gray)
                            
                            RuleRow(text: "Роли: Мафия, Мирный, Доктор, Шериф")
                            RuleRow(text: "Смена дня и ночи")
                            RuleRow(text: "Голосование игроков")
                            RuleRow(text: "Детективное расследование")
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Text("Назад")
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
            }
            .navigationTitle("Мафия")
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

// MARK: - Mafia ViewModel
class MafiaViewModel: ObservableObject {
    @Published var gameStarted = false
    
    // TODO: Реализация логики игры Мафия
    // - Раздача ролей (мафия, мирный, доктор, шериф)
    // - Смена фаз (ночь/день)
    // - Действия ролей (мафия убивает, доктор лечит, шериф проверяет)
    // - Голосование днём
    // - Определение победителя
}

#Preview {
    MafiaView()
}
