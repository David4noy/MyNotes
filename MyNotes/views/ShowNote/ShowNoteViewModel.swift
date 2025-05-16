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
    
    func insertTodo() {
        note.todos.insert(TodoItem(item: "", isComplete: false), at: 0)
        onSaveNote()
    }

    func addTodo() {
        note.todos.append(TodoItem(item: "", isComplete: false))
        onSaveNote()
    }
    
    func onSaveNote() {
        note.creationDate = Date()
    }
}
