//
//  MenuItem.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import SwiftUI

enum MenuItem: String, CaseIterable, Identifiable {
    case settings = "Settings"
    case iCloudSync = "iCloud Sync"
    case terms = "Terms of Use"
    case about = "About"

    var id: String { self.rawValue }
}
