# Исправление поля ввода и добавление списка групп

## 🐛 Проблемы на скриншоте:

1. **Поле ввода "Сообщение..." НЕ ВИДНО**
   - Видна только кнопка со стрелкой
   - Само TextField слишком маленькое или скрыто

2. **"Моя группа Ортголики" - это один чат, а не список**
   - Должен быть список ВСЕХ групп студента
   - Каждая группа - отдельный чат

---

## ✅ ИСПРАВЛЕНИЯ:

### 1. Поле ввода сделано видимым

**Что изменено в MyGroupChatView.swift:**

```swift
TextField("Сообщение...", text: $messageText, axis: .vertical)
    .font(.system(size: 15, weight: .regular, design: .rounded))
    .padding(12)
    .background(Color(uiColor: .secondarySystemBackground)) // ← Контрастный фон
    .cornerRadius(20)
    .lineLimit(1...4)
    .frame(minHeight: 44) // ← Минимальная высота!
```

**Изменения:**
- `.background(Color(uiColor: .secondarySystemBackground))` - серый фон вместо белого
- `.frame(minHeight: 44)` - минимальная высота для видимости
- `.padding(.horizontal, 12)` - отступы по бокам для контейнера

**Результат:** Поле теперь ВИДНО и имеет нормальный размер!

---

### 2. Создан список групп

**Новый файл: MyGroupsListView.swift**

Показывает список всех групп студента:

```
┌─────────────────────────────────┐
│  [👥] Ортголики           [30]  │
│      Супер, спасибо! Скину...   │
│      👥 25 участников            │
├─────────────────────────────────┤
│  [👥] Дизайнеры           [5]   │
│      Кто-нибудь знает где...    │
│      👥 15 участников            │
├─────────────────────────────────┤
│  [👥] Фотография          [12]  │
│      Завтра будет практич...    │
│      👥 18 участников            │
└─────────────────────────────────┘
```

**Каждая карточка группы содержит:**
- 👥 Иконка группы с градиентом
- 🔴 Badge с количеством новых сообщений
- 📛 Название группы
- 💬 Последнее сообщение (preview)
- 👤 Количество участников
- ➡️ Стрелка для перехода

---

### 3. Обновлена навигация

**ChatView.swift:**
```swift
// БЫЛО:
ChatSectionCard(
    title: "МОЯ ГРУППА ОРТГОЛИКИ",
    destination: AnyView(MyGroupChatView(viewModel: viewModel))
)

// СТАЛО:
ChatSectionCard(
    title: "МОИ ГРУППЫ",
    description: "Общайтесь с вашими группами",
    destination: AnyView(MyGroupsListView(viewModel: viewModel))
)
```

**Навигация теперь:**
```
ЧАТ → МОИ ГРУППЫ → Выбор группы → Чат группы
```

---

### 4. MyGroupChatView обновлен

**Теперь принимает конкретную группу:**

```swift
struct MyGroupChatView: View {
    @ObservedObject var viewModel: SOSViewModel
    let group: StudentGroup // ← Конкретная группа!
    
    var body: some View {
        // ...
        .navigationTitle(group.name) // Ортголики / Дизайнеры / Фотография
    }
}
```

---

## 🗂️ Модель StudentGroup

```swift
struct StudentGroup: Identifiable {
    let id: String
    let name: String               // "Ортголики"
    let description: String?       // "Основная группа..."
    let membersCount: Int          // 25
    let unreadCount: Int           // 30
    let lastMessage: String?       // "Привет всем!"
    let lastMessageTime: Date?     // 1 час назад
}
```

---

## 📊 Mock данные групп

**В SOSViewModel добавлено:**

