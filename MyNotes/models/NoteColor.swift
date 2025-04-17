//
//  NoteColor.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import UIKit
import SwiftUICore

enum NoteColor: CaseIterable, Codable {
    case yellow, orange, green, mint, teal, cyon, blue, indigo, purple, pink, red, brown, gray

    var uiColor: UIColor {
        switch self {
        case .blue: return UIColor.systemBlue
        case .green: return UIColor.systemGreen
        case .red: return UIColor.systemRed
        case .yellow: return UIColor.systemYellow
        case .cyon: return UIColor.systemCyan
        case .gray: return UIColor.systemGray
        case .pink: return UIColor.systemPink
        case .brown: return UIColor.systemBrown
        case .orange: return UIColor.systemOrange
        case .teal: return UIColor.systemTeal
        case .mint: return UIColor.systemMint
        case .purple: return UIColor.systemPurple
        case .indigo: return UIColor.systemIndigo
        }
    }

    var cellColor: Color {
        Color(uiColor)
    }
    
    var textBackgroundColor: Color {
        Color(uiColor).opacity(0.5)
    }
}
