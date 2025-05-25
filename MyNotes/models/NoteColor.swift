//
//  NoteColor.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUICore

enum NoteColor: CaseIterable, Codable {
    case yellow, orange, green, mint, teal, cyon, indigo, purple, pink, red, brown, gray
    
    var noteColor: Color {
        switch self {
        case .green: return .green
        case .red: return .red
        case .yellow: return .yellow
        case .cyon: return .cyan
        case .gray: return .gray
        case .pink: return .pink
        case .brown: return .brown
        case .orange: return .orange
        case .teal: return .teal
        case .mint: return .mint
        case .purple: return .purple
        case .indigo: return .indigo
        }
    }
    
    var textBackgroundColor: Color {
        noteColor.opacity(0.5)
    }
    
    var textColor: Color {
        switch self {
        case .yellow, .mint:
            return .black.opacity(0.87) // fallback, but low contrast
        case .indigo, .purple, .brown:
            return .black
        default:
            return .black
        }
    }
}
