//
//  AuthView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: AuthTab = .login
    @State private var refreshView = false
    @State private var showLanguageSelector = !UserDefaults.standard.bool(forKey: "languageSelected")
    @Namespace private var animation
    
    enum AuthTab {
        case login, register
    }
    
    var loginTabText: String {
        AppLanguage.current == "RU" ? "ВХОД" : "КИРҮҮ"
    }
    
    var registerTabText: String {
        AppLanguage.current == "RU" ? "РЕГИСТРАЦИЯ" : "КАТТОО"
    }
    
    var errorTitle: String {
        AppLanguage.current == "RU" ? "Ошибка" : "Ката"
    }
    
    var closeButton: String {
        AppLanguage.current == "RU" ? "Закрыть" : "Жабуу"
    }
    
    var body: some View {
        ZStack {
            if showLanguageSelector {
                LanguageSelectorView(showLanguageSelector: $showLanguageSelector)
                    .transition(.opacity)
            } else {
                mainAuthView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showLanguageSelector)
    }
    
    private var mainAuthView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Кнопка смены языка
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            showLanguageSelector = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                            Text(AppLanguage.current)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(Color(hex: "#1B2A6B"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#F0F4FF"))
                        .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Логотип
                logoView
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                
                // Переключатель вкладок
                tabSelector
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                
                // Контент
                TabView(selection: $selectedTab) {
                    LoginView()
                        .tag(AuthTab.login)
                    
                    RegisterView()
                        .tag(AuthTab.register)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
            }
            
            // Loading overlay
            if authViewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color(hex: "#E84E1B"))
            }
        }
        .alert(errorTitle, isPresented: .constant(authViewModel.errorMessage != nil)) {
            Button(closeButton, role: .cancel) {
                authViewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .id(refreshView)
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshView.toggle()
        }
    }
    
    // MARK: - Логотип
    private var logoView: some View {
        HStack(spacing: 0) {
            Text("school")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#E84E1B"))
            
            Text("club")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#1B2A6B"))
        }
    }
    
    // MARK: - Переключатель вкладок
    private var tabSelector: some View {
        HStack(spacing: 0) {
            // Кнопка входа
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .login
                }
            } label: {
                VStack(spacing: 8) {
                    Text(loginTabText)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedTab == .login ? Color(hex: "#E84E1B") : Color.gray)
                    
                    if selectedTab == .login {
                        Rectangle()
                            .fill(Color(hex: "#E84E1B"))
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "tab", in: animation)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 3)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // ⭐ Вся область кликабельна!
            .buttonStyle(.plain) // ⭐ Убирает стандартное поведение кнопки
            
            // Разделитель
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 30)
            
            // Кнопка регистрации
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = .register
                }
            } label: {
                VStack(spacing: 8) {
                    Text(registerTabText)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedTab == .register ? Color(hex: "#E84E1B") : Color.gray)
                    
                    if selectedTab == .register {
                        Rectangle()
                            .fill(Color(hex: "#E84E1B"))
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "tab", in: animation)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 3)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // ⭐ Вся область кликабельна!
            .buttonStyle(.plain) // ⭐ Убирает стандартное поведение кнопки
        }
        .frame(height: 50)
    }
}

