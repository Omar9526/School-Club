//
//  ChatBackground.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct ChatBackground: View {
    var body: some View {
        Image("chat_bg")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ZStack {
        ChatBackground()
        
        Text("Пример текста")
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
    }
}
