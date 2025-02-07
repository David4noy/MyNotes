//
//  NoteColor.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import UIKit
import SwiftUICore

enum NoteColor: CaseIterable {
    case blue
    case green
    case red
    case yellow
    case cyon
    case gray
    case white
    case lightBlue
    case pink

    var uiColor: UIColor {
        switch self {
        case .blue: return UIColor.systemBlue
        case .green: return UIColor.systemGreen
        case .red: return UIColor.systemRed
        case .yellow: return UIColor.systemYellow
        case .cyon: return UIColor.systemTeal
        case .gray: return UIColor.systemGray
        case .white: return UIColor.white 
        case .lightBlue: return UIColor.lightGray
        case .pink: return UIColor.systemPink
        }
    }
    
    var cellColor: Color {
        Color(uiColor).opacity(0.8) // Converts UIColor to SwiftUI Color
    }
}
