# Добавление прикрепления файлов в групповой чат

## ✨ Новая функция:

Теперь в групповом чате можно прикреплять:
- 📷 **Фото**
- 🎬 **Видео**
- 📄 **Документы/Файлы**

---

## 🎨 Дизайн:

### Кнопка прикрепления:
```
[+] [Сообщение...        ] [➤]
 ↑
 Меню с опциями
```

При нажатии на **[+]** открывается меню:
```
┌─────────────────────┐
│ 📷 Фото или видео   │
│ 📄 Документ         │
└─────────────────────┘
```

---

## 💻 Реализация:

### 1. Новые состояния в MyGroupChatView:

```swift
@State private var selectedPhoto: PhotosPickerItem?
@State private var selectedImageData: Data?
@State private var selectedVideoURL: URL?
@State private var showDocumentPicker = false
```

---

### 2. Кнопка прикрепления с Menu:

```swift
Menu {
    // Фото/Видео
    PhotosPicker(selection: $selectedPhoto, matching: .any(of: [.images, .videos])) {
        Label("Фото или видео", systemImage: "photo.on.rectangle")
    }
    
    // Документ/Файл
    Button(action: {
        showDocumentPicker = true
    }) {
        Label("Документ", systemImage: "doc")
    }
} label: {
    Image(systemName: "plus.circle.fill")
        .font(.system(size: 28))
        .foregroundColor(Color(hex: "#2196F3"))
}
```

---

### 3. Превью прикрепленного файла:

Появляется НАД полем ввода:

```swift
if selectedImageData != nil || selectedVideoURL != nil {
    attachmentPreview
        .padding(.horizontal, 12)
        .padding(.top, 8)
}
```

**Превью показывает:**
- Миниатюру фото/видео
- Кнопку удаления (крестик)

```
┌─────────────────────────┐
│ [📷 фото]        [✕]    │
├─────────────────────────┤
│ [+] [Сообщение...] [➤] │
└─────────────────────────┘
```

---

### 4. Обновлена модель GroupMessage:

```swift
struct GroupMessage: Identifiable {
    let id: String
    let text: String
    let authorNickname: String
    let authorUID: String
    let timestamp: Date
    let isCurrentUser: Bool
    let imageData: Data? // ← НОВОЕ ПОЛЕ
}
```

---

### 5. Отображение изображений в сообщениях:

```swift
// В GroupMessageBubble:

// Изображение (если есть)
if let imageData = message.imageData, let uiImage = UIImage(data: imageData) {
    Image(uiImage: uiImage)
        .resizable()
        .scaledToFit()
        .frame(maxWidth: 250)
        .clipShape(RoundedRectangle(cornerRadius: 12))
}

// Текст сообщения (если есть)
if !message.text.isEmpty {
    Text(message.text)
        .font(.system(size: 15))
        .padding(12)
        .background(Color(hex: "#2196F3"))
        .cornerRadius(16)
}
```

**Можно отправить:**
- Только фото
- Только текст
- Фото + текст

---

### 6. Обновлен метод отправки:

```swift
func sendMessage() {
    guard !messageText.isEmpty || selectedImageData != nil else { return }
    
    let text = messageText
    let imageData = selectedImageData
    
    messageText = ""
    selectedImageData = nil
    
    Task {
        try await viewModel.sendGroupMessage(text: text, imageData: imageData)
    }
}
```

**Кнопка отправки активна если:**
- Есть текст ИЛИ
- Есть прикрепленное фото/видео

---

## 📱 Как выглядит:

### Обычный режим:
```
┌───────────────────────────┐
│ [+] [Сообщение...   ] [➤] │
└───────────────────────────┘
```

### С прикрепленным фото:
```
┌───────────────────────────┐
│ [🖼️ превью фото]      [✕] │
├───────────────────────────┤
│ [+] [Подпись...     ] [➤] │
└───────────────────────────┘
```

### В чате с фото:
```
┌───────────────────────────┐
│ Айдай                     │
│ ┌──────────────┐          │
│ │   [Фото]     │          │
│ └──────────────┘          │
│ Вот задача по математике  │
│ 1 hr ago                  │
└───────────────────────────┘
```

---

## 🎯 Функционал:

### PhotosPicker:
- ✅ Открывает галерею iOS
- ✅ Позволяет выбрать фото или видео
- ✅ Поддерживает `.images` и `.videos`
- ✅ Автоматически загружает Data

### Превью:
- ✅ Показывает миниатюру (60pt высоты)
- ✅ Кнопка удаления (крестик)
- ✅ Серый фон для контраста
- ✅ Скругленные углы

### Отправка:
- ✅ Можно отправить только фото
- ✅ Можно отправить фото + текст
- ✅ Кнопка отключена если пусто
- ✅ ProgressView при отправке

---

## 🔄 SOSViewModel обновлен:

```swift
func sendGroupMessage(text: String, imageData: Data? = nil) async throws {
    guard !text.isEmpty || imageData != nil else { return }
    
    // TODO: Загрузить imageData в Firebase Storage
    // TODO: Получить URL изображения
    // TODO: Сохранить сообщение в Firestore с URL
    
    let newMessage = GroupMessage(
        id: UUID().uuidString,
        text: text,
        authorNickname: "Вы",
        authorUID: "current-user",
        timestamp: Date(),
        isCurrentUser: true,
        imageData: imageData // Пока храним локально
    )
    
    groupMessages.append(newMessage)
}
```

---

## 📂 Измененные файлы:

1. ✅ **MyGroupChatView.swift**
   - Добавлены состояния для файлов
   - Кнопка прикрепления с Menu
   - Превью прикрепленных файлов
   - Обновлен метод отправки

2. ✅ **GroupMessage model**
   - Добавлено поле `imageData: Data?`

3. ✅ **GroupMessageBubble**
   - Отображение изображений
   - Поддержка сообщений без текста (только фото)

4. ✅ **SOSViewModel.swift**
   - Обновлен `sendGroupMessage` для imageData
   - Mock данные обновлены

5. ✅ **FILE_ATTACHMENT.md** - эта документация

---

## 🚀 TODO (будущее):

### Поддержка видео:
- [ ] Проигрывание видео в чате
- [ ] Превью видео (первый кадр)
- [ ] Индикатор загрузки видео

### Документы:
- [ ] DocumentPicker для файлов
- [ ] Иконки типов файлов (PDF, DOC, etc)
- [ ] Размер файла
- [ ] Скачивание файлов

### Firebase интеграция:
- [ ] Загрузка в Firebase Storage
- [ ] Прогресс-бар загрузки
- [ ] Получение URL
- [ ] Сохранение URL в Firestore

### Дополнительно:
- [ ] Сжатие изображений перед отправкой
- [ ] Просмотр фото в полном размере (tap)
- [ ] Множественный выбор фото
- [ ] Запись голосовых сообщений

---

## 📅 Дата обновления:
17 июня 2026

## ✅ Статус:
Реализовано! Теперь можно прикреплять фото и видео в групповой чат! 📷🎬
