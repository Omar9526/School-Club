//
//  DiscountView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct DiscountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedUser: String?
    @State private var discountPercent = 10
    @State private var expiryDate = Date().addingTimeInterval(30 * 24 * 3600) // +30 days
    @State private var isSaving = false
    @State private var showSuccess = false
    
    let users = ["Айдай", "Бекжан", "Динара", "Эркин"] // TODO: Load from Firestore
    
    var body: some View {
        NavigationStack {
            Form {
                Section("ПОИСК ПОЛЬЗОВАТЕЛЯ") {
                    TextField("Никнейм", text: $searchText)
                    
                    if !searchText.isEmpty {
                        ForEach(filteredUsers, id: \.self) { user in
                            Button(action: { selectedUser = user }) {
                                HStack {
                                    Text(user)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedUser == user {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                if selectedUser != nil {
                    Section("ВЫБРАННЫЙ ПОЛЬЗОВАТЕЛЬ") {
                        HStack {
                            Text(selectedUser!)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            Spacer()
                            Button("Сбросить") {
                                selectedUser = nil
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    Section("СКИДКА") {
                        Stepper("\(discountPercent)%", value: $discountPercent, in: 5...90, step: 5)
                        
                        DatePicker("Действует до", selection: $expiryDate, in: Date()..., displayedComponents: .date)
                    }
                    
                    Section {
                        Button(action: saveDiscount) {
                            if isSaving {
                                ProgressView()
                            } else {
                                Text("Назначить скидку")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(isSaving)
                    }
                }
            }
            .navigationTitle("Назначить скидку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .alert("Успех!", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Скидка \(discountPercent)% назначена пользователю \(selectedUser ?? "")")
            }
        }
    }
    
    private var filteredUsers: [String] {
        users.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func saveDiscount() {
        guard let user = selectedUser else { return }
        
        isSaving = true
        
        Task {
            // TODO: Update Firestore users/{uid}.discount
            /*
             discount: {
               percent: discountPercent,
               expiryDate: expiryDate
             }
            */
            
            try? await Task.sleep(for: .seconds(1))
            
            print("Discount \(discountPercent)% assigned to \(user) until \(expiryDate)")
            
            isSaving = false
            showSuccess = true
        }
    }
}

#Preview {
    DiscountView()
}
