# Доработка зума и перемещения видео в VideoLessonView

## Изменения

### 1. ✅ Добавлены новые состояния для offset (смещения)

```swift
@State private var currentScale: CGFloat = 1.0
@State private var currentOffset: CGSize = .zero     // ✅ НОВОЕ: текущее смещение
@State private var lastOffset: CGSize = .zero        // ✅ НОВОЕ: последнее смещение
```

---

### 2. ✅ Заменён жест: MagnificationGesture → SimultaneousGesture

**Было:**
```swift
.gesture(
    MagnificationGesture()
        .onChanged { value in
            currentScale = min(max(value, 1.0), 3.0)
        }
)
```

**Стало:**
```swift
.scaleEffect(currentScale)
.offset(currentOffset)  // ✅ НОВОЕ: применяем смещение
.gesture(
    SimultaneousGesture(
        // Жест 1: Зум (pinch)
        MagnificationGesture()
            .onChanged { value in
                currentScale = min(max(value, 1.0), 3.0)
            }
            .onEnded { _ in
                // Если зум сброшен до 1x, сбросить offset
                if currentScale == 1.0 {
                    withAnimation(.spring()) {
                        currentOffset = .zero
                        lastOffset = .zero
                    }
                }
            },
        
        // Жест 2: Перемещение (drag)
        DragGesture()
            .onChanged { value in
                // Перемещать можно только при зуме > 1x
                if currentScale > 1.0 {
                    currentOffset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                lastOffset = currentOffset
            }
    )
)
```

---

## Как работает

### Зум (MagnificationGesture):
- ✅ Pinch-to-zoom: увеличение 1x → 3x
- ✅ При сбросе зума до 1x → автоматически сбрасывается offset (с анимацией)

### Перемещение (DragGesture):
- ✅ Работает **только при currentScale > 1.0**
- ✅ Позволяет перемещать увеличенную картинку пальцем
- ✅ Сохраняет последнее положение (lastOffset)
- ✅ При следующем драге продолжает с последней позиции

### SimultaneousGesture:
- ✅ Оба жеста работают **одновременно**
- ✅ Можно зумить и двигать картинку без конфликтов

---

## Сценарии использования

### 1. Увеличить часть видео:
1. Пользователь делает pinch (сводит/разводит пальцы)
2. Видео увеличивается (1x → 2x → 3x)
3. Часть картинки теперь выходит за пределы экрана

### 2. Посмотреть скрытую область:
1. При увеличенном видео (scale > 1x)
2. Пользователь двигает пальцем (drag)
3. Видео перемещается, показывая скрытые части

### 3. Сбросить зум:
1. Пользователь pinch обратно до 1x
2. Автоматически срабатывает анимированный сброс offset
3. Видео возвращается в центр

---

## Преимущества

### ✅ Удобство:
- Можно рассмотреть детали на видео (текст, формулы, графики)
- Плавное перемещение увеличенной области
- Анимированный возврат в исходное положение

### ✅ UX:
- Жесты работают интуитивно (как в Photos.app)
- Перемещение доступно только при зуме (не мешает обычному просмотру)
- Spring-анимация делает взаимодействие приятным

### ✅ Защита контента:
- Все существующие механизмы защиты сохранены
- Screenshot prevention работает
- Баннер "Защита контента" не изменён

---

## Технические детали

### currentOffset vs lastOffset:
```swift
currentOffset  // Текущее положение во время драга
lastOffset     // Запомненное положение после завершения драга
```

При начале нового драга:
```swift
currentOffset = lastOffset + translation
```

### Ограничение зума:
```swift
currentScale = min(max(value, 1.0), 3.0)
// min = 1.0 (не меньше)
// max = 3.0 (не больше)
```

### Условие перемещения:
```swift
if currentScale > 1.0 {
    // Разрешаем drag только при увеличении
}
```

---

## Не затронуто

✅ AVPlayer и VideoPlayer
✅ setupPlayer()
✅ setupScreenshotPrevention()
✅ Описание урока
✅ Баннер "Защита контента"
✅ Все остальные UI-элементы

Только добавлена возможность **перемещать увеличенное видео**!
