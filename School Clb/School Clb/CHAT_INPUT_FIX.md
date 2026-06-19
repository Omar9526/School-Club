# Исправление поля ввода в чатах

## Проблема:

На скриншоте "Моя группа • Ортголики" **НЕ ВИДНО поля ввода сообщения** внизу экрана.

Причина: Поле ввода перекрывается нижним TabBar.

---

## ✅ Решение:

Добавлены отступы снизу для всех чатов, чтобы поле ввода было видно над TabBar.

---

## Исправленные файлы:

### 1. MyGroupChatView.swift

**Добавлено:**
```swift
.padding(.bottom, 100) // Отступ для поля ввода + TabBar
```

**Где:**
- В `LazyVStack` с сообщениями - чтобы последнее сообщение не скрывалось
- В блоке поля ввода `.padding(.bottom, 50)` - чтобы поле было над TabBar

**До:**
```swift
LazyVStack(spacing: 16) {
    // Сообщения
}
.padding(20)

// Поле ввода
HStack { ... }
.padding(12)
.background(Color(uiColor: .systemBackground))
```

**После:**
```swift
LazyVStack(spacing: 16) {
    // Сообщения
}
.padding(20)
.padding(.bottom, 100) // ← ДОБАВЛЕНО

// Поле ввода
HStack { ... }
.padding(12)
.padding(.bottom, 50) // ← ДОБАВЛЕНО
.background(Color(uiColor: .systemBackground))
```

---

### 2. AITeacherView.swift

**Добавлено:**
```swift
.padding(.bottom, 100) // Отступ для поля ввода + TabBar
```

**Где:**
- В `LazyVStack` с сообщениями AI
- В блоке поля ввода `.padding(.bottom, 50)`

---

### 3. PrivateChatsView.swift → PrivateChatDetailView

**Добавлено:**
```swift
.padding(.bottom, 100) // Отступ для поля ввода
```

**Где:**
- В `LazyVStack` с личными сообщениями

---

## 📐 Размеры отступов:

| Элемент | Отступ снизу | Назначение |
|---------|--------------|------------|
| LazyVStack (сообщения) | 100pt | Чтобы последнее сообщение не скрывалось за полем ввода + TabBar |
| Поле ввода | 50pt | Чтобы поле было видно над TabBar (~80-90pt высота TabBar) |

---

## 📱 Результат:

### До:
```
╔══════════════════════════╗
║ Сообщения...             ║
║                          ║
║ [Последнее сообщение]    ║
║                          ║
╠══════════════════════════╣
║ [TabBar перекрывает      ║
║  поле ввода]             ║
╚══════════════════════════╝
```

### После:
```
╔══════════════════════════╗
║ Сообщения...             ║
║                          ║
║ [Последнее сообщение]    ║
║                          ║
║ [Поле ввода ВИДНО] 🎉    ║
╠══════════════════════════╣
║ [TabBar]                 ║
╚══════════════════════════╝
```

---

## ✨ Функционал поля ввода:

### Моя группа (MyGroupChatView):
- ✅ Поле текста с placeholder "Сообщение..."
- ✅ Многострочный ввод (1-4 строки)
- ✅ Кнопка отправки (синяя стрелка)
- ✅ Отключена при пустом поле
- ✅ ProgressView при отправке

### ИИ-преподаватель (AITeacherView):
- ✅ Поле текста "Задайте вопрос..."
- ✅ Кнопка прикрепления фото
- ✅ Превью фото перед отправкой
- ✅ Кнопка отправки (темно-синяя)
- ✅ ProgressView при отправке

### Личные чаты (PrivateChatDetailView):
- ✅ Поле текста "Сообщение..."
- ✅ Многострочный ввод
- ✅ Кнопка отправки (зеленая стрелка)
- ✅ ProgressView при отправке

---

## 🎨 Дизайн поля ввода:

```swift
HStack(spacing: 12) {
    TextField("Сообщение...", text: $messageText, axis: .vertical)
        .font(.system(size: 15, weight: .regular, design: .rounded))
        .padding(12)
        .background(Color(uiColor: .systemBackground)) // Адаптивный фон
        .cornerRadius(20) // Округлые углы
        .lineLimit(1...4) // 1-4 строки
    
    Button(action: sendMessage) {
        Image(systemName: "arrow.up.circle.fill")
            .font(.system(size: 32))
            .foregroundColor(messageText.isEmpty ? .gray : Color(hex: "#2196F3"))
    }
    .disabled(messageText.isEmpty)
}
.padding(12)
.padding(.bottom, 50) // Отступ для TabBar
.background(Color(uiColor: .systemBackground))
```

---

## 📂 Файлы изменены:

1. ✅ `MyGroupChatView.swift` - добавлены отступы
2. ✅ `AITeacherView.swift` - добавлены отступы
3. ✅ `PrivateChatsView.swift` - добавлены отступы
4. ✅ `CHAT_INPUT_FIX.md` - эта документация

---

## 📅 Дата обновления:
17 июня 2026

## ✅ Статус:
Исправлено! Теперь поле ввода видно во всех чатах и не перекрывается TabBar! 🎉
