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
    @State private var importedNote: Note? = nil
    @State private var settings = AppSettings.load()
    @StateObject private var iCloudManager = GlobalICloudManager()
    @State private var showToast = false
    
    var body: some Scene {
        WindowGroup {
            NotesListView(importedNote: importedNote, settings: $settings)
                .preferredColorScheme(settings.theme.colorScheme)
                .environmentObject(iCloudManager)
                .onOpenURL { url in
                    importNote(from: url)
                }
                .onAppear {
                    Task {
                        await iCloudManager.checkAndUpdateICloudStatus()
                        if !iCloudManager.isICloudAvailable {
                            showToastMessage()
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task {
                        await iCloudManager.checkAndUpdateICloudStatus()
                        if !iCloudManager.isICloudAvailable {
                            showToastMessage()
                        }
                    }
                }
                .toast(isShowing: $showToast) {
                    HStack {
                        Image(systemName: "xmark.icloud")
                        VStack(alignment: .leading) {
                            Text("iCloud Sync Disabled")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Notes will be saved locally only")
                                .font(.caption)
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(20)
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
        
        print("🔄 Setting up unified container with local + CloudKit support")
        
        // Create configurations for both local and cloud storage
        let localConfig = ModelConfiguration(
            schema: schema,
            url: URL.documentsDirectory.appending(path: "MyNotesLocal.store"),
            cloudKitDatabase: .none
        )
        
        let cloudConfig = ModelConfiguration(
            schema: schema,
            url: URL.documentsDirectory.appending(path: "MyNotesCloud.store"),
            cloudKitDatabase: .private(cloudID)
        )
        
        // Try to create container with both configurations
        do {
            // First, try with CloudKit + Local
            let container = try ModelContainer(for: schema, configurations: [localConfig, cloudConfig])
            print("✅ SUCCESS: Unified container created with CloudKit support!")
            return container
        } catch {
            print("⚠️ CloudKit failed, using local-only container")
            print("Error: \(error)")
            
            // Fallback: Local only
            do {
                let container = try ModelContainer(for: schema, configurations: [localConfig])
                print("✅ Local-only container created")
                return container
            } catch {
                print("❌ Local container failed: \(error)")
                // Last resort: in-memory only
                let memConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try! ModelContainer(for: schema, configurations: [memConfig])
            }
        }
    }
    
    private func showToastMessage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showToast = false
            }
        }
    }
}

