//
//  Untitled.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Note: Identifiable, Hashable {
    var id = UUID().uuidString
    var title: String
    var content: String
    var todos: [TodoItem]
    var type: NoteType
    var color: NoteColor
    var creationDate: Date
    var latitude: Double?
    var longitude: Double?
    
    init(
        title: String,
        type: NoteType,
        color: NoteColor,
        content: String = "",
        todos: [TodoItem] = [],
        creationDate: Date = Date(),
        latitude: Double?,
        longitude: Double?
    ) {
        self.title = title
        self.type = type
        self.color = color
        self.content = content
        self.todos = todos
        self.creationDate = creationDate
        self.latitude = latitude
        self.longitude = longitude
    }

    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TodoItem: Identifiable, Hashable, Codable {
    var id = UUID()
    var item: String
    var isComplete: Bool
}

enum NoteType: String, CaseIterable, Codable {
    case textType
    case todo
}
