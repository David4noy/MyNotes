//
//  ShowNoteViewModel.swift
//  MyNotes
//
//  Created by David Noy on 16/04/2025.
//

import Foundation

class ShowNoteViewModel: ObservableObject {
    @Published var note: Note

    init(note: Note) {
        self.note = note
    }

    func toggleTodoComplete(_ index: Int) {
        note.todos[index].isComplete.toggle()
    }
    
    func insertTodo() {
        note.todos.insert(TodoItem(item: "", isComplete: false), at: 0)
    }

    func addTodo() {
        note.todos.append(TodoItem(item: "", isComplete: false))
    }
}
