//
//  EditProfileView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var fullName = ""
    @State private var username = ""
    @State private var district = ""
    @State private var school = ""
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showPasswordSection = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            Form {
                // ФОТО ПРОФИЛЯ
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let avatarURL = viewModel.user?.avatarURL, let url = URL(string: avatarURL) {
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
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color(hex: "#1B2A6B").opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color(hex: "#1B2A6B"))
                                    )
                            }
                            
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Text("Изменить фото")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(hex: "#1B2A6B"))
                            }
                            .onChange(of: selectedPhoto) { oldValue, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        selectedImage = uiImage
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
                
                // ЛИЧНЫЕ ДАННЫЕ
                Section(header: Text("ЛИЧНЫЕ ДАННЫЕ")) {
                    TextField("Полное имя", text: $fullName)
                        .textContentType(.name)
                    
                    TextField("Никнейм", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                    
                    TextField("Район", text: $district)
                    
                    TextField("Школа", text: $school)
                }
                
                // ПАРОЛЬ
                Section(header: Text("ИЗМЕНИТЬ ПАРОЛЬ")) {
                    Toggle("Изменить пароль", isOn: $showPasswordSection)
                    
                    if showPasswordSection {
                        SecureField("Текущий пароль", text: $currentPassword)
                            .textContentType(.password)
                        
                        SecureField("Новый пароль", text: $newPassword)
                            .textContentType(.newPassword)
                        
                        SecureField("Подтвердить пароль", text: $confirmPassword)
                            .textContentType(.newPassword)
                    }
                }
            }
            .navigationTitle("Редактировать профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        Task {
                            await saveProfile()
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .alert("Ошибка", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                loadCurrentData()
            }
        }
    }
    
    // MARK: - Load Current Data
    private func loadCurrentData() {
        guard let user = viewModel.user else { return }
        fullName = user.fullName
        username = user.username
        district = user.district
        school = user.school
    }
    
    // MARK: - Save Profile
    private func saveProfile() async {
        isSaving = true
        defer { isSaving = false }
        
        // Валидация
        guard !fullName.isEmpty, !username.isEmpty else {
            errorMessage = "Заполните все обязательные поля"
            showError = true
            return
        }
        
        // Загрузка аватарки (если выбрана)
        if let image = selectedImage {
            do {
                _ = try await viewModel.uploadAvatar(image)
            } catch {
                errorMessage = "Ошибка загрузки фото: \(error.localizedDescription)"
                showError = true
                return
            }
        }
        
        // Обновление профиля
        do {
            try await viewModel.updateProfile(
                fullName: fullName,
                username: username,
                district: district,
                school: school
            )
        } catch {
            errorMessage = "Ошибка сохранения: \(error.localizedDescription)"
            showError = true
            return
        }
        
        // Изменение пароля (если нужно)
        if showPasswordSection {
            guard newPassword == confirmPassword else {
                errorMessage = "Пароли не совпадают"
                showError = true
                return
            }
            
            guard newPassword.count >= 6 else {
                errorMessage = "Пароль должен быть минимум 6 символов"
                showError = true
                return
            }
            
            do {
                try await viewModel.changePassword(
                    currentPassword: currentPassword,
                    newPassword: newPassword
                )
            } catch {
                errorMessage = "Ошибка изменения пароля: \(error.localizedDescription)"
                showError = true
                return
            }
        }
        
        // Успешно сохранено
        dismiss()
    }
}

#Preview {
    EditProfileView(viewModel: ProfileViewModel())
}
