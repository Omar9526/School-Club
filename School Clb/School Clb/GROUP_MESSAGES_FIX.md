# ✅ ИСПРАВЛЕНИЕ: Сообщения дублируются во всех группах

## 🐛 Проблема
Когда пишешь сообщение в группе "Ортголики", оно появляется **во всех группах**:
- Ортголики → "Привет!" ✅
- Дизайнеры → "Привет!" ❌ (не должно быть!)
- Фотография → "Привет!" ❌ (не должно быть!)

## 🔍 Причина
Использовался **один общий массив** `groupMessages: [GroupMessage]` для всех групп.

```swift
// ❌ БЫЛО:
@Published var groupMessages: [GroupMessage] = []

// Все группы используют один массив
ForEach(viewModel.groupMessages) { message in
    GroupMessageBubble(message: message)
}
```

## ✅ Решение

### 1. Изменена структура данных в SOSViewModel

```swift
// ✅ СТАЛО:
@Published var groupMessages: [String: [GroupMessage]] = [:] 
// Словарь: groupID -> массив сообщений
```

Теперь каждая группа имеет **свой собственный массив сообщений**:
- `groupMessages["1"]` → Ортголики
- `groupMessages["2"]` → Дизайнеры
- `groupMessages["3"]` → Фотография

---

### 2. Обновлен loadMockGroupMessages()

```swift
private func loadMockGroupMessages() {
    // ✅ Ортголики (id: "1")
    groupMessages["1"] = [
        GroupMessage(
            id: "1-1",
            text: "Всем привет! Кто-нибудь делал домашку по математике?",
            authorNickname: "Айдай",
            ...
        )
    ]
    
    // ✅ Дизайнеры (id: "2")
    groupMessages["2"] = [
        GroupMessage(
            id: "2-1",
            text: "Привет! Кто хочет поработать над новым проектом?",
            authorNickname: "Динара",
            ...
        )
    ]
    
    // ✅ Фотография (id: "3")
    groupMessages["3"] = [
        GroupMessage(
            id: "3-1",
            text: "Завтра планируется фотосессия в 15:00!",
            authorNickname: "Азамат",
            ...
        )
    ]
}
```

---

### 3. Обновлен sendGroupMessage()

```swift
// ✅ Добавлен параметр groupID
func sendGroupMessage(groupID: String, text: String, imageData: Data? = nil) async throws {
    guard !text.isEmpty || imageData != nil else { return }
    
    try await Task.sleep(for: .seconds(0.5))
    
    let newMessage = GroupMessage(
        id: UUID().uuidString,
        text: text,
        authorNickname: "Вы",
        authorUID: "current-user",
        timestamp: Date(),
        isCurrentUser: true,
        imageData: imageData
    )
    
    // ✅ Добавляем сообщение ТОЛЬКО в конкретную группу
    if groupMessages[groupID] != nil {
        groupMessages[groupID]?.append(newMessage)
    } else {
        groupMessages[groupID] = [newMessage]
    }
}
```

---

### 4. Обновлен MyGroupChatView

```swift
// ✅ Отображаем сообщения ТОЛЬКО для этой группы
ForEach(viewModel.groupMessages[group.id] ?? []) { message in
    GroupMessageBubble(message: message)
        .id(message.id)
}

// ✅ Отслеживаем изменения ТОЛЬКО для этой группы
.onChange(of: viewModel.groupMessages[group.id]?.count ?? 0) { _, _ in
    if let lastMessage = viewModel.groupMessages[group.id]?.last {
        withAnimation {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}

// ✅ Отправляем с указанием groupID
try await viewModel.sendGroupMessage(groupID: group.id, text: text, imageData: imageData)
```

---

## 📱 Результат:

### Было:
- ❌ "Ортголики" → пишешь "Привет!" → появляется везде
- ❌ "Дизайнеры" → те же сообщения, что в Ортголиках
- ❌ "Фотография" → те же сообщения, что в Ортголиках

### Стало:
- ✅ "Ортголики" → "Привет!" → только в Ортголиках
- ✅ "Дизайнеры" → свои сообщения
- ✅ "Фотография" → свои сообщения

---

## 🗂 Структура данных:

```
groupMessages = [
    "1": [  // Ортголики
        "Привет от Айдай",
        "Привет от Бекжан",
        "Твое сообщение"
    ],
    "2": [  // Дизайнеры
        "Сообщение от Динара",
        "Твое сообщение"
    ],
    "3": [  // Фотография
        "Сообщение от Азамат"
    ]
]
```

Каждая группа — **отдельный массив**, независимый от других!

---

## 🔧 Измененные файлы:

1. ✅ **SOSViewModel.swift**:
   - Изменено: `@Published var groupMessages: [String: [GroupMessage]]`
   - Обновлено: `loadMockGroupMessages()`
   - Обновлено: `sendGroupMessage(groupID:text:imageData:)`

2. ✅ **MyGroupChatView.swift**:
   - Обновлено: `ForEach(viewModel.groupMessages[group.id] ?? [])`
   - Обновлено: `.onChange(of: viewModel.groupMessages[group.id]?.count)`
   - Обновлено: `sendGroupMessage(groupID: group.id, ...)`

---

## 📅 Дата исправления: 17 июня 2026

## 🎉 Статус: ✅ ИСПРАВЛЕНО

Теперь:
- ✅ Каждая группа имеет свои сообщения
- ✅ Сообщения НЕ дублируются между группами
- ✅ Можно писать в "Ортголики", "Дизайнеры", "Фотография" независимо

**Готово к тестированию!** 🚀
