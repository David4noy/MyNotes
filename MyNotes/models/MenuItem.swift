//
//  MenuItem.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import SwiftUI

enum MenuItem: CaseIterable, Identifiable {
    case iCloudSync
    case terms
    case about

    var id: String { title }

    var title: String {
        switch self {
        case .iCloudSync:
            return String(localized: "iCloud Sync")
        case .terms:
            return String(localized: "Terms of Use")
        case .about:
            return String(localized: "About")
        }
    }
}

