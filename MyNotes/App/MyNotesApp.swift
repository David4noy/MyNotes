//
//  MyNotesApp.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI
import SwiftData
import UIKit

enum ImportState {
    case regular
    case didImport([Note])
    case didFail
}

@main
struct MyNotesApp: App {
    @State private var importState: ImportState = .regular
    @State private var settings = AppSettings.load()
    
    var body: some Scene {
        WindowGroup {
            NotesListView(importState: $importState, settings: $settings)
                .preferredColorScheme(settings.theme.colorScheme)
                .onOpenURL { url in
                    importNotesFromJSON(from: url)
                }
        }
        .modelContainer(cloudContainer)
    }
    
    // Import notes from JSON file
    private func importNotesFromJSON(from url: URL) {
        // Start accessing security-scoped resource for external files
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        var newNotes: [Note] = []
        
        defer {
            // Always stop accessing when done
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let importData = try decoder.decode(NotesExportData.self, from: data)
            
            // Add imported notes to SwiftData
            for note in importData.notes {
                // Create new note with original data
                let newNote = Note(
                    title: note.title,
                    type: note.type,
                    color: note.color,
                    content: note.content,
                    todos: note.todos,
                    creationDate: note.creationDate, // Keep original creation date!
                    latitude: note.latitude,
                    longitude: note.longitude
                )
                
                // Save image if exists
                if let imageData = note.getImageData() {
                    newNote.setImageData(imageData)
                }
                
                // Keep original text direction
                newNote.isRightToLeft = note.isRightToLeft
                
                newNotes.append(newNote)
            }
            importState = .didImport(newNotes)
        } catch (let error) {
            print("Error importing notes: \(error.localizedDescription)")
            importState = .didFail
        }
    }
    
    private var cloudContainer: ModelContainer {
        let schema = Schema([Note.self])
        let cloudID = "iCloud.com.davidnoy.mynotes"
        
        print("🔄 Attempting to create CloudKit container with ID: \(cloudID)")
        
        let cloudConfig = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private(cloudID)
        )
        
        // 1) Try CloudKit
        do {
            let container = try ModelContainer(for: schema, configurations: [cloudConfig])
            print("✅ SUCCESS: CloudKit container created!")
            print("✅ Using CloudKit with container: \(cloudID)")
            return container
        } catch {
            print("❌ FAILED: CloudKit ModelContainer creation failed!")
            print("❌ Error: \(error)")
            print("❌ App will use LOCAL storage instead - NO SYNC!")
            
            // 2) Fallback: local persistent store (on-device)
            do {
                let localContainer = try ModelContainer(for: schema)
                print("⚠️ Using LOCAL storage - data will NOT sync!")
                return localContainer
            } catch {
                print("❌ Even local storage failed: \(error)")
                let memConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try! ModelContainer(for: schema, configurations: [memConfig])
            }
        }
    }
}

