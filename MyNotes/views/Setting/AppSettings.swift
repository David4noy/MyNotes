//
//  AppSettings.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import Foundation
import SwiftUI

var isAppInHebrew: Bool {
    Locale.current.language.languageCode?.identifier == "he"
}

enum SortOption: CaseIterable, Identifiable, Codable {
    case date
    case color
    case alphabetically

    var id: String { title }

    var title: String {
        switch self {
        case .date:
            return String(localized: "Date")
        case .color:
            return String(localized: "Color")
        case .alphabetically:
            return String(localized: "A-Z")
        }
    }
}

enum ThemeMode: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return String(localized: "System Default")
        case .light: return String(localized: "Light")
        case .dark: return String(localized: "Dark")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct AppSettings: Codable, Equatable {
    var sortBy: SortOption = .date
    var addLocationToNotes: Bool = false
    var iCloudAutoSync: Bool = false
    var theme: ThemeMode = .system
}

extension AppSettings {
    static  let userDefaultsKey = "AppSettings"

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
        }
    }

    static func load() -> AppSettings {
        if let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
           let settings = try? JSONDecoder().decode(AppSettings.self, from: data) {
            return settings
        }
        return AppSettings()
    }
}