// MARK: - LoginView
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var phoneNumber = "+996"
    @State private var password = ""
    
    var loginFormTitle: String {
        AppLanguage.current == "RU" ? "Форма входа" : "Кирүү формасы"
    }
    
    var phonePlaceholder: String {
        AppLanguage.current == "RU" ? "Телефон" : "Телефон"
    }
    
    var passwordPlaceholder: String {
        AppLanguage.current == "RU" ? "Пароль" : "Сыр сөз"
    }
    
    var loginButtonText: String {
        AppLanguage.current == "RU" ? "ВОЙТИ" : "КИРҮҮ"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(loginFormTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                TextField(phonePlaceholder, text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(hex: "#F0F4FF"))
                    .cornerRadius(16)
                
                SecureField(passwordPlaceholder, text: $password)
                    .padding()
                    .background(Color(hex: "#F0F4FF"))
                    .cornerRadius(16)
                
                Button {
                    Task {
                        await authViewModel.login(phoneNumber: phoneNumber, password: password)
                    }
                } label: {
                    Text(loginButtonText)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#E84E1B"))
                        .cornerRadius(16)
                }
                .buttonStyle(.plain) // ⭐ Фикс кнопки!
                .disabled(authViewModel.isLoading)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - RegisterView
struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var phoneNumber = "+996"
    @State private var fullName = ""
    @State private var password = ""
    
    var registerFormTitle: String {
        AppLanguage.current == "RU" ? "Форма регистрации" : "Катталуу формасы"
    }
    
    var phonePlaceholder: String {
        AppLanguage.current == "RU" ? "Телефон" : "Телефон"
    }
    
    var fullNamePlaceholder: String {
        AppLanguage.current == "RU" ? "ФИО" : "Толук аты"
    }
    
    var passwordPlaceholder: String {
        AppLanguage.current == "RU" ? "Пароль" : "Сыр сөз"
    }
    
    var registerButtonText: String {
        AppLanguage.current == "RU" ? "ЗАРЕГИСТРИРОВАТЬСЯ" : "КАТТАЛУУ"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(registerFormTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#1B2A6B"))
                
                TextField(phonePlaceholder, text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .padding()
                    .background(Color(hex: "#F0F4FF"))
                    .cornerRadius(16)
                
                TextField(fullNamePlaceholder, text: $fullName)
                    .padding()
                    .background(Color(hex: "#F0F4FF"))
                    .cornerRadius(16)
                
                SecureField(passwordPlaceholder, text: $password)
                    .padding()
                    .background(Color(hex: "#F0F4FF"))
                    .cornerRadius(16)
                
                Button {
                    Task {
                        await authViewModel.register(phoneNumber: phoneNumber, fullName: fullName, password: password)
                    }
                } label: {
                    Text(registerButtonText)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#E84E1B"))
                        .cornerRadius(16)
                }
                .buttonStyle(.plain) // ⭐ Фикс кнопки!
                .disabled(authViewModel.isLoading)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Language Selector View
struct LanguageSelectorView: View {
    @Binding var showLanguageSelector: Bool
    @State private var selectedLanguage = AppLanguage.current
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Логотип
                HStack(spacing: 0) {
                    Text("school")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#E84E1B"))
                    
                    Text("club")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                }
                
                // Заголовок
                VStack(spacing: 12) {
                    Text("Тилди тандаңыз")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                    
                    Text("Выберите язык")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#1B2A6B"))
                }
                
                // Кнопки выбора языка
                VStack(spacing: 16) {
                    // Кыргызский
                    Button {
                        selectedLanguage = "KG"
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🇰🇬 Кыргызча")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                
                                Text("Кыргыз тилинде")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if selectedLanguage == "KG" {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: "#E84E1B"))
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                        }
                        .foregroundColor(Color(hex: "#1B2A6B"))
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedLanguage == "KG" ? Color(hex: "#FFE600").opacity(0.2) : Color(hex: "#F0F4FF"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedLanguage == "KG" ? Color(hex: "#E84E1B") : Color.clear, lineWidth: 3)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Русский
                    Button {
                        selectedLanguage = "RU"
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("🇷🇺 Русский")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                
                                Text("На русском языке")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if selectedLanguage == "RU" {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(hex: "#E84E1B"))
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray.opacity(0.3))
                            }
                        }
                        .foregroundColor(Color(hex: "#1B2A6B"))
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedLanguage == "RU" ? Color(hex: "#FFE600").opacity(0.2) : Color(hex: "#F0F4FF"))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(selectedLanguage == "RU" ? Color(hex: "#E84E1B") : Color.clear, lineWidth: 3)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Кнопка продолжить
                Button {
                    AppLanguage.current = selectedLanguage
                    UserDefaults.standard.set(true, forKey: "languageSelected")
                    withAnimation {
                        showLanguageSelector = false
                    }
                } label: {
                    Text(selectedLanguage == "RU" ? "ПРОДОЛЖИТЬ" : "УЛАНТУУ")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#E84E1B"))
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
