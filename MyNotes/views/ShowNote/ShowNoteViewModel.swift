//
//  ShowNoteViewModel.swift
//  MyNotes
//
//  Created by David Noy on 16/04/2025.
//

import Foundation
import CoreLocation

class ShowNoteViewModel: ObservableObject {
    @Published var note: Note
    @Published var address: String? = nil

    init(note: Note) {
        self.note = note
    }
    
    func loadAddressIfNeeded() async {
        guard
            let lat = note.latitude,
            let lon = note.longitude
        else {
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let result = await LocationManager.shared.getFullAddress(from: coordinate)
        await MainActor.run {
            self.address = result
        }
    }

    func toggleTodoComplete(_ index: Int) {
        note.todos[index].isComplete.toggle()
        onSaveNote()
    }
    
    func insertTodoAndGetID() -> UUID {
        let newTodo = TodoItem(item: "", isComplete: false)
        note.todos.insert(newTodo, at: 0)
        onSaveNote()
        return newTodo.id
    }

    func addTodoAndGetID() -> UUID {
        let newTodo = TodoItem(item: "", isComplete: false)
        note.todos.append(newTodo)
        onSaveNote()
        return newTodo.id
    }
    
    func indexOfTodo(withId id: UUID) -> Int? {
        note.todos.firstIndex { $0.id == id }
    }
    
    func onSaveNote() {
        note.creationDate = Date()
    }
}
