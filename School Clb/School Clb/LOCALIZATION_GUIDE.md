# Локализация в School Club

## Как добавить новый переведенный текст

### 1. Добавьте строку в Localizable.swift

```swift
static var yourNewString: String {
    switch AppLanguage.current {
    case "RU": return "Русский текст"
    default: return "Кыргызча текст"
    }
}
```

### 2. Используйте в View

```swift
Text(L10n.yourNewString)
```

### 3. Добавьте автоматическое обновление при смене языка

```swift
struct YourView: View {
    @State private var refreshView = false
    
    var body: some View {
        VStack {
            Text(L10n.yourNewString)
        }
        .id(refreshView) // Важно!
        .onReceive(NotificationCenter.default.publisher(for: .languageChanged)) { _ in
            refreshView.toggle() // Обновляет view при смене языка
        }
    }
}
```

## Примеры использования

### В навигации
```swift
.navigationTitle(L10n.profile)
```

### В кнопках
```swift
Button(action: { }) {
    Text(L10n.save)
}
```

### В динамических строках
```swift
Text("\(L10n.lesson) \(number)")
```

## Смена языка

Язык меняется автоматически когда пользователь переключает Picker в ProfileView:

```swift
Picker("", selection: $selectedLanguage) {
    Text("KG").tag("KG")
    Text("RU").tag("RU")
}
.onChange(of: selectedLanguage) { oldValue, newValue in
    AppLanguage.current = newValue // Это отправляет уведомление всем экранам
}
```

## Категории переводов

- **Profile Screen** - экран профиля
- **Lessons Screen** - экран уроков
- **Home Screen** - главный экран
- **Duel Screen** - экран дуэлей
- **Rating Screen** - экран рейтинга
- **Auth Screen** - экран авторизации
- **Common** - общие строки

## Добавление новой категории

1. Добавьте комментарий `// MARK: - Your Category` в Localizable.swift
2. Добавьте ваши переводы в формате выше
3. Используйте `L10n.yourString` в коде

## Важно!

- **Всегда** используйте `L10n.stringName` вместо прямых строк "Текст"
- **Всегда** добавляйте `.id(refreshView)` и `.onReceive` для автообновления
- **По умолчанию** язык - кыргызский (KG), если не выбран русский (RU)
