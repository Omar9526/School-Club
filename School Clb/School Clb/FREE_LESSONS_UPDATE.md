# Изменение количества бесплатных уроков: 6 → 3

## Изменённые файлы:

### 1. ✅ LessonsViewModel.swift — метод loadLevels()

**Было:**
```swift
CourseLevel(..., freeLessons: 6)  // Все три уровня
```

**Стало:**
```swift
CourseLevel(..., freeLessons: 3)  // Все три уровня (А, В, С)
```

**Изменённые строки:**
- Уровень А: `freeLessons: 6` → `freeLessons: 3`
- Уровень В: `freeLessons: 6` → `freeLessons: 3`
- Уровень С: `freeLessons: 6` → `freeLessons: 3`

### 2. ✅ LessonListView.swift — Preview

**Было:**
```swift
level: CourseLevel(..., freeLessons: 6)
```

**Стало:**
```swift
level: CourseLevel(..., freeLessons: 3)
```

### 3. ✅ Логика loadLessons() — уже корректна

```swift
isFree: i <= level.freeLessons
```

Эта логика работает правильно:
- Уроки 1, 2, 3 → `isFree = true` (бесплатные)
- Уроки 4-24 → `isFree = false` (премиум)

## Результат:

Теперь в каждом уровне (А, В, С):
- ✅ **3 бесплатных урока** (1, 2, 3)
- ✅ **21 премиум урок** (4-24)
- ✅ **1 пробный тест** (всегда бесплатный)

## Проверка в UI:

В LevelCard автоматически отображается корректная информация:
- "3 бесплатно" (вместо "6 бесплатно")
- "21 премиум" (вместо "18 премиум")

Никаких дополнительных изменений в LevelCard не требуется — там динамически вычисляется текст на основе `level.freeLessons` и `level.totalLessons`.
