//
//  DailyChallengeView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct DailyChallengeView: View {
    let challenge: DailyChallenge?
    @ObservedObject var viewModel: BreakViewModel
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var isCorrect = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "#F5F5F5").ignoresSafeArea()
            
            if let challenge = challenge {
                if showResult {
                    // Результат
                    VStack(spacing: 24) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(isCorrect ? .green : .red)
                        
                        Text(isCorrect ? "Правильно!" : "Неправильно")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                        
                        if isCorrect {
                            Text("+\(challenge.rewardPoints) баллов")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#FFE600"))
                        } else {
                            Text("Правильный ответ: \(challenge.question.correctAnswer)")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        
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
                    }
                } else {
                    // Вопрос
                    ScrollView {
                        VStack(spacing: 24) {
                            // Заголовок
                            VStack(spacing: 8) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(hex: "#E84E1B"))
                                
                                Text("ВЫЗОВ ДНЯ")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#1B2A6B"))
                                
                                Text("\(challenge.participantsCount) участников")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 40)
                            
                            // Вопрос
                            Text(challenge.question.questionText ?? "")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#1B2A6B"))
                                .multilineTextAlignment(.center)
                                .padding(24)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(16)
                            
                            // Варианты
                            VStack(spacing: 12) {
                                DailyChallengeAnswerButton(
                                    letter: "А",
                                    text: challenge.question.optionA,
                                    isSelected: selectedAnswer == "A",
                                    action: { selectedAnswer = "A" }
                                )
                                
                                DailyChallengeAnswerButton(
                                    letter: "Б",
                                    text: challenge.question.optionB,
                                    isSelected: selectedAnswer == "B",
                                    action: { selectedAnswer = "B" }
                                )
                                
                                DailyChallengeAnswerButton(
                                    letter: "В",
                                    text: challenge.question.optionC,
                                    isSelected: selectedAnswer == "C",
                                    action: { selectedAnswer = "C" }
                                )
                                
                                DailyChallengeAnswerButton(
                                    letter: "Г",
                                    text: challenge.question.optionD,
                                    isSelected: selectedAnswer == "D",
                                    action: { selectedAnswer = "D" }
                                )
                            }
                            
                            // Кнопка ответа
                            Button(action: submitAnswer) {
                                Text("ОТВЕТИТЬ")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(selectedAnswer != nil ? Color(hex: "#E84E1B") : Color.gray)
                                    .cornerRadius(12)
                            }
                            .disabled(selectedAnswer == nil)
                        }
                        .padding(20)
                    }
                }
            }
        }
        .navigationTitle("Вызов дня")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func submitAnswer() {
        guard let answer = selectedAnswer else { return }
        isCorrect = viewModel.submitDailyChallenge(answer: answer)
        withAnimation {
            showResult = true
        }
    }
}

// MARK: - Daily Challenge Answer Button
struct DailyChallengeAnswerButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(letter)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : Color(hex: "#1B2A6B"))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? Color(hex: "#E84E1B") : Color(hex: "#F5F5F5"))
                    )
                
                Text(text)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(isSelected ? Color(hex: "#E84E1B").opacity(0.1) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "#E84E1B") : Color.gray.opacity(0.2), lineWidth: 2)
            )
        }
    }
}

#Preview {
    NavigationStack {
        DailyChallengeView(
            challenge: DailyChallenge(
                id: "test",
                date: Date(),
                question: Question(
                    id: "q1",
                    lessonId: "daily",
                    order: 1,
                    type: .text,
                    questionText: "Сколько планет в Солнечной системе?",
                    questionImageURL: nil,
                    optionA: "7",
                    optionB: "8",
                    optionC: "9",
                    optionD: "10",
                    correctAnswer: "B"
                ),
                participantsCount: 1523,
                rewardPoints: 10
            ),
            viewModel: BreakViewModel()
        )
    }
}
