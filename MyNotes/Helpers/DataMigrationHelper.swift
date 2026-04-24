//
//  DataMigrationHelper.swift
//  MyNotes
//
//  Created by David Noy on 24/04/2026.
//

import Foundation
import SwiftData

@MainActor
final class DataMigrationHelper {
    
    /// Checks if there are multiple store files and helps merge them
    static func checkAndMigrateData(modelContext: ModelContext) async {
        let documentsPath = URL.documentsDirectory
        
        // Check for old store files that might exist
        let potentialStores = [
            documentsPath.appending(path: "default.store"),
            documentsPath.appending(path: "MyNotes.store"),
            documentsPath.appending(path: "Model.sqlite")
        ]
        
        var foundStores: [URL] = []
        
        for storeURL in potentialStores {
            if FileManager.default.fileExists(atPath: storeURL.path()) {
                foundStores.append(storeURL)
                print("📁 Found potential old data store: \(storeURL.lastPathComponent)")
            }
        }
        
        if !foundStores.isEmpty {
            print("🔄 Found \(foundStores.count) old data store(s). Data migration may be needed.")
            print("📍 Current notes count: \(await getCurrentNotesCount(modelContext: modelContext))")
        }
    }
    
    private static func getCurrentNotesCount(modelContext: ModelContext) async -> Int {
        let descriptor = FetchDescriptor<Note>()
        do {
            let notes = try modelContext.fetch(descriptor)
            return notes.count
        } catch {
            print("❌ Failed to fetch notes count: \(error)")
            return 0
        }
    }
    
    /// Logs information about the current storage configuration
    static func logStorageInfo() {
        let documentsPath = URL.documentsDirectory
        print("📂 Documents directory: \(documentsPath.path())")
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            let storeFiles = contents.filter { $0.pathExtension == "store" || $0.lastPathComponent.contains("sqlite") }
            
            print("🗃️ Found \(storeFiles.count) potential database files:")
            for file in storeFiles {
                let attributes = try FileManager.default.attributesOfItem(atPath: file.path())
                let size = attributes[.size] as? Int64 ?? 0
                let modified = attributes[.modificationDate] as? Date ?? Date()
                
                print("  📄 \(file.lastPathComponent) - \(size) bytes - Modified: \(modified)")
            }
        } catch {
            print("❌ Failed to list directory contents: \(error)")
        }
    }
}