# 🐛 ОТЛАДКА: Фото не загружается в чате

## 📋 Проблема
При попытке загрузить фото через кнопку [+] → "Фото или видео" ничего не происходит.

## 🔍 Возможные причины:

### 1. ❗️ Отсутствуют разрешения в Info.plist

PhotosPicker требует разрешения для доступа к галерее.

**Проверьте Info.plist:**

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Необходим доступ к фото для отправки в чате</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Необходим доступ для сохранения фото</string>
```

**Как добавить в Xcode:**
1. Откройте `Info.plist` в проекте
2. Нажмите `+` для добавления новой строки
3. Выберите `Privacy - Photo Library Usage Description`
4. Введите: "Необходим доступ к фото для отправки в чате"
5. Повторите для `Privacy - Photo Library Additions Usage Description`

---

### 2. 🖨 Отладка с принтами

Я добавил принты в код для отладки:

```swift
.onChange(of: selectedPhoto) { _, newValue in
    Task {
        print("🖼 PrivateChat: PhotosPicker изменился")  // Проверяем, срабатывает ли onChange
        if let data = try? await newValue?.loadTransferable(type: Data.self) {
            print("✅ PrivateChat: Данные загружены, размер: \(data.count) байт")
            if UIImage(data: data) != nil {
                selectedImageData = data
                print("✅ PrivateChat: Изображение установлено")
            } else {
                print("⚠️ PrivateChat: Не удалось создать UIImage")
            }
        } else {
            print("❌ PrivateChat: Не удалось загрузить данные")
        }
    }
}
```

**Откройте консоль Xcode и посмотрите:**
- Если видите `🖼 PhotosPicker изменился` → onChange срабатывает
- Если видите `✅ Данные загружены` → загрузка работает
- Если видите `❌ Не удалось загрузить данные` → проблема с loadTransferable

---

### 3. 📱 Проверка на симуляторе vs реальное устройство

**Симулятор:**
- Может не иметь фотографий в галерее
- Добавьте тестовые фото через Safari или перетаскиванием

**Реальное устройство:**
- Проверьте разрешения в Настройки → School Club → Фото → Выбрать "Все фото"

---

### 4. 🔧 Альтернативное решение: UIImagePickerController

Если PhotosPicker не работает, можно использовать UIKit:

```swift
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}
```

---

### 5. 🎯 Быстрая проверка

**Шаг 1:** Запустите приложение
**Шаг 2:** Откройте личный чат
**Шаг 3:** Нажмите [+]
**Шаг 4:** Выберите "Фото или видео"
**Шаг 5:** Посмотрите в консоль Xcode

**Что должно быть:**
```
🖼 PrivateChat: PhotosPicker изменился
✅ PrivateChat: Данные загружены, размер: 1234567 байт
✅ PrivateChat: Изображение установлено
```

**Если ничего не видно:**
- PhotosPicker не открывается → проблема с Info.plist
- PhotosPicker открывается, но onChange не срабатывает → проблема с SwiftUI
- onChange срабатывает, но данные не загружаются → проблема с типом файла

---

### 6. 🔍 Проверка кода превью

Убедитесь, что превью отображается:

```swift
// Превью прикрепленных файлов
if selectedImageData != nil || selectedVideoURL != nil {
    attachmentPreview  // ✅ Должно показаться
        .padding(.horizontal, 12)
        .padding(.top, 8)
}
```

Если `selectedImageData` установлено, но превью не видно, проверьте `attachmentPreview`:

```swift
private var attachmentPreview: some View {
    HStack {
        if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        
        Spacer()
        
        Button(action: {
            selectedImageData = nil
            selectedVideoURL = nil
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .font(.system(size: 24))
        }
    }
    .padding(8)
    .background(Color(uiColor: .secondarySystemBackground))
    .cornerRadius(8)
}
```

---

## ✅ Чек-лист для исправления:

- [ ] Добавлены разрешения в Info.plist (NSPhotoLibraryUsageDescription)
- [ ] Проверена консоль на принты
- [ ] Тестовые фото добавлены в симулятор/устройство
- [ ] PhotosPicker открывается при нажатии на меню
- [ ] При выборе фото onChange срабатывает
- [ ] selectedImageData заполняется данными
- [ ] Превью отображается над полем ввода
- [ ] Кнопка отправки активируется

---

## 📅 Дата: 17 июня 2026

## 🎯 Следующие шаги:

1. Проверьте консоль Xcode на принты
2. Добавьте разрешения в Info.plist (если их нет)
3. Отправьте скриншот консоли или сообщите, что видите

**Я помогу дальше, как только узнаю, что показывает консоль!** 🚀
