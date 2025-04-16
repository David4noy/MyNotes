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

    func addTodo() {
        note.todos.append(Todo(item: "", isComplete: false))
    }
}
