//
//  SettingsView.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Binding var settings: AppSettings
    @State private var selectedMenuItem: MenuItem?
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    
    @Environment(\.modelContext) private var context
    @Query private var notes: [Note]
    
    @State private var showImportSuccess = false
    @State private var showDeleteConfirmation = false
    @State private var showFinalDeleteConfirmation = false
    @State private var showImportPicker = false
    @State private var importMessage = ""
    
    @State private var showExportSuccess = false
    @State private var exportMessage = ""
    @State private var isPreparingExport = false
    @State private var backupExportURL: URL?
    @State private var showPreparingShare = false
    
    var body: some View {
        VStack {
            Form {
                sortSection()
                themeSection()
                backupSection()
                menuSection()
            }

            Spacer()
            versionFooter()
        }
        .navigationTitle("Menu")
        .navigationDestination(item: $selectedMenuItem) { item in
            switch item {
            case .about:
                AboutView()
            case .terms:
                TermsOfUseView()
            case .iCloudSync:
                ICloudSyncView()
            }
        }
        .onChange(of: settings) { _, newValue in
            newValue.save()
        }
        .sheet(isPresented: $showExportSuccess) {
            VStack(spacing: 24) {

                Text("Export Result")
                    .font(.title3.bold())
                    .padding(.top, 20)

                Text(exportMessage)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                if let url = backupExportURL {
                    ShareLink(item: url) {
                        Text("Share to External Storage")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    }
                    .padding(.horizontal, 24)
                }

                Button {
                    backupExportURL = nil
                    showExportSuccess = false
                } label: {
                    Text("OK")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("Import Result", isPresented: $showImportSuccess) {
            Button("OK") {}
        } message: {
            Text(importMessage)
        }
        .confirmationDialog(
            "Delete All Notes",
            isPresented: $showDeleteConfirmation
        ) {
            Button("Delete All Notes", role: .destructive) {
                showFinalDeleteConfirmation = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete ALL your notes. Are you sure?")
        }
        .confirmationDialog(
            "FINAL WARNING",
            isPresented: $showFinalDeleteConfirmation
        ) {
            Button("YES, DELETE EVERYTHING", role: .destructive) {
                deleteAllNotes()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. ALL \(notes.count) notes will be permanently deleted!")
        }
        .fileImporter(
            isPresented: $showImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    importNotesFromJSON(url: url)
                }
            case .failure(let error):
                importMessage = "File selection failed: \(error.localizedDescription)"
                showImportSuccess = true
            }
        }
    }

    private func sortSection() -> some View {
        Section(header: Text("Sort Notes By")) {
            Picker("Sort By", selection: $settings.sortBy) {
                ForEach(SortOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private func themeSection() -> some View {
        Section(header: Text("Appearance")) {
            Picker("Theme", selection: $settings.theme) {
                ForEach(ThemeMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    private func menuSection() -> some View {
        Section {
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack {
                    Text("App Language")
                    Spacer()
                    Text("Current Language text")
                        .foregroundColor(.gray)
                    Image(systemName: isAppInHebrew ? "chevron.left" : "chevron.right")
                        .foregroundColor(.gray)
                }
            }

            ForEach(MenuItem.allCases) { item in
                Button(action: {
                    selectedMenuItem = item
                }) {
                    Text(item.title)
                }
            }
        }
    }

    private func backupSection() -> some View {
        Section(header: Text("Backup & Data Management")) {
            // Export button - saves directly to internal Documents
            Button(action: {
                exportAllNotesToDocuments()
            }) {
                HStack {
                    Label(isPreparingExport ? "Exporting..." : "Export All Notes", systemImage: "square.and.arrow.up")
                    Spacer()
                }
                .foregroundStyle(isPreparingExport ? .gray : .primary)
            }
            .disabled(isPreparingExport)
            
            // Import button
            Button(action: {
                showImportPicker = true
            }) {
                HStack {
                    Label("Import Notes from Files", systemImage: "square.and.arrow.down")
                    Spacer()
                }
            }
            
            // Delete button
            Button(action: {
                showDeleteConfirmation = true
            }) {
                HStack {
                    Label("Delete All Notes", systemImage: "trash")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
        }
    }
    
    // Export all notes directly to Documents directory
    private func exportAllNotesToDocuments() {
        isPreparingExport = true
        
        Task {
            do {
                let notesData = try exportNotesToJSON(notes: notes)
                let fileName = "MyNotes_Backup_\(DateFormatter.backupFormatter.string(from: Date())).json"
                
                print("DEBUG: Creating backup file with name: \(fileName)")
                print("DEBUG: Number of notes to export: \(notes.count)")
                
                // Get Documents directory - this will appear in Files app
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                // Create MyNotes subfolder for organization
                let myNotesFolder = documentsURL.appendingPathComponent("Backups", isDirectory: true)
                try FileManager.default.createDirectory(at: myNotesFolder, withIntermediateDirectories: true, attributes: nil)
                
                // Save backup file
                let backupURL = myNotesFolder.appendingPathComponent(fileName)
                try notesData.write(to: backupURL)
                print("DEBUG: Backup saved to: \(backupURL.path)")
                
                // Create temporary file for sharing
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                try notesData.write(to: tempURL)
                print("DEBUG: Temp file created at: \(tempURL.path)")
                
                await MainActor.run {
                    if !isAppInHebrew {
                        exportMessage = "Successfully exported \(notes.count) notes!\n\nLocation: Files → On My iPhone/iPad → MyNotes → Backups\n\n⚠️ Note: This backup is stored inside the app and will be deleted if you uninstall the app.\n\nFor permanent backup, use the share option below."
                    } else {
                        exportMessage = "הייצוא הושלם בהצלחה! \(notes.count) פתקים יוצאו.\n\nמיקום: קבצים על ה‑iPhone/iPad שלי\n→ MyNotes → Backups\n\n⚠️ שימו לב: הגיבוי הזה נשמר בתוך האפליקציה ויימחק אם האפליקציה תוסר.\n\nלגיבוי קבוע, נא להשתמש באפשרות השיתוף למטה."
                    }

                    backupExportURL = tempURL
                    isPreparingExport = false
                    showExportSuccess = true
                }
                
            } catch {
                await MainActor.run {
                    exportMessage = "Export failed: \(error.localizedDescription)"
                    showExportSuccess = true
                    isPreparingExport = false
                }
            }
        }
    }
    
    // Convert notes to JSON format
    private func exportNotesToJSON(notes: [Note]) throws -> Data {
        let exportData = NotesExportData(
            exportDate: Date(),
            notesCount: notes.count,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
            notes: notes
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        return try encoder.encode(exportData)
    }
    
    // Import notes from JSON file
    private func importNotesFromJSON(url: URL) {
        // Start accessing security-scoped resource for external files
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        
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
                
                context.insert(newNote)
            }
            
            try context.save() // This will also sync to iCloud!
            
            importMessage = "Successfully imported \(importData.notes.count) notes!"
            showImportSuccess = true
            
        } catch {
            importMessage = "Import failed: \(error.localizedDescription)"
            showImportSuccess = true
        }
    }
    
    // Delete all notes function
    private func deleteAllNotes() {
        for note in notes {
            context.delete(note)
        }
        
        do {
            try context.save()
            print("All notes deleted successfully")
        } catch {
            print("Failed to delete notes: \(error)")
        }
    }
    
    private func versionFooter() -> some View {
        Text("Version: " + appVersion)
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 10)
    }
}

// Data structure for backup export
struct NotesExportData: Codable {
    let exportDate: Date
    let notesCount: Int
    let appVersion: String
    let notes: [Note]
}
