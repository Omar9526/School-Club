# Firebase Integration TODO

## Этап 3: Профиль

Сейчас ProfileViewModel работает с моковыми данными.

### Когда будете подключать Firebase:

1. **Установите Firebase SDK через SPM:**
   - File → Add Package Dependencies
   - Добавьте: `https://github.com/firebase/firebase-ios-sdk`
   - Выберите пакеты: FirebaseAuth, FirebaseFirestore, FirebaseStorage

2. **Замените ProfileViewModel.swift на версию с Firebase:**
   - Раскомментируйте импорты: `import FirebaseAuth`, `import FirebaseFirestore`, `import FirebaseStorage`
   - Замените метод `loadMockData()` на `loadUserProfile()` с запросом к Firestore
   - Подключите реальные методы обновления данных

3. **Структура данных в Firestore:**
   ```
   users/{userId}
     - fullName: String
     - username: String
     - email: String
     - district: String
     - school: String
     - isPremium: Bool
     - premiumUntil: Timestamp (optional)
     - avatarURL: String (optional)
     - vibe: String (emoji)
   
   users/{userId}/completedLessons/{lessonId}
     - completedAt: Timestamp
     - score: Number (optional)
   ```

4. **Firebase Storage для аватарок:**
   - Путь: `avatars/{userId}.jpg`
   - Сжатие: 0.5 quality JPEG

## Текущее состояние:
✅ UI полностью готов
✅ Логика работает с локальными данными
⏳ Ждёт подключения Firebase

## Следующие этапы после Firebase:
- Подключить реальную аутентификацию
- Синхронизировать AuthViewModel с ProfileViewModel
- Добавить обработку ошибок сети
