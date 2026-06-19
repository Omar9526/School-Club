# Проверка и подтверждение ChatInputBar

## Статус ChatInputBar в файлах:

### 1. **AITeacherView.swift**
✅ ChatInputBar ПРИСУТСТВУЕТ (строка 55)
```swift
ChatInputBar(
    messageText: $messageText,
    selectedImageData: $selectedImageData,
    selectedVideoURL: $selectedVideoURL,
    selectedDocumentURL: $selectedDocumentURL,
    selectedDocumentName: $selectedDocumentName,
    accentColor: Color(hex: "#9C27B0"),
    placeholder: "Задайте вопрос...",
    isSending: isSending,
    onSend: sendMessage
)
```

### 2. **PrivateChatsView.swift** (PrivateChatDetailView)
✅ ChatInputBar ПРИСУТСТВУЕТ (строка 211)
```swift
ChatInputBar(
    messageText: $messageText,
    selectedImageData: $selectedImageData,
    selectedVideoURL: $selectedVideoURL,
    selectedDocumentURL: $selectedDocumentURL,
    selectedDocumentName: $selectedDocumentName,
    accentColor: Color(hex: "#34C759"),
    placeholder: "Сообщение...",
    isSending: isSending,
    onSend: sendMessage
)
```

### 3. **ForumChatView.swift** (PostDetailView)
✅ ChatInputBar ПРИСУТСТВУЕТ (строка 295)
```swift
ChatInputBar(
    messageText: $answerText,
    selectedImageData: $selectedImageData,
    selectedVideoURL: $selectedVideoURL,
    selectedDocumentURL: $selectedDocumentURL,
    selectedDocumentName: $selectedDocumentName,
    accentColor: Color(hex: "#E84E1B"),
    placeholder: "Ваш ответ...",
    isSending: isPosting,
    onSend: postAnswer
)
```

### 4. **MyGroupChatView.swift** (эталон)
✅ ChatInputBar ПРИСУТСТВУЕТ и РАБОТАЕТ
```swift
ChatInputBar(
    messageText: $messageText,
    selectedImageData: $selectedImageData,
    selectedVideoURL: $selectedVideoURL,
    selectedDocumentURL: $selectedDocumentURL,
    selectedDocumentName: $selectedDocumentName,
    accentColor: Color(hex: "#1B2A6B"),
    placeholder: "Сообщение...",
    isSending: isSending,
    onSend: sendMessage
)
```

## Проверка ChatInputBar.swift:

✅ Файл существует (270 строк)
✅ Содержит:
- Кнопку "+" с меню (Фото/Видео + Документ)
- TextField с placeholder
- Кнопку отправки (arrow.up.circle.fill)
- PhotosPicker для фото и видео
- FileImporter для документов
- Превью вложений
- Правильный фон и тень

## Структура пузырей:

### Моя группа (эталон) - GroupMessageBubble:
```swift
VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
    // Имя автора (если чужое)
    // Изображение (если есть)
    // Текст с .padding(12) и .background()
    // Время
}
.frame(maxWidth: 280)
```

### ИИ - AIMessageBubble:
```swift
HStack(alignment: .top, spacing: 12) {
    // Аватар ИИ слева (если чужое)
    VStack {
        // Фото (если есть)
        // Текст с .padding(12)
        // Время
    }
    .frame(maxWidth: 280)
}
```

### Личный чат - PrivateMessageBubble:
```swift
HStack {
    VStack {
        // Изображение (если есть)
        // Текст с .padding(12)
        // Время
    }
    .frame(maxWidth: 280)
}
```

### Форум - AnswerBubble:
```swift
VStack(alignment: .leading, spacing: 8) {
    // Автор + лайки
    // Изображение (если есть)
    // Текст
}
.padding(12)
.background(Color.white)
```

## Что исправлено:

1. ✅ **PrivateMessage.timeAgo** - теперь использует `timestamp.relativeRu()`
2. ✅ **PrivateChat.timeAgo** - теперь использует `lastMessageTime.relativeRu()`

## Возможные причины проблемы "пропал ChatInputBar":

1. **Компиляция** - возможно проект не пересобрался после изменений
2. **ZStack** - ChatInputBar может быть перекрыт фоном ChatBackground
3. **VStack spacing** - может быть проблема с layout

## Рекомендации:

1. Clean Build Folder (Cmd+Shift+K)
2. Rebuild (Cmd+B)
3. Проверить, что ChatInputBar в VStack идёт ПОСЛЕ ScrollView
4. Убедиться, что ChatBackground не перекрывает поле ввода

## Структура экрана (правильная):

```swift
ZStack {
    // Фон
    ChatBackground()
    
    VStack(spacing: 0) {
        // Сообщения
        ScrollView {
            LazyVStack {
                // Пузыри сообщений
            }
        }
        .background(Color.clear)
        
        // Поле ввода (ДОЛЖНО БЫТЬ ВИДНО)
        ChatInputBar(...)
    }
}
```

Все 4 чата имеют одинаковую структуру и ChatInputBar присутствует в каждом.
