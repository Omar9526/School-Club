//
//  EmojiPickerView.swift
//  School Club
//
//  Created on 20.05.2026
//

import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    let emojis = [
        "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣",
        "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰",
        "😘", "😗", "😙", "😚", "😋", "😛", "😝", "😜",
        "🤪", "🤨", "🧐", "🤓", "😎", "🥸", "🤩", "🥳",
        "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "☹️",
        "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😤",
        "😠", "😡", "🤬", "🤯", "😳", "🥵", "🥶", "😱",
        "😨", "😰", "😥", "😓", "🤗", "🤔", "🤭", "🤫",
        "🤥", "😶", "😐", "😑", "😬", "🙄", "😯", "😦",
        "😧", "😮", "😲", "🥱", "😴", "🤤", "😪", "😵",
        "🤐", "🥴", "🤢", "🤮", "🤧", "😷", "🤒", "🤕",
        "🎓", "🎯", "🎨", "🎭", "🎪", "🎬", "🎤", "🎧",
        "🎸", "🎹", "🎺", "🎷", "🥁", "🎮", "👾", "🎲",
        "🎰", "🎳", "⚽️", "🏀", "🏈", "⚾️", "🥎", "🎾",
        "🏐", "🏉", "🥏", "🎱", "🪀", "🏓", "🏸", "🏒",
        "🏑", "🥍", "🏏", "⛳️", "🏹", "🎣", "🤿", "🥊",
        "🥋", "🎽", "🛹", "🛼", "🛷", "⛸", "🥌", "🎿",
        "⛷", "🏂", "🪂", "🏋️", "🤸", "🤺", "🤾", "🏌️",
        "🏇", "🧘", "🏄", "🏊", "🤽", "🚣", "🧗", "🚴",
        "🔥", "⭐️", "✨", "🌟", "💫", "🌈", "☀️", "🌤",
        "⛅️", "🌥", "☁️", "🌦", "🌧", "⛈", "🌩", "🌨",
        "❄️", "☃️", "⛄️", "🌬", "💨", "💧", "💦", "☔️",
        "💰", "💎", "💍", "💄", "💋", "👑", "🎩", "🎓"
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 8)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            selectedEmoji = emoji
                            onSelect(emoji)
                            dismiss()
                        }) {
                            Text(emoji)
                                .font(.system(size: 36))
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(selectedEmoji == emoji ? Color(hex: "#FFE600") : Color.clear)
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Выбери свой вайб")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant("🎓")) { _ in }
}
