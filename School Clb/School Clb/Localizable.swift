//
//  Localizable.swift
//  School Club
//
//  Created on 20.05.2026
//

import Foundation

class AppLanguage {
    static var current: String {
        get {
            UserDefaults.standard.string(forKey: "appLanguage") ?? "KG"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "appLanguage")
            NotificationCenter.default.post(name: .languageChanged, object: nil)
        }
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}

enum L10n {
    // MARK: - Profile Screen
    static var profile: String {
        switch AppLanguage.current {
        case "RU": return "Профиль"
        default: return "Профайл"
        }
    }
    
    static var myVibe: String {
        switch AppLanguage.current {
        case "RU": return "Мой вайб"
        default: return "Менин вайбым"
        }
    }
    
    static var lessonProgress: String {
        switch AppLanguage.current {
        case "RU": return "Прогресс уроков"
        default: return "Сабактардын прогресси"
        }
    }
    
    static var lastLesson: String {
        switch AppLanguage.current {
        case "RU": return "Акыркы сабак:"
        default: return "Акыркы сабак:"
        }
    }
    
    static var premiumAccount: String {
        switch AppLanguage.current {
        case "RU": return "Премиум аккаунт"
        default: return "Премиум аккаунт"
        }
    }
    
    static var activeUntil: String {
        switch AppLanguage.current {
        case "RU": return "Активен до"
        default: return "Активдүү болот"
        }
    }
    
    static var freeAccount: String {
        switch AppLanguage.current {
        case "RU": return "Бесплатный аккаунт"
        default: return "Акысыз аккаунт"
        }
    }
    
    static var becomePremium: String {
        switch AppLanguage.current {
        case "RU": return "Стать Премиум"
        default: return "Премиум болуу"
        }
    }
    
    static var account: String {
        switch AppLanguage.current {
        case "RU": return "АККАУНТ"
        default: return "АККАУНТ"
        }
    }
    
    static var editProfile: String {
        switch AppLanguage.current {
        case "RU": return "Редактировать профиль"
        default: return "Профайлды өзгөртүү"
        }
    }
    
    static var editorPanel: String {
        switch AppLanguage.current {
        case "RU": return "Панель редактора"
        default: return "Редактордун панели"
        }
    }
    
    static var getHelp: String {
        switch AppLanguage.current {
        case "RU": return "Обратиться за помощью"
        default: return "Жардам суроо"
        }
    }
    
    static var documents: String {
        switch AppLanguage.current {
        case "RU": return "ДОКУМЕНТЫ"
        default: return "ДОКУМЕНТТЕР"
        }
    }
    
    static var publicOffer: String {
        switch AppLanguage.current {
        case "RU": return "Публичная оферта"
        default: return "Ачык оферта"
        }
    }
    
    static var privacyPolicy: String {
        switch AppLanguage.current {
        case "RU": return "Политика конфиденциальности"
        default: return "Купуялуулук саясаты"
        }
    }
    
    static var aboutCompany: String {
        switch AppLanguage.current {
        case "RU": return "О компании Скул Клаб"
        default: return "Скул Клаб жөнүндө"
        }
    }
    
    static var language: String {
        switch AppLanguage.current {
        case "RU": return "ЯЗЫК"
        default: return "ТИЛ"
        }
    }
    
    static var languageLabel: String {
        switch AppLanguage.current {
        case "RU": return "Тил / Язык"
        default: return "Тил / Язык"
        }
    }
    
    static var signOut: String {
        switch AppLanguage.current {
        case "RU": return "Выход"
        default: return "Чыгуу"
        }
    }
    
    static var version: String {
        switch AppLanguage.current {
        case "RU": return "Версия"
        default: return "Версия"
        }
    }
    
    // MARK: - Lessons Screen
    static var lessons: String {
        switch AppLanguage.current {
        case "RU": return "Уроки"
        default: return "Сабактар"
        }
    }
    
    static var categoryORT: String {
        switch AppLanguage.current {
        case "RU": return "SC | Все про ОРТ"
        default: return "SC | ЖРТ жөнүндө"
        }
    }
    
    static var categoryHimBio: String {
        switch AppLanguage.current {
        case "RU": return "Все про ХИМБИО"
        default: return "ХИМБИО жөнүндө"
        }
    }
    
    static var categoryOther: String {
        switch AppLanguage.current {
        case "RU": return "Другое"
        default: return "Башка"
        }
    }
    
    static var levelsCount: String {
        switch AppLanguage.current {
        case "RU": return "уровня"
        default: return "деңгээл"
        }
    }
    
