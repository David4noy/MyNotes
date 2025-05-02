//
//  MyNotesApp.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI
import SwiftData

@main
struct MyNotesApp: App {
    var body: some Scene {
        WindowGroup {
            NotesListView()
        }
        .modelContainer(for: Note.self)
    }
}