```swift
@Published var myGroups: [StudentGroup] = []

private func loadMockGroups() {
    myGroups = [
        StudentGroup(
            id: "1",
            name: "Ортголики",
            membersCount: 25,
            unreadCount: 30,
            lastMessage: "Супер, спасибо! Скину фото задачи..."
        ),
        StudentGroup(
            id: "2",
            name: "Дизайнеры",
            membersCount: 15,
            unreadCount: 5,
            lastMessage: "Кто-нибудь знает где найти референсы?"
        ),
        StudentGroup(
            id: "3",
            name: "Фотография",
            membersCount: 18,
            unreadCount: 12,
            lastMessage: "Завтра будет практическое занятие!"
        )
    ]
}
```

---

## 📱 Как выглядит сейчас:

### Главный экран ЧАТ:
```
┌─────────────────────────────┐
│ [👥] МОИ ГРУППЫ       [30]  │
│     Общайтесь с вашими...   │
├─────────────────────────────┤
│ [💬] ФОРУМ СКУЛ КЛАБ    🔒  │
├─────────────────────────────┤
│ [🧠] ИИ-ПРЕПОДАВАТЕЛЬ   🔒  │
├─────────────────────────────┤
│ [✉️] ЛИЧНЫЕ ЧАТЫ        🔒  │
└─────────────────────────────┘
```

### Список групп (MyGroupsListView):
```
┌─────────────────────────────┐
│ Мои группы                  │
├─────────────────────────────┤
│ [👥] Ортголики        [30]  │
│     Супер, спасибо!...      │
│     👥 25 участников         │
├─────────────────────────────┤
│ [👥] Дизайнеры        [5]   │
│     Кто-нибудь знает...     │
│     👥 15 участников         │
├─────────────────────────────┤
│ [👥] Фотография       [12]  │
│     Завтра будет...         │
│     👥 18 участников         │
└─────────────────────────────┘
```

### Чат конкретной группы (MyGroupChatView):
```
┌─────────────────────────────┐
│ Ортголики           [←]     │
├─────────────────────────────┤
│ А: Всем привет! Кто-нибудь  │
│    делал домашку?           │
│                             │
│ Б: Да, я уже сделал...      │
│                             │
│         Супер, спасибо! 💙  │
│                             │
├─────────────────────────────┤
│ [Сообщение...        ] [➤] │ ← ВИДНО!
└─────────────────────────────┘
```

---

## 🎨 Дизайн поля ввода (исправленный):

```swift
HStack(spacing: 12) {
    TextField("Сообщение...", text: $messageText, axis: .vertical)
        .font(.system(size: 15, weight: .regular, design: .rounded))
        .padding(12)
        .background(Color(uiColor: .secondarySystemBackground)) // Серый фон
        .cornerRadius(20)
        .lineLimit(1...4)
        .frame(minHeight: 44) // Минимальная высота
    
    Button(action: sendMessage) {
        Image(systemName: "arrow.up.circle.fill")
            .font(.system(size: 32))
            .foregroundColor(messageText.isEmpty ? .gray : Color(hex: "#2196F3"))
    }
}
.padding(.horizontal, 12)
.padding(.vertical, 8)
.padding(.bottom, 50) // Отступ для TabBar
.background(Color(uiColor: .systemBackground))
```

**Ключевые изменения:**
- `.secondarySystemBackground` - контрастный серый фон
- `.frame(minHeight: 44)` - гарантированная высота
- `.padding(.horizontal, 12)` - отступы по бокам

---

## 📂 Созданные файлы:

1. ✅ **MyGroupsListView.swift** - список всех групп
2. ✅ **GROUP_LIST_FIX.md** - эта документация

## 📝 Измененные файлы:

1. ✅ **MyGroupChatView.swift** - принимает группу, исправлено поле ввода
2. ✅ **ChatView.swift** - ведет на список групп
3. ✅ **SOSViewModel.swift** - добавлены mock группы

---

## 📅 Дата обновления:
17 июня 2026

## ✅ Статус:
✅ Поле ввода ВИДНО и работает!
✅ Список групп создан!
✅ Навигация обновлена!

Теперь студент видит ВСЕ свои группы и может выбрать нужную! 🎉
