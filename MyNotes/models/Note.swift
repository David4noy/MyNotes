//
//  Untitled.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import UIKit

struct Note: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var todoList: [Todo]
    var content: String
    var isTodo: Bool
    var hasContent: Bool
    let creationDate: Date
    var backgroundColor: NoteColor
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Todo: Hashable {
    var item: String
    var isComplete: Bool
}

