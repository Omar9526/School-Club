# Разделение логики тестов по флагу hasVideoAnalysis

## Три вида тестов из ТЗ

### 1. ✅ Тест С ВИДЕОРАЗБОРОМ (hasVideoAnalysis = true)
**Поведение:**
- После проверки ответа НЕ показывать правильный вариант зелёным
- Если ошибка → подсветить ТОЛЬКО выбранный вариант красным
- Верный ответ НЕ раскрывать
- На экране результатов: количество правильных + кнопка «Видеоразбор теста»
- Список верных ответов НЕ показывать

### 2. ✅ Тест БЕЗ ВИДЕО (hasVideoAnalysis = false)
**Поведение:**
- После проверки показывать правильный вариант зелёным
- Если ошибка → красным + зелёным правильный
- В конце: количество правильных + список верных ответов

---

## Изменения в TestView.swift

### 1. ✅ AnswerButton — добавлен параметр showCorrectAnswer

```swift
struct AnswerButton: View {
    let letter: String
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let showCorrectAnswer: Bool  // ✅ НОВЫЙ параметр
    let action: () -> Void
    
    // ...
}
```

**Логика:**
```swift
// Фон и рамка зелёного цвета только если showCorrectAnswer == true
var backgroundColor: Color {
    if showCorrectAnswer && isCorrect {
        return Color.green.opacity(0.1)
    } else if isWrong {
        return Color.red.opacity(0.1)
    } else if isSelected {
        return Color(hex: "#1B2A6B").opacity(0.05)
    } else {
        return Color.white
    }
}

var borderColor: Color {
    if showCorrectAnswer && isCorrect {
        return Color.green
    } else if isWrong {
        return Color.red
    } else if isSelected {
        return Color(hex: "#1B2A6B")
    } else {
        return Color(hex: "#1B2A6B").opacity(0.2)
    }
}
```

**Кружок с буквой и иконка:**
```swift
// Зелёный кружок и галочка только если showCorrectAnswer == true
.fill((showCorrectAnswer && isCorrect) ? Color.green : (isWrong ? Color.red : Color(hex: "#1B2A6B")))

if showCorrectAnswer && isCorrect {
    Image(systemName: "checkmark.circle.fill")
        .foregroundColor(.green)
} else if isWrong {
    Image(systemName: "xmark.circle.fill")
        .foregroundColor(.red)
}
```

### 2. ✅ Вызовы AnswerButton — добавлен параметр

```swift
AnswerButton(
    letter: "А",
    text: question.optionA,
    isSelected: selectedAnswer == "A",
    isCorrect: isAnswerChecked && question.correctAnswer == "A",
    isWrong: isAnswerChecked && selectedAnswer == "A" && question.correctAnswer != "A",
    showCorrectAnswer: !hasVideoAnalysis,  // ✅ Управление показом
    action: { selectAnswer("A") }
)
```

**Ключевое:**
- `showCorrectAnswer: !hasVideoAnalysis`
- Если видео ЕСТЬ → НЕ показывать правильный ответ
- Если видео НЕТ → показывать правильный ответ

### 3. ✅ TestResultsView — уже корректен

Экран результатов уже учитывает `hasVideoAnalysis`:
```swift
// Видеоразбор (если есть)
if hasVideoAnalysis, let _ = lesson.videoAnalysisURL {
    NavigationLink(destination: VideoLessonView(lesson: lesson, isTheory: false)) {
        // Кнопка "Видеоразбор теста"
    }
}
```

---

## Примеры использования

### Тест с видеоразбором (из LessonListView):
```swift
NavigationLink(destination: TestView(lesson: lesson, viewModel: viewModel, hasVideoAnalysis: true))
```

**Результат:**
- ✅ Ошибся → видишь только красный крестик на своём варианте
- ❌ Правильный ответ НЕ показан зелёным
- 📹 В конце — кнопка "Видеоразбор теста"

### Тест без видео (из LessonListView):
```swift
NavigationLink(destination: TestView(lesson: lesson, viewModel: viewModel, hasVideoAnalysis: false))
```

**Результат:**
- ✅ Ошибся → видишь красный крестик + зелёную галочку на правильном
- ✅ Сразу видно, где правильный ответ
- 📝 В конце — просто результаты

---

## Сохранённый дизайн

- ✅ Синие кружки с белыми буквами (в обычном состоянии)
- ✅ Синий прогресс-бар
- ✅ Синяя кнопка "Проверить"
- ✅ Компактные размеры кнопок
- ✅ Зелёный/красный для правильных/неправильных (когда показываем)

---

## Ключевое отличие

| Параметр | hasVideoAnalysis = true | hasVideoAnalysis = false |
|----------|------------------------|-------------------------|
| Показ правильного ответа | ❌ НЕ показывать | ✅ Показывать |
| Зелёная подсветка | ❌ Нет | ✅ Да |
| Видеоразбор | ✅ Кнопка в конце | ❌ Нет |
| Цель | Мотивировать смотреть видео | Сразу учиться на ошибках |

Теперь логика полностью соответствует ТЗ! 🎯
