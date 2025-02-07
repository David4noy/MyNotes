//
//  Untitled.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import UIKit

struct Note: Identifiable {
    let id = UUID()
    let title: String
    let todoList: [Todo]
    let content: String
    let isTodo: Bool
    let hasContent: Bool
    let creationDate: Date
    let backgroundColor: NoteColor
}

struct Todo {
    let item: String
    let isComplete: Bool
}

