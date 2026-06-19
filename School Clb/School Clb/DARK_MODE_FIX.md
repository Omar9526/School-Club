# Исправление темной темы в PremiumView

## Проблема
В темной теме iOS текст и элементы интерфейса не были видны из-за использования статических цветов:
- Текст "Тариф STUDENT доступен только для студентов School Club" был светло-серым
- Фон карточек был белым
- Текст в карточках тарифов использовал темный цвет `#1B2A6B`

## Исправления

### 1. Адаптивные цвета текста
**Было:**
```swift
.foregroundColor(.gray)
.foregroundColor(Color(hex: "#1B2A6B"))
```

**Стало:**
```swift
.foregroundColor(.primary)     // Автоматически белый/черный
.foregroundColor(.secondary)   // Автоматически серый с адаптацией
```

### 2. Адаптивные фоны
**Было:**
```swift
.background(Color.white)
.background(Color(hex: "#F5F5F5"))
```

**Стало:**
```swift
.background(Color(uiColor: .systemBackground))           // Для карточек
.background(Color(uiColor: .systemGroupedBackground))   // Для экрана
```

### 3. Улучшенная карточка информации
**Было:**
```swift
Text("...")
    .foregroundColor(.gray)
    .background(Color.white)
```

**Стало:**
```swift
Text("...")
    .foregroundColor(.primary)  // Видно в обеих темах
    .background(Color(uiColor: .systemBackground))
    .shadow(color: Color.black.opacity(0.05), radius: 8)
```

## Системные цвета iOS

Использованные адаптивные цвета:
- `.primary` - Основной текст (черный/белый)
- `.secondary` - Вторичный текст (серый, адаптируется)
- `Color(uiColor: .systemBackground)` - Фон карточек
- `Color(uiColor: .systemGroupedBackground)` - Фон экрана

## Результат
✅ Все элементы теперь видны в светлой и темной теме
✅ Автоматическая адаптация при переключении темы
✅ Соблюдение гайдлайнов Apple HIG
✅ Кнопка "Записаться в School Club" не перекрывается таб-баром (добавлен отступ 100pt снизу)

## Дополнительные исправления

### 4. Отступ для таб-бара
**Проблема:** Синяя кнопка "Записаться в School Club" скрывалась за нижним таб-баром

**Решение:**
```swift
VStack(spacing: 30) {
    // ... контент
}
.padding(20)
.padding(.bottom, 100) // Отступ снизу для таб-бара
```

Теперь при прокрутке вниз весь контент виден полностью.

## Файлы изменены
- `PremiumView.swift` - адаптация для темной темы + отступ для таб-бара
- `ProfileView.swift` - адаптация для темной темы + отступ для таб-бара

## Дата исправления
17 июня 2026
