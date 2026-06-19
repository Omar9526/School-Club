# Добавление фона чата во все переписки

## Созданный компонент:

### **ChatBackground.swift** (новый файл)
Переиспользуемый компонент фона для всех чатов:
```swift
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
```

**Особенности:**
- Использует изображение `chat_bg` из Assets (светлый кремовый фон с логотипом School Club)
- `.scaledToFill()` + `.clipped()` — заполняет экран, логотип остается по центру
- `.ignoresSafeArea(edges: .bottom)` — фон под Safe Area, но не под навбаром
- Без затемняющего слоя — фон светлый, текст читается

## Изменённые файлы:

### 1. **MyGroupChatView.swift**
**Что изменено:**
- Обернул `body` в `ZStack` с `ChatBackground()` на заднем плане
- ScrollView теперь имеет `.background(Color.clear)` вместо `.systemGroupedBackground`
- Фон видно только за сообщениями, не залезает на поле ввода и навбар

**Код:**
```swift
var body: some View {
    ZStack {
        // Фон чата
        ChatBackground()
        
        VStack(spacing: 0) {
            // Сообщения
            ScrollViewReader { proxy in
                ScrollView {
                    messagesList
                }
                .background(Color.clear) // Прозрачный фон
                // ...
            }
            
            // Поле ввода
            ChatInputBar(...)
        }
    }
    // ...
}
```

### 2. **AITeacherView.swift**
**Что изменено:**
- Обернул `body` в `ZStack` с `ChatBackground()`
- ScrollView с `.background(Color.clear)`
- Фон за перепиской с ИИ

**Код:**
```swift
var body: some View {
    ZStack {
        // Фон чата
        ChatBackground()
        
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Сообщения ИИ
                    }
                    .padding(16)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                // ...
            }

            ChatInputBar(...)
        }
    }
    // ...
}
```

### 3. **PrivateChatsView.swift** (PrivateChatDetailView)
**Что изменено:**
- Обернул `body` в `ZStack` с `ChatBackground()`
- ScrollView с `.background(Color.clear)`
- Фон за личными чатами (зелёный акцент)

**Код:**
```swift
var body: some View {
    NavigationStack {
        ZStack {
            // Фон чата
            ChatBackground()
            
            VStack(spacing: 0) {
                // Сообщения
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(currentMessages) { message in
                                PrivateMessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(16)
                        .padding(.bottom, 20)
                    }
                    .background(Color.clear)
                    // ...
                }
                
                // Поле ввода
                ChatInputBar(...)
            }
        }
        // ...
    }
}
```

### 4. **ForumChatView.swift** (PostDetailView)
**Что изменено:**
- Обернул `body` в `ZStack` с `ChatBackground()`
- ScrollView с `.background(Color.clear)` вместо `Color(hex: "#F5F5F5")`
- Фон за вопросами и ответами форума (оранжевый акцент)

**Код:**
```swift
var body: some View {
    NavigationStack {
        if let post = post {
            ZStack {
                // Фон чата
                ChatBackground()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Вопрос и ответы
                        }
                        .padding(20)
                    }
                    .background(Color.clear)
                    
                    // Поле ввода ответа
                    ChatInputBar(...)
                }
            }
            // ...
        }
    }
}
```

## Результат:

✅ **ChatBackground** — единый переиспользуемый компонент для всех чатов  
✅ **Моя группа** — кремовый фон с логотипом, синие пузыри поверх  
✅ **ИИ-преподаватель** — кремовый фон с логотипом, фиолетовые пузыри поверх  
✅ **Личные чаты** — кремовый фон с логотипом, зелёные пузыри поверх  
✅ **Форум (ответы)** — кремовый фон с логотипом, оранжевые пузыри поверх  
✅ Фон только за лентой сообщений, не залезает на поле ввода и навбар  
✅ Никакого затемняющего слоя — фон светлый, текст читается  
✅ Логотип School Club виден по центру фона  

## Требования к Assets:

Убедитесь, что в `Assets.xcassets` есть изображение с именем `chat_bg`:
- Светлый кремовый фон
- Логотип School Club по центру
- Изображение должно хорошо масштабироваться при `.scaledToFill()`

## Как менять фон:

Чтобы изменить фон во всех чатах сразу, отредактируйте только файл `ChatBackground.swift`:
- Замените `"chat_bg"` на другое имя изображения из Assets
- Измените модификаторы `.scaledToFill()` на `.scaledToFit()` если нужно
- Добавьте overlay с затемнением, если потребуется

Все 4 чата автоматически обновятся.
