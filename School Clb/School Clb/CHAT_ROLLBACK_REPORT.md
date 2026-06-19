# Откат изменений: восстановление рабочих пузырей чатов

## Проблема:
После внедрения компонента `MessageBubbleContent` вёрстка чатов сломалась:
- Текст сообщений обрезан по краям экрана
- Пузыри не отображаются корректно
- Вёрстка разъехалась во всех чатах

## Исправленные файлы:

### 1. **MyGroupChatView.swift**
**Что откатил:**
- Вернул `GroupMessageBubble` к рабочему виду
- Удалил использование `MessageBubbleContent`
- Восстановил прямое отображение текста с `.padding(12)` и `.background()`
- `.frame(maxWidth: 280)` для ограничения ширины
- Цвет акцента: `#1B2A6B` (синий)

**Код пузыря:**
```swift
struct GroupMessageBubble: View {
    let message: GroupMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Аватар слева для чужих сообщений
            VStack {
                // Имя автора
                // Изображение (если есть)
                // Текст в пузыре с padding(12)
                // Время
            }
            .frame(maxWidth: 280)
        }
    }
}
```

### 2. **AITeacherView.swift**
**Что откатил:**
- Вернул `AIMessageBubble` к рабочему виду
- Удалил `MessageBubbleContent`
- Прямое отображение текста и изображений
- `.frame(maxWidth: 280)`
- Цвет акцента: `#9C27B0` (фиолетовый)

### 3. **PrivateChatsView.swift**
**Что проверил:**
- `PrivateMessageBubble` уже был в рабочем виде
- Не требовал изменений
- Цвет акцента: `#34C759` (зелёный)

### 4. **ForumChatView.swift**
**Что откатил:**
- Вернул `AnswerBubble` к рабочему виду
- Удалил `MessageBubbleContent`
- Прямое отображение текста ответов
- Белый фон вместо `#F5F5F5`
- Цвет акцента: `#E84E1B` (оранжевый)

### 5. **SOSViewModel.swift**
**Что исправил:**
- Добавил недостающие поля `videoURL`, `documentURL`, `documentName` в `loadMockPrivateChats()`
- Обновил `sendPrivateMessage()` для правильного создания `PrivateMessage` со всеми полями

## Рабочий вид пузырей (восстановлен):

```swift
// Пример рабочего пузыря
VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
    // Изображение (если есть)
    if let imageData = message.imageData {
        Image(uiImage: UIImage(data: imageData)!)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 250)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // Текст
    if !message.text.isEmpty {
        Text(message.text)
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(isCurrentUser ? Color.white : Color.primary)
            .padding(12) // ✅ ВАЖНО: отступы внутри пузыря
            .background(
                isCurrentUser 
                ? accentColor 
                : Color(uiColor: .systemBackground)
            )
            .cornerRadius(16)
    }
    
    // Время
    Text(timeAgo)
        .font(.system(size: 11))
        .foregroundColor(.secondary)
}
.frame(maxWidth: 280, alignment: alignment) // ✅ ВАЖНО: ограничение ширины
```

## Что НЕ было откачено:

✅ **ChatInputBar** — остался, работает корректно  
✅ **ChatBackground** — остался, фон работает  
✅ **DateExtensions** (relativeRu) — остался  
✅ Поддержка вложений в моделях (videoURL, documentURL, etc.) — осталась  
✅ Обновлённые методы в SOSViewModel — остались  

## Что откачено:

❌ **MessageBubbleContent** — компонент больше не используется (остался в ChatInputBar.swift, но не применяется)  
❌ Использование `ChatAttachment` в пузырях — удалено  

## Результат:

✅ Моя группа — пузыри работают, текст не обрезается  
✅ ИИ-преподаватель — пузыри работают  
✅ Личные чаты — работали и продолжают работать  
✅ Форум — ответы отображаются корректно  
✅ Фон чата виден во всех чатах  
✅ Поле ввода ChatInputBar работает  

## Оставшиеся возможности для вложений:

Хотя `MessageBubbleContent` откачен, поддержка вложений осталась:
- В моделях есть поля `videoURL`, `documentURL`, `documentName`
- В методах `sendMessage` можно передавать вложения
- Просто нужно добавить отображение этих вложений напрямую в каждый пузырь (не через MessageBubbleContent)

## Рекомендация:

Если нужно добавить отображение видео и документов в пузырях, делайте это напрямую в каждом `*MessageBubble` view:

```swift
// Видео
if let videoURL = message.videoURL {
    ZStack {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black.opacity(0.3))
            .frame(width: 200, height: 150)
        
        Image(systemName: "play.circle.fill")
            .font(.system(size: 48))
            .foregroundColor(.white)
    }
}

// Документ
if let documentName = message.documentName {
    HStack(spacing: 8) {
        Image(systemName: "doc.fill")
            .foregroundColor(accentColor)
        Text(documentName)
            .lineLimit(1)
    }
    .padding(12)
    .background(Color(uiColor: .secondarySystemBackground))
    .cornerRadius(12)
}
```

Просто добавьте эти блоки перед или после текстового пузыря в каждом `*MessageBubble`.