    static var levels: String {
        switch AppLanguage.current {
        case "RU": return "Уровни"
        default: return "Деңгээлдер"
        }
    }
    
    static var selectLevel: String {
        switch AppLanguage.current {
        case "RU": return "Выберите уровень для начала обучения"
        default: return "Окууну баштоо үчүн деңгээлди тандаңыз"
        }
    }
    
    static var lessonsCount: String {
        switch AppLanguage.current {
        case "RU": return "урока"
        default: return "сабак"
        }
    }
    
    static var lessonsWord: String {
        switch AppLanguage.current {
        case "RU": return "урока"
        default: return "сабак"
        }
    }
    
    // Функция для правильного склонения "урок/урока/уроков"
    static func lessonsCount(_ count: Int) -> String {
        switch AppLanguage.current {
        case "RU":
            let lastDigit = count % 10
            let lastTwoDigits = count % 100
            
            if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
                return "\(count) уроков"
            } else if lastDigit == 1 {
                return "\(count) урок"
            } else if lastDigit >= 2 && lastDigit <= 4 {
                return "\(count) урока"
            } else {
                return "\(count) уроков"
            }
        default:
            return "\(count) сабак"
        }
    }
    
    static var free: String {
        switch AppLanguage.current {
        case "RU": return "бесплатно"
        default: return "акысыз"
        }
    }
    
    static var premium: String {
        switch AppLanguage.current {
        case "RU": return "премиум"
        default: return "премиум"
        }
    }
    
    static var progress: String {
        switch AppLanguage.current {
        case "RU": return "Прогресс"
        default: return "Прогресс"
        }
    }
    
    static var points: String {
        switch AppLanguage.current {
        case "RU": return "балл"
        default: return "упай"
        }
    }
    
    static var beginner: String {
        switch AppLanguage.current {
        case "RU": return "Начинающий"
        default: return "Баштоочу"
        }
    }
    
    static var intermediate: String {
        switch AppLanguage.current {
        case "RU": return "Средний"
        default: return "Орточо"
        }
    }
    
    static var advanced: String {
        switch AppLanguage.current {
        case "RU": return "Продвинутый"
        default: return "Жогорку"
        }
    }
    
    static var lesson: String {
        switch AppLanguage.current {
        case "RU": return "Урок"
        default: return "Сабак"
        }
    }
    
    static var locked: String {
        switch AppLanguage.current {
        case "RU": return "Закрыто"
        default: return "Жабык"
        }
    }
    
    static var completed: String {
        switch AppLanguage.current {
        case "RU": return "Завершено"
        default: return "Бүттү"
        }
    }
    
    // MARK: - Home Screen
    static var home: String {
        switch AppLanguage.current {
        case "RU": return "Главная"
        default: return "Башкы"
        }
    }
    
    static var greeting: String {
        switch AppLanguage.current {
        case "RU": return "Привет"
        default: return "Салам"
        }
    }
    
    static var continueLesson: String {
        switch AppLanguage.current {
        case "RU": return "Продолжить урок"
        default: return "Сабакты улантуу"
        }
    }
    
    static var startLesson: String {
        switch AppLanguage.current {
        case "RU": return "Начать урок"
        default: return "Сабакты баштоо"
        }
    }
    
    // MARK: - Duel Screen
    static var duel: String {
        switch AppLanguage.current {
        case "RU": return "Дуэль"
        default: return "Дуэль"
        }
    }
    
    static var findOpponent: String {
        switch AppLanguage.current {
        case "RU": return "Найти соперника"
        default: return "Атаандашты табуу"
        }
    }
    
    static var searching: String {
        switch AppLanguage.current {
        case "RU": return "Поиск..."
        default: return "Издөө..."
        }
    }
    
    static var cancel: String {
        switch AppLanguage.current {
        case "RU": return "Отмена"
        default: return "Жокко чыгаруу"
        }
    }
    
    // MARK: - Rating Screen
    static var rating: String {
        switch AppLanguage.current {
        case "RU": return "Рейтинг"
        default: return "Рейтинг"
        }
    }
    
    static var yourPosition: String {
        switch AppLanguage.current {
        case "RU": return "Ваша позиция"
        default: return "Сиздин орунуңуз"
        }
    }
    
    static var pointsPlural: String {
        switch AppLanguage.current {
        case "RU": return "баллов"
        default: return "упай"
        }
    }
    
    // MARK: - Auth Screen
    static var welcome: String {
        switch AppLanguage.current {
        case "RU": return "Добро пожаловать"
        default: return "Кош келиңиз"
        }
    }
    
    static var signIn: String {
        switch AppLanguage.current {
        case "RU": return "Войти"
        default: return "Кирүү"
        }
    }
    
    static var signUp: String {
        switch AppLanguage.current {
        case "RU": return "Регистрация"
        default: return "Катталуу"
        }
    }
    
    static var email: String {
        switch AppLanguage.current {
        case "RU": return "Email"
        default: return "Email"
        }
    }
    
    static var password: String {
        switch AppLanguage.current {
        case "RU": return "Пароль"
        default: return "Сыр сөз"
        }
    }
    
    static var fullName: String {
        switch AppLanguage.current {
        case "RU": return "Полное имя"
        default: return "Толук аты"
        }
    }
    
    static var username: String {
        switch AppLanguage.current {
        case "RU": return "Имя пользователя"
        default: return "Колдонуучу аты"
        }
    }
    
    static var district: String {
        switch AppLanguage.current {
        case "RU": return "Район"
        default: return "Район"
        }
    }
    
    static var school: String {
        switch AppLanguage.current {
        case "RU": return "Школа"
        default: return "Мектеп"
        }
    }
    
    // MARK: - Common
    static var save: String {
        switch AppLanguage.current {
        case "RU": return "Сохранить"
        default: return "Сактоо"
        }
    }
    
    static var loading: String {
        switch AppLanguage.current {
        case "RU": return "Загрузка..."
        default: return "Жүктөлүүдө..."
        }
    }
    
    static var error: String {
        switch AppLanguage.current {
        case "RU": return "Ошибка"
        default: return "Ката"
        }
    }
    
    static var ok: String {
        switch AppLanguage.current {
        case "RU": return "ОК"
        default: return "Макул"
        }
    }
    
    // MARK: - Tab Bar
    static var tabLessons: String {
        switch AppLanguage.current {
        case "RU": return "УРОКИ"
        default: return "САБАКТАР"
        }
    }
    
    static var tabMovement: String {
        switch AppLanguage.current {
        case "RU": return "КУРС"
        default: return "КУРС"
        }
    }
    
    static var tabBreak: String {
        switch AppLanguage.current {
        case "RU": return "БРЕЙК"
        default: return "БРЕЙК"
        }
    }
    
    static var tabChat: String {
        switch AppLanguage.current {
        case "RU": return "ЧАТ"
        default: return "ЧАТ"
        }
    }
    
    static var tabProfile: String {
        switch AppLanguage.current {
        case "RU": return "ПРОФИЛЬ"
        default: return "ПРОФАЙЛ"
        }
    }
    
    // MARK: - Lesson List Screen
    static var practiceTestTitle: String {
        switch AppLanguage.current {
        case "RU": return "Пробный тест для оценки уровня"
        default: return "Деңгээлди баалоо үчүн сынамык тест"
        }
    }
    
    static var premiumRequired: String {
        switch AppLanguage.current {
        case "RU": return "Премиум требуется"
        default: return "Премиум керек"
        }
    }
    
    static var premiumMessage: String {
        switch AppLanguage.current {
        case "RU": return "Этот урок доступен только для премиум-подписчиков"
        default: return "Бул сабак премиум жазылуучулар үчүн гана жеткиликтүү"
        }
    }
    
    static var buyPremium: String {
        switch AppLanguage.current {
        case "RU": return "Купить Премиум"
        default: return "Премиум сатып алуу"
        }
    }
    
    static var videoLesson: String {
        switch AppLanguage.current {
        case "RU": return "ВИДЕОСАБАК"
        default: return "ВИДЕОСАБАК"
        }
    }
    
    static var theory: String {
        switch AppLanguage.current {
        case "RU": return "теория"
        default: return "теория"
        }
    }
    
    static var doTest: String {
        switch AppLanguage.current {
        case "RU": return "ТЕСТ ИШТӨӨ"
        default: return "ТЕСТ ИШТӨӨ"
        }
    }
    
    static var videoAnalysis: String {
        switch AppLanguage.current {
        case "RU": return "+ видеоталдоо"
        default: return "+ видеоталдоо"
        }
    }
    
    static var testAlone: String {
        switch AppLanguage.current {
        case "RU": return "ТЕСТ — өз алдынча иштөө"
        default: return "ТЕСТ — өз алдынча иштөө"
        }
    }
    
    // MARK: - Movement Screen
    static var movement: String {
        switch AppLanguage.current {
        case "RU": return "Движ"
        default: return "Кыймыл"
        }
    }
    
    static var progressTitle: String {
        switch AppLanguage.current {
        case "RU": return "ПРОГРЕСС"
        default: return "ПРОГРЕСС"
        }
    }
    
    static var activity: String {
        switch AppLanguage.current {
        case "RU": return "Активность"
        default: return "Активдүүлүк"
        }
    }
    
    static var pointsTitle: String {
        switch AppLanguage.current {
        case "RU": return "БАЛЛЫ"
        default: return "УПАЙЛАР"
        }
    }
    
    static var spendPoints: String {
        switch AppLanguage.current {
        case "RU": return "Потратить баллы"
        default: return "Упайларды коротуу"
        }
    }
    
    static var activities: String {
        switch AppLanguage.current {
        case "RU": return "АКТИВНОСТИ"
        default: return "АКТИВДҮҮЛҮКТӨР"
        }
    }
    
    // MARK: - Break Screen
    static var breakTitle: String {
        switch AppLanguage.current {
        case "RU": return "Брейк"
        default: return "Брейк"
        }
    }
    
    static var myGroup: String {
        switch AppLanguage.current {
        case "RU": return "МОЯ ГРУППА"
        default: return "МЕНИН ТОБУМ"
        }
    }
    
    static var myFriends: String {
        switch AppLanguage.current {
        case "RU": return "МОИ ДРУЗЬЯ"
        default: return "МЕНИН ДОСТОРУМ"
        }
    }
    
    static var dailyChallenge: String {
        switch AppLanguage.current {
        case "RU": return "ВЫЗОВ ДНЯ"
        default: return "КҮНДҮН ЧАКЫРЫГЫ"
        }
    }
    
    static var duelTitle: String {
        switch AppLanguage.current {
        case "RU": return "РАЗ НА РАЗ"
        default: return "ТЕК ТЕКТЕН"
        }
    }
    
    static var quiz: String {
        switch AppLanguage.current {
        case "RU": return "ВИКТОРИНА"
        default: return "ВИКТОРИНА"
        }
    }
    
    static var gamesBySubjects: String {
        switch AppLanguage.current {
        case "RU": return "ИГРЫ ПО ПРЕДМЕТАМ"
        default: return "САБАКТАР БОЮНЧА ОЮНДАР"
        }
    }
    
    static var mathematics: String {
        switch AppLanguage.current {
        case "RU": return "Математика"
        default: return "Математика"
        }
    }
    
    static var physics: String {
        switch AppLanguage.current {
        case "RU": return "Физика"
        default: return "Физика"
        }
    }
    
    static var chemistry: String {
        switch AppLanguage.current {
        case "RU": return "Химия"
        default: return "Химия"
        }
    }
    
    static var biology: String {
        switch AppLanguage.current {
        case "RU": return "Биология"
        default: return "Биология"
        }
    }
    
    static var history: String {
        switch AppLanguage.current {
        case "RU": return "История"
        default: return "Тарых"
        }
    }
    
    static var geography: String {
        switch AppLanguage.current {
        case "RU": return "География"
        default: return "География"
        }
    }
    
    // MARK: - Chat Screen
    static var sos: String {
        switch AppLanguage.current {
        case "RU": return "SOS"
        default: return "SOS"
        }
    }
    
    static var forumChat: String {
        switch AppLanguage.current {
        case "RU": return "ФОРУМ / ЧАТ"
        default: return "ФОРУМ / ЧАТ"
        }
    }
    
    static var aiTeacher: String {
        switch AppLanguage.current {
        case "RU": return "ИИ ПРЕПОДАВАТЕЛЬ"
        default: return "ИИ МУГАЛИМ"
        }
    }
    
    // MARK: - Premium Screen
    static var premiumTitle: String {
        switch AppLanguage.current {
        case "RU": return "Premium"
        default: return "Premium"
        }
    }
    
    static var close: String {
        switch AppLanguage.current {
        case "RU": return "Закрыть"
        default: return "Жабуу"
        }
    }
    
    static var success: String {
        switch AppLanguage.current {
        case "RU": return "Успех!"
        default: return "Ийгилик!"
        }
    }
    
    static var great: String {
        switch AppLanguage.current {
        case "RU": return "Отлично!"
        default: return "Сонун!"
        }
    }
    
    static var premiumSuccessMessage: String {
        switch AppLanguage.current {
        case "RU": return "Вы успешно оформили Premium подписку!"
        default: return "Сиз Premium жазылууну ийгиликтүү алдыңыз!"
        }
    }
}
