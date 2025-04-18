//
//  AppSettings.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable, Codable {
    case date = "Date"
    case color = "Color"
    case alphabetically = "A-Z"
    var id: String { rawValue }
}

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case `default` = "Default"
    case english = "EN"
    case hebrew = "HE"
    var id: String { rawValue }
}

struct AppSettings: Codable, Equatable {
    var sortBy: SortOption = .date
    var language: AppLanguage = .default
    var addLocationToNotes: Bool = false
    var iCloudAutoSync: Bool = false
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
