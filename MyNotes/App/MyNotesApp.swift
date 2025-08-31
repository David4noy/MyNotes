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
        .modelContainer(cloudContainer)
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
    
    private var cloudContainer: ModelContainer {
        let schema = Schema([Note.self])
        let cloudID = "iCloud.com.davidnoy.mynotes"
        
        let cloudConfig = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private(cloudID)
        )
        
        // 1) Try CloudKit
        do {
            return try ModelContainer(for: schema, configurations: [cloudConfig])
        } catch {
#if DEBUG
            print("CloudKit ModelContainer failed: \(error)")
            print("Falling back to local persistent store.")
#endif
        }
        
        // 2) Fallback: local persistent store (on-device)
        do {
            return try ModelContainer(for: schema) // default local config
        } catch {
#if DEBUG
            print("Local persistent ModelContainer failed: \(error)")
            print("Falling back to in-memory store.")
#endif
        }
        
        // 3) Last resort: in-memory (so the app still runs)
        do {
            let memConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [memConfig])
        } catch {
            // If even in-memory fails, crash with a clear message (no force unwrap).
            preconditionFailure("Failed to create any ModelContainer: \(error)")
        }
    }
}
