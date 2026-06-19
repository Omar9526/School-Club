//
//  PremiumView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct PremiumView: View {
    @StateObject private var viewModel = PaymentViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: SubscriptionTier = .student
    @State private var showPaymentWeb = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Заголовок
                    headerSection
                    
                    // Тарифы
                    tiersSection
                    
                    // Кнопка оплаты (только для PRO)
                    if selectedTier == .pro {
                        paymentButton
                    } else {
                        infoButton
                    }
                }
                .padding(20)
                .padding(.bottom, 100) // Отступ снизу, чтобы контент не перекрывался таб-баром
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Тарифы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showPaymentWeb) {
            if let plan = viewModel.selectedPlan {
                PaymentWebView(plan: plan, viewModel: viewModel)
            }
        }
        .alert("Успех!", isPresented: $viewModel.showSuccess) {
            Button("Отлично!") {
                dismiss()
            }
        } message: {
            Text("Вы успешно оформили PRO подписку!")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Иконка с анимацией
            ZStack {
                // Внешнее свечение
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "#FFE600").opacity(0.3),
                                Color(hex: "#E84E1B").opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 70
                        )
                    )
                    .frame(width: 140, height: 140)
                
                // Основной круг с градиентом
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FFE600"), Color(hex: "#E84E1B")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color(hex: "#FFE600").opacity(0.4), radius: 15, x: 0, y: 5)
                
                // Иконка короны
                Image(systemName: "crown.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
            }
            
            VStack(spacing: 10) {
                Text("Выберите тариф")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Разные уровни доступа для разных потребностей")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Tiers Section
    private var tiersSection: some View {
        VStack(spacing: 16) {
            Text("ВЫБЕРИТЕ ТАРИФ")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // BASE
            TierCard(
                tier: .base,
                isSelected: selectedTier == .base
            ) {
                selectedTier = .base
            }
            
            // STUDENT
            TierCard(
                tier: .student,
                isSelected: selectedTier == .student,
                isRecommended: true
            ) {
                selectedTier = .student
            }
            
            // PRO
            TierCard(
                tier: .pro,
                isSelected: selectedTier == .pro
            ) {
                selectedTier = .pro
                viewModel.selectedPlan = viewModel.monthlyPlan
            }
        }
    }
    
    // MARK: - Payment Button
    private var paymentButton: some View {
        VStack(spacing: 12) {
            // Выбор периода (только для PRO)
            HStack(spacing: 12) {
                ForEach([viewModel.monthlyPlan, viewModel.ortPlan], id: \.id) { plan in
                    Button(action: {
                        viewModel.selectedPlan = plan
                    }) {
                        VStack(spacing: 4) {
                            Text(plan.title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(viewModel.selectedPlan?.id == plan.id ? .white : .primary)
                            
                            Text("\(plan.price) с")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.selectedPlan?.id == plan.id ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedPlan?.id == plan.id ? Color(hex: "#E84E1B") : Color(uiColor: .systemBackground))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E84E1B"), lineWidth: 2)
                        )
                    }
                }
            }
            
            Button(action: {
                showPaymentWeb = true
            }) {
                HStack {
                    if viewModel.isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("ОПЛАТИТЬ \(viewModel.selectedPlan?.price ?? 0) сом")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#FFE600"), Color(hex: "#E84E1B")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(viewModel.isProcessing)
        }
    }
    
    // MARK: - Info Button
    private var infoButton: some View {
        VStack(spacing: 12) {
            if selectedTier == .base {
                Text("Тариф BASE доступен автоматически при регистрации")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
            } else if selectedTier == .student {
                VStack(spacing: 12) {
                    Text("Тариф STUDENT доступен только для студентов School Club")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Link(destination: URL(string: "https://schoolclub.kg/enroll")!) {
                        HStack {
                            Image(systemName: "link")
                            Text("Записаться в School Club")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "#2196F3"))
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
        }
    }
}

// MARK: - Benefit Row
struct BenefitRow: View {
    let icon: String
    let text: String
    let color: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: color))
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Tier Card
struct TierCard: View {
    let tier: SubscriptionTier
    let isSelected: Bool
    var isRecommended: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Заголовок с градиентом
                ZStack(alignment: .topTrailing) {
                    HStack(spacing: 14) {
                        // Иконка с градиентным фоном
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: tier.color).opacity(0.2),
                                            Color(hex: tier.color).opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            
                            Image(systemName: tier.iconName)
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(Color(hex: tier.color))
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text(tier.displayName)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text(tier.description)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                    
                    // Бейдж "Для студентов"
                    if isRecommended {
                        VStack(spacing: 0) {
                            Text("ДЛЯ СТУДЕНТОВ")
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: "#2196F3"), Color(hex: "#1976D2")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8, corners: [.bottomLeft, .topRight])
                        }
                        .offset(x: 20, y: -20)
                    }
                }
                .padding(20)
                
                // Разделитель с градиентом
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: tier.color).opacity(0.3),
                                Color(hex: tier.color).opacity(0.1),
                                Color(hex: tier.color).opacity(0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 20)
                
                // Функции
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(tier.features, id: \.self) { feature in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: tier.color))
                            
                            Text(feature)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
                
                // Футер с ценой
                HStack(spacing: 12) {
                    if tier == .base {
                        HStack(spacing: 6) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "#34C759"))
                            
                            Text("Бесплатно")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#34C759"))
                        }
                    } else if tier == .student {
                        HStack(spacing: 6) {
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "#2196F3"))
                            
                            Text("Только для студентов")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#2196F3"))
                        }
                    } else if tier == .pro {
                        HStack(spacing: 4) {
                            Text("От")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text("500 с")
                                .font(.system(size: 24, weight: .black, design: .rounded))
                                .foregroundColor(Color(hex: tier.color))
                            
                            Text("/ месяц")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        ZStack {
                            Circle()
                                .fill(Color(hex: tier.color))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(
                ZStack {
                    // Основной фон
                    Color(uiColor: .systemBackground)
                    
                    // Тонкий градиент сверху для эффекта глубины
                    if isSelected {
                        LinearGradient(
                            colors: [
                                Color(hex: tier.color).opacity(0.03),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected
                        ? LinearGradient(
                            colors: [Color(hex: tier.color), Color(hex: tier.color).opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: isSelected ? 2.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? Color(hex: tier.color).opacity(0.25) : Color.black.opacity(0.05),
                radius: isSelected ? 12 : 4,
                x: 0,
                y: isSelected ? 6 : 2
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(TierCardButtonStyle())
    }
}

// Кастомный стиль кнопки для плавной анимации
struct TierCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// Extension для закругления отдельных углов
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Plan Card
struct PlanCard: View {
    let plan: PremiumPlan
    let isSelected: Bool
    var isRecommended: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Заголовок
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                        
                        Text(plan.duration)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if isRecommended {
                        Text("ВЫГОДНО")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#E84E1B"))
                            .cornerRadius(8)
                    }
                }
                
                // Цена
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    if plan.hasDiscount, let original = plan.originalPrice {
                        Text("\(original) с")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .strikethrough()
                    }
                    
                    Text("\(plan.price) с")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    if plan.hasDiscount {
                        Text("-\(plan.discountPercentage)%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#E84E1B"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: "#E84E1B").opacity(0.1))
                            .cornerRadius(6)
                    }
                }
                
                Divider()
                
                // Преимущества
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(plan.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "#34C759"))
                            
                            Text(feature)
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color(hex: "#FFE600") : Color.gray.opacity(0.2),
                        lineWidth: isSelected ? 3 : 1
                    )
            )
            .shadow(color: isSelected ? Color(hex: "#FFE600").opacity(0.3) : Color.clear, radius: 8)
        }
    }
}

#Preview {
    PremiumView()
}
