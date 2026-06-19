//
//  DateExtensions.swift
//  School Club
//
//  Created on 20.05.2026
//

import Foundation

extension Date {
    func relativeRu() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
