//
//  MyNotesApp.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct MyNotesApp: App {
    @State private var importState: ImportState = .regular
    @State private var settings = AppSettings.load()
    @State private var container: ModelContainer?
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let container {
                    NotesListView(importState: $importState, settings: $settings)
                        .modelContainer(container)
                        .preferredColorScheme(settings.theme.colorScheme)
                        .onOpenURL { url in
                            importNotesFromJSON(from: url)
                        }
                } else {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Loading…")
                            .font(.headline)
                    }
                }
            }
            .task {
                self.container = await createContainerSafely()
            }
        }
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
    
    private func createContainerSafely() async -> ModelContainer {
        try? await Task.sleep(nanoseconds: 150_000_000) // 0.15 sec delay
        
        let schema = Schema([Note.self])
        let cloudID = "iCloud.com.davidnoy.mynotes"
        
        let cloudConfig = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .private(cloudID)
        )
        
        // Try CloudKit
        if let cloud = try? ModelContainer(for: schema, configurations: [cloudConfig]) {
            print("CloudKit container ready")
            return cloud
        }
        
        // Fallback: local
        if let local = try? ModelContainer(for: schema) {
            print("Using local store")
            return local
        }
        
        // Last resort: memory
        let mem = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [mem])
    }
}

