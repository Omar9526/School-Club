# ⏰ TIME AGO - Автоматическое обновление времени

## 📋 Как работает сейчас:

### Текущая реализация (английский):
```swift
var timeAgo: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short  // Короткий формат
    return formatter.localizedString(for: timestamp, relativeTo: Date())
}
```

### Примеры вывода:
- 0 секунд → **"now"** или **"0 sec ago"**
- 30 секунд → **"30 sec ago"**
- 1 минута → **"1 min ago"**
- 5 минут → **"5 min ago"**
- 35 минут → **"35 min ago"**
- 1 час → **"1 hr ago"**
- 2 часа → **"2 hr ago"**
- 1 день → **"1 day ago"**
- 1 неделя → **"1 wk ago"**

---

## 🇷🇺 Русская локализация (опционально):

### Вариант 1: Стандартный iOS (автоматически):

Если устройство на русском языке, `RelativeDateTimeFormatter` **автоматически** покажет русский текст:
- "только что"
- "30 сек. назад"
- "1 мин. назад"
- "5 мин. назад"
- "1 ч. назад"

**Ничего менять не нужно!** iOS сам определяет язык устройства.

---

### Вариант 2: Кастомная функция (полный контроль):

Если нужен свой формат:

```swift
var timeAgo: String {
    let now = Date()
    let interval = now.timeIntervalSince(timestamp)
    
    switch interval {
    case 0..<10:
        return "только что"
    case 10..<60:
        return "\(Int(interval)) сек назад"
    case 60..<3600:
        let minutes = Int(interval / 60)
        return "\(minutes) мин назад"
    case 3600..<86400:
        let hours = Int(interval / 3600)
        return "\(hours) ч назад"
    case 86400..<604800:
        let days = Int(interval / 86400)
        return "\(days) д назад"
    default:
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: timestamp)
    }
}
```

#### Примеры:
- 5 секунд → **"только что"**
- 30 секунд → **"30 сек назад"**
- 3 минуты → **"3 мин назад"**
- 35 минут → **"35 мин назад"**
- 2 часа → **"2 ч назад"**
- 1 день → **"1 д назад"**
- > 7 дней → **"15.06.2026"** (дата)

---

### Вариант 3: Умный формат (как в Telegram):

```swift
var timeAgo: String {
    let now = Date()
    let interval = now.timeIntervalSince(timestamp)
    let calendar = Calendar.current
    
    // Меньше минуты
    if interval < 60 {
        return "только что"
    }
    
    // Меньше часа
    if interval < 3600 {
        let minutes = Int(interval / 60)
        return "\(minutes) мин"
    }
    
    // Сегодня
    if calendar.isDateInToday(timestamp) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
    
    // Вчера
    if calendar.isDateInYesterday(timestamp) {
        return "вчера"
    }
    
    // Меньше недели
    if interval < 604800 {
        let days = Int(interval / 86400)
        return "\(days) д назад"
    }
    
    // Старше недели
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: timestamp)
}
```

#### Примеры:
- 30 секунд → **"только что"**
- 5 минут → **"5 мин"**
- 35 минут → **"35 мин"**
- Сегодня 14:30 → **"14:30"**
- Вчера → **"вчера"**
- 3 дня назад → **"3 д назад"**
- > 7 дней → **"15.06.2026"**

---

## ⏱ Автоматическое обновление:

### Текущее поведение:
- SwiftUI пересчитывает `timeAgo` **каждый раз при рендере**
- Когда обновляется список сообщений, время обновляется автоматически
- Но НЕ обновляется каждую секунду в реальном времени

### Если нужно обновление каждую минуту:

```swift
struct GroupMessageBubble: View {
    let message: GroupMessage
    @State private var currentTime = Date()
    
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            // ... ваш код
            
            Text(message.timeAgo(relativeTo: currentTime))
                .onReceive(timer) { _ in
                    currentTime = Date()
                }
        }
    }
}
```

---

## 🎯 Рекомендация:

**Лучший вариант** - оставить как есть (`RelativeDateTimeFormatter`), потому что:

1. ✅ **Автоматически** на русском, если устройство на русском
2. ✅ **Стандарт iOS** - пользователи привыкли к этому формату
3. ✅ **Минимум кода**
4. ✅ **Работает везде** (iOS, macOS, watchOS)

Но если хочешь **кастомный формат** (как в Telegram), я могу добавить!

---

## 📱 Проверка:

**Шаг 1:** Отправь сообщение в чат  
**Шаг 2:** Закрой приложение  
**Шаг 3:** Открой через 3 минуты  
**Шаг 4:** Увидишь **"3 min ago"** (или **"3 мин назад"** если устройство на русском)

---

## 🔧 Что выбрать?

1. **Оставить как есть** (RelativeDateTimeFormatter) - ничего не делать ✅
2. **Кастомная функция** - я добавлю код с "только что", "мин", "ч", "д" 
3. **Как в Telegram** - "только что", потом время "14:30", потом дата

**Какой вариант тебе нравится больше?** 🚀
