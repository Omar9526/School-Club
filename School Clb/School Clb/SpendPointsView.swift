//
//  SpendPointsView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct SpendPointsView: View {
    @ObservedObject var viewModel: MovementViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var selectedCategory: SpendCategory?
    
    let spendOptions: [(category: SpendCategory, icon: String, color: String, points: Int, description: String)] = [
        (.partners, "bag.fill", "#007AFF", 50, "Скидки от партнёров"),
        (.giveToGroup, "person.3.fill", "#34C759", 20, "Поддержите группу"),
        (.raffle, "gift.fill", "#FFE600", 100, "Участие в розыгрыше"),
        (.merch, "books.vertical.fill", "#AF52DE", 150, "Книги и мерч SC"),
        (.charity, "heart.fill", "#E84E1B", 30, "Помочь нуждающимся"),
        (.discount, "percent", "#1B2A6B", 200, "Скидка на подписку")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Баланс
                    balanceCard
                    
                    // Сетка опций
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(spendOptions, id: \.category) { option in
                            SpendOptionCard(
                                title: option.category.rawValue,
                                icon: option.icon,
                                color: option.color,
                                points: option.points,
                                description: option.description,
                                canAfford: viewModel.userPoints >= option.points
                            ) {
                                handleSpend(option.category, points: option.points)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Потратить баллы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Balance Card
    private var balanceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Ваш баланс")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "#FFE600"))
                    
                    Text("\(viewModel.userPoints)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    Text("баллов")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // MARK: - Handle Spend
    private func handleSpend(_ category: SpendCategory, points: Int) {
        guard viewModel.userPoints >= points else {
            alertTitle = "Недостаточно баллов"
            alertMessage = "Вам нужно ещё \(points - viewModel.userPoints) баллов для этой покупки."
            showAlert = true
            return
        }
        
        selectedCategory = category
        
        switch category {
        case .partners:
            alertTitle = "Партнёры"
            alertMessage = "Вы получили промокод на скидку 15% в книжном магазине 'Раритет'!"
        case .giveToGroup:
            alertTitle = "Отдать группе"
            alertMessage = "20 баллов добавлено в копилку вашей группы!"
        case .raffle:
            alertTitle = "Розыгрыш"
            alertMessage = "Вы участвуете в розыгрыше iPhone 15! Результаты 30 июня."
        case .merch:
            alertTitle = "Книги и мерч"
            alertMessage = "Выберите товар в каталоге. Ссылка отправлена вам на email."
        case .charity:
            alertTitle = "Благотворительность"
            alertMessage = "Спасибо за помощь! 30 баллов переведено в детский дом."
        case .discount:
            alertTitle = "Скидка на подписку"
            alertMessage = "Вы получили скидку 50% на годовую подписку!"
        }
        
        do {
            try viewModel.spendPoints(points, on: category)
            showAlert = true
        } catch {
            alertTitle = "Ошибка"
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
}

// MARK: - Spend Option Card
struct SpendOptionCard: View {
    let title: String
    let icon: String
    let color: String
    let points: Int
    let description: String
    let canAfford: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Иконка
                ZStack {
                    Circle()
                        .fill(Color(hex: color).opacity(canAfford ? 0.2 : 0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: color).opacity(canAfford ? 1.0 : 0.5))
                }
                
                // Название
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(canAfford ? Color(hex: "#1B2A6B") : Color.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Описание
                Text(description)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Spacer()
                
                // Цена
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#FFE600"))
                    
                    Text("\(points)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(canAfford ? Color(hex: "#1B2A6B") : Color.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#FFE600").opacity(canAfford ? 0.2 : 0.1))
                .cornerRadius(8)
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(canAfford ? Color(hex: color).opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 2)
            )
            .opacity(canAfford ? 1.0 : 0.6)
        }
        .disabled(!canAfford)
    }
}

#Preview {
    SpendPointsView(viewModel: MovementViewModel())
}
