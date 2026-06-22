# Добавлен раздел "Пробные тесты" на экране уровней

## Изменения

### 1. ✅ CourseLevelsView.swift

#### Добавлено после списка уровней А/В/С:
```swift
// Пробные тесты
NavigationLink(destination: PracticeListView(course: course)) {
    PracticeTestsCard(courseLanguage: course.contentLanguage)
}
```

#### Новый компонент: PracticeTestsCard
```swift
struct PracticeTestsCard: View {
    let courseLanguage: String
    
    // Заголовок по языку курса
    var title: String {
        courseLanguage == "RU" ? "Пробные тесты" : "Сынамык тесттер"
    }
    
    var subtitle: String {
        courseLanguage == "RU" ? "Полноценные пробные тесты ОРТ" : "ЖРТнын толук сынамык тесттери"
    }
}
```

**Дизайн:**
- Жёлтая рамка `Color(hex: "#FFE600")`
- Иконка `star.circle.fill` жёлтого цвета
- Жёлтая тень для акцента
- Стиль как у карточек уровней

---

### 2. ✅ PracticeListView.swift (НОВЫЙ ФАЙЛ)

#### Структура экрана:
```
Иконка: star.circle.fill (большая, жёлтая)
Заголовок: "Пробные тесты" / "Сынамык тесттер"
Подпись: "Выберите пробный тест"
─────────────────────────
[★ №1] Пробный тест №1
       100 вопросов | 180 мин
       
[★ №2] Пробный тест №2
       100 вопросов | 180 мин
       
[★ №3] Пробный тест №3
       100 вопросов | 180 мин
```

#### Mock-данные:
```swift
struct PracticeTest: Identifiable {
    let id: String
    let numberKg: String
    let numberRu: String
    let titleKg: String
    let titleRu: String
    let descriptionKg: String
    let descriptionRu: String
    let questionCount: Int
    
    func toLesson() -> Lesson {
        // Конвертация в Lesson для PracticeTestView
    }
}
```

**3 пробных теста:**
- Пробный тест №1 (Сынамык тест №1)
- Пробный тест №2 (Сынамык тест №2)
- Пробный тест №3 (Сынамык тест №3)

#### Компонент: PracticeTestCard
**Дизайн:**
- Кружок с жёлтым градиентом
- Звёздочка + номер теста
- Информация: количество вопросов + время (180 мин)
- Жёлтая рамка (opacity 0.3)
- Белый фон

#### Навигация:
```swift
NavigationLink(destination: PracticeTestView(
    lesson: test.toLesson(),
    viewModel: viewModel
))
```

Открывает существующий **PracticeTestView** с:
- Разбором вопросов после каждого ответа
- Детальными результатами в конце
- Кнопкой "Видеоразбор теста"

---

## Двуязычность (KG/RU)

### Русский (RU):
- "Пробные тесты"
- "Полноценные пробные тесты ОРТ"
- "Выберите пробный тест"
- "Пробный тест №1/2/3"
- "100 вопросов"
- "180 мин"

### Кыргызский (KG):
- "Сынамык тесттер"
- "ЖРТнын толук сынамык тесттери"
- "Сынамык тестти тандаңыз"
- "Сынамык тест №1/2/3"
- "100 суроо"
- "180 мүн"

---

## Дизайн-система

### Цвета:
- **Жёлтый #FFE600**: акцент для пробных тестов
  - Иконки, рамки, тени
  - Градиенты для кружков
- **Синий #1B2A6B**: основной текст
- **Белый**: фон карточек
- **Серый #F5F5F5**: фон экрана

### Иконки:
- `star.circle.fill` — пробные тесты
- `star.fill` — внутри карточек
- `doc.text.fill` — количество вопросов
- `clock.fill` — время

### Стиль:
- Rounded шрифты
- Тени: `Color.black.opacity(0.05)` для обычных карточек
- Жёлтая тень для акцента: `Color(hex: "#FFE600").opacity(0.2)`
- cornerRadius: 12pt

---

## Путь пользователя

1. **LessonsView** → выбрать курс
2. **CourseLevelsView** → видит уровни А, В, С + "Пробные тесты" внизу
3. **PracticeListView** → выбрать №1, №2 или №3
4. **PracticeTestView** → пройти 100 вопросов с разбором

---

## Готово к Firebase

Позже можно заменить mock-данные:
```swift
// Вместо hardcoded массива
practiceTests = await FirestoreService.loadPracticeTests(courseId: course.id)
```

Структура уже готова для загрузки реальных тестов из базы данных.
