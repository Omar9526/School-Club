//
//  AppRouter.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct AppRouter: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        ZStack {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .transition(.opacity)
            } else {
                AuthView()
                    .environmentObject(authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isAuthenticated)
    }
}

#Preview {
    AppRouter()
}
