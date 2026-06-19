//
//  MovementView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct MovementView: View {
    @StateObject private var viewModel = MovementViewModel()
    @StateObject private var pointsService = PointsService.shared
    @State private var showSpendPoints = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // А) ПРОГРЕСС
                    progressSection
                    
                    // Б) БАЛЛЫ
                    pointsCard
                    
                    // В) АКТИВНОСТИ
                    activitiesSection
                }
                .padding(20)
            }
            .background(Color(hex: "#F5F5F5"))
            .navigationTitle("Движ")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.refresh()
            }
        }
        .sheet(isPresented: $showSpendPoints) {
            SpendPointsView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.recordActivity()
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Text("ПРОГРЕСС")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                Spacer()
            }
            
            // Рейтинг активности
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Активность")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.activityRating * 100))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#FFE600"))
                }
                
                // Анимированный прогресс-бар
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .cornerRadius(6)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "#FFE600"), Color(hex: "#E84E1B")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.activityRating, height: 12)
                            .cornerRadius(6)
                            .animation(.spring(duration: 1.0), value: viewModel.activityRating)
                    }
                }
                .frame(height: 12)
            }
            
            Divider()
            
            // Место в рейтинге
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ваше место")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 8) {
                        Text("#\(viewModel.userRank)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                        
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Всего пользователей")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Text("\(viewModel.totalUsers)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Points Card
    private var pointsCard: some View {
        VStack(spacing: 16) {
            // Счётчик баллов
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("ЗАРАБОТАНО БАЛЛОВ")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color(hex: "#FFE600"))
                        
                        Text("\(pointsService.currentPoints)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                    }
                }
                
                Spacer()
            }
            
            // Кнопка траты баллов
            Button(action: {
                showSpendPoints = true
            }) {
                HStack {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 18))
                    
                    Text("ПОТРАТИТЬ БАЛЛЫ")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(hex: "#E84E1B"))
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(hex: "#FFE600").opacity(0.15), Color(hex: "#FFE600").opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#FFE600").opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Activities Section
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("АКТИВНОСТИ")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            ForEach(viewModel.announcements) { announcement in
                AnnouncementCard(announcement: announcement)
            }
        }
    }
}

// MARK: - Announcement Card
struct AnnouncementCard: View {
    let announcement: Announcement
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(hex: announcement.type.color).opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: announcement.type.icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: announcement.type.color))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(announcement.type.rawValue)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: announcement.type.color))
                    
                    Text(announcement.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text(announcement.timeAgo)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            // Тело
            Text(announcement.body)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            
            // Изображение (если есть)
            if let imageURL = announcement.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 150)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

#Preview {
    MovementView()
}
