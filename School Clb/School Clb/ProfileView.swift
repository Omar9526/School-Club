//
//  ProfileView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false
    @State private var showEditorDashboard = false
    @State private var selectedLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "KG"
    @State private var refreshView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // ШАПКА
                    profileHeader
                    
                    // ПОДПИСКА
                    subscriptionCard
                    
                    // АККАУНТ
                    accountSection
                    
                    // ДОКУМЕНТЫ
                    documentsSection
                    
                    // ЯЗЫК
                    languageSection
                    
                    // ВЫХОД
                    signOutButton
                    
                    // ВЕРСИЯ
                    versionText
                }
                .padding(.vertical, 20)
                .padding(.bottom, 90) // ✅ Отступ под плавающий таб-бар
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(L10n.profile)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $showEditorDashboard) {
                EditorDashboardView()
            }
            .id(refreshView)
            .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
                refreshView.toggle()
            }
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            // Аватарка
            if let avatarImage = viewModel.getAvatarImage() {
                Image(uiImage: avatarImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else if let avatarURL = viewModel.user?.avatarURL, let url = URL(string: avatarURL), avatarURL != "local://avatar" {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(hex: "#1B2A6B").opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Color(hex: "#1B2A6B"))
                    )
            }
            
            // Никнейм
            if let user = viewModel.user {
                Text("@\(user.username)")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Subscription Card
    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Текущий тариф
            HStack(spacing: 12) {
                Image(systemName: viewModel.user?.subscriptionTier.iconName ?? "star")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: viewModel.user?.subscriptionTier.color ?? "#9E9E9E"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.user?.subscriptionTier.displayName ?? "BASE")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(viewModel.user?.subscriptionTier.description ?? "")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Бейдж тарифа
                Text(viewModel.user?.subscriptionTier.displayName ?? "BASE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(hex: viewModel.user?.subscriptionTier.color ?? "#9E9E9E"))
                    .cornerRadius(6)
            }
            
            // Если не PRO - показываем кнопку улучшения
            if viewModel.user?.subscriptionTier != .pro {
                NavigationLink(destination: PremiumView()) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                        Text(viewModel.user?.subscriptionTier == .base ? "Улучшить подписку" : "Перейти на PRO")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#E84E1B"), Color(hex: "#FF6B35")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                }
            }
            
            // Дата окончания для PRO
            if let premiumUntil = viewModel.user?.premiumUntil, viewModel.user?.subscriptionTier == .pro {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("Активен до \(formattedDate(premiumUntil))")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(spacing: 0) {
            Text(L10n.account)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                Button(action: {
                    showEditProfile = true
                }) {
                    HStack {
                        Image(systemName: "person.circle")
                            .foregroundColor(.primary)
                        Text(L10n.editProfile)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                }
                
                Divider()
                    .padding(.leading, 52)
                
                // Панель редактора (только для суперадмина)
                if viewModel.user?.role == .superadmin {
                    Button(action: {
                        showEditorDashboard = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.key.fill")
                                .foregroundColor(Color(hex: "#E84E1B"))
                            Text(L10n.editorPanel)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#E84E1B"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                    }
                    
                    Divider()
                        .padding(.leading, 52)
                }
                
                Link(destination: URL(string: "mailto:support@schoolclub.kg")!) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.primary)
                        Text(L10n.getHelp)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                }
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Documents Section
    private var documentsSection: some View {
        VStack(spacing: 0) {
            Text(L10n.documents)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            
            VStack(spacing: 0) {
                Link(destination: URL(string: "https://schoolclub.kg/terms")!) {
                    documentRow(icon: "doc.text", title: L10n.publicOffer)
                }
                
                Divider()
                    .padding(.leading, 52)
                
                Link(destination: URL(string: "https://schoolclub.kg/privacy")!) {
                    documentRow(icon: "lock.shield", title: L10n.privacyPolicy)
                }
                
                Divider()
                    .padding(.leading, 52)
                
                Link(destination: URL(string: "https://schoolclub.kg/about")!) {
                    documentRow(icon: "info.circle", title: L10n.aboutCompany)
                }
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    private func documentRow(icon: String, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Language Section
    private var languageSection: some View {
        VStack(spacing: 8) {
            Text(L10n.language)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            HStack {
                Text(L10n.languageLabel)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Picker("", selection: $selectedLanguage) {
                    Text("KG").tag("KG")
                    Text("RU").tag("RU")
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
                .onChange(of: selectedLanguage) { oldValue, newValue in
                    AppLanguage.current = newValue
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Sign Out Button
    private var signOutButton: some View {
        Button(action: {
            do {
                try viewModel.signOut()
                authViewModel.signOut()
            } catch {
                print("Sign out error: \(error)")
            }
        }) {
            Text(L10n.signOut)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Version Text
    private var versionText: some View {
        Text("\(L10n.version) 1.0.0")
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .foregroundColor(.secondary)
            .padding(.top, 8)
            .padding(.bottom, 40)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
