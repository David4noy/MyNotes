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
                .onOpenURL { url in
                    importNote(from: url)
                }
                .onAppear {
                    Task {
                        let isAvailable = await iCloudManager.checkICloudStatus()
                        if !isAvailable {
                            showToastMessage()
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    Task {
                        let isAvailable = await iCloudManager.checkICloudStatus()
                        if !isAvailable {
                            showToastMessage()
                        }
                    }
                }
                .toast(isShowing: $showToast) {
                    HStack {
                        Image(systemName: "xmark.icloud")
                        Text("iCloud is not available")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
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

