//
//  VideoLessonView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import AVKit

struct VideoLessonView: View {
    let lesson: Lesson
    let isTheory: Bool
    
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentScale: CGFloat = 1.0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Видео плеер
                ZStack {
                    if let player = player {
                        VideoPlayer(player: player)
                            .frame(height: 250)
                            .scaleEffect(currentScale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        currentScale = min(max(value, 1.0), 3.0)
                                    }
                            )
                            .onAppear {
                                // Запрет скриншотов (для защиты контента)
                                setupScreenshotPrevention()
                            }
                    } else {
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 250)
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                            )
                    }
                }
                
                // Описание урока
                VStack(alignment: .leading, spacing: 16) {
                    Text(lesson.title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    if isTheory {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(Color(hex: "#1B2A6B"))
                            Text("Теоретический урок")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "eye.fill")
                                .foregroundColor(Color(hex: "#E84E1B"))
                            Text("Видеоразбор теста")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    Text(lesson.description)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                    
                    // Предупреждение о защите контента
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .foregroundColor(Color(hex: "#E84E1B"))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Защита контента")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                            
                            Text("Скриншоты и запись видео запрещены")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "#E84E1B").opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(20)
            }
        }
        .background(Color(hex: "#F5F5F5"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    // MARK: - Setup Player
    private func setupPlayer() {
        guard let videoURL = lesson.videoURL,
              let url = URL(string: videoURL) else {
            return
        }
        
        player = AVPlayer(url: url)
    }
    
    // MARK: - Screenshot Prevention
    private func setupScreenshotPrevention() {
        // Обнаружение скриншотов
        NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Показываем предупреждение пользователю
            print("⚠️ Screenshot detected! This is protected content.")
            // TODO: Можно показать alert или отправить уведомление на сервер
        }
    }
}

#Preview {
    NavigationStack {
        VideoLessonView(
            lesson: Lesson(
                id: "1",
                levelId: "1",
                title: "Сабак 1",
                order: 1,
                isFree: true,
                isPracticeTest: false,
                videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                description: "Это описание урока. Здесь будет подробная информация о том, что вы изучите в этом уроке.",
                subject: .text
            ),
            isTheory: true
        )
    }
}
