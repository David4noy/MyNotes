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
    @State private var importedNote: Note? = nil
    @State private var settings = AppSettings.load()

    var body: some Scene {
        WindowGroup {
            NotesListView(importedNote: importedNote, settings: $settings)
                .preferredColorScheme(settings.theme.colorScheme)
                .onOpenURL { url in
                    importNote(from: url)
                }
        }
        .modelContainer(for: Note.self)
    }

    private func importNote(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decrypted = try CryptoHelper.decrypt(data: data)
            let note = try JSONDecoder().decode(Note.self, from: decrypted)
            importedNote = note
        } catch {
            print("error - failed to import note")
        }
    }
}
