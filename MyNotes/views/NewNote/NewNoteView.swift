//
//  NewNoteView.swift
//  MyNotes
//
//  Created by David Noy on 16/04/2025.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var selectedColor: NoteColor = .yellow
    @State private var isTodo: Bool = false
    @State private var showLocationAlert = false
    @State private var showImportAlert = false
    @State private var alertMessage = ""
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isMainSetting = false
    @State private var shouldAddLocation = false
    @State private var showingFileImporter = false
    
    var onSave: (Note) -> Void

    var body: some View {
        NavigationView {
            Form {
                titleSection
                colorSection
                typeSection
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Open Note") {
                        showingFileImporter = true
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    saveButton
                }
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
            }
        }
        .alert(isPresented: $showLocationAlert) {
            locationAlert
        }
        .alert("Import Failed", isPresented: $showImportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [UTType(exportedAs: "com.davidnoy.mynote")],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile = try result.get().first else { return }
                
                guard selectedFile.startAccessingSecurityScopedResource() else {
                    throw NSError(domain: "com.mynotes", code: 1, userInfo: [NSLocalizedDescriptionKey: "Permission denied"])
                }
                defer { selectedFile.stopAccessingSecurityScopedResource() }
                
                if let importedNote = importNote(from: selectedFile) {
                    let newNote = importedNote
                    newNote.id = UUID().uuidString
                    newNote.creationDate = Date()
                    
                    onSave(newNote)
                    dismiss()
                } else {
                    alertMessage = "Failed to import note: invalid file or decryption failed."
                }
                
            } catch {
                print("Failed to open note: \(error.localizedDescription)")
                alertMessage = "Failed to open note"
                isMainSetting = false
                showLocationAlert = true
            }
        }
    }

    // MARK: - Sections

    private var titleSection: some View {
        Section(header: Text("Title")) {
            TextField("Enter title", text: $title)
        }
    }

    private var colorSection: some View {
        Section(header: Text("Color")) {
            colorPicker
        }
    }

    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(NoteColor.allCases, id: \.self) { color in
                    Circle()
                        .fill(color.noteColor)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: selectedColor == color ? 2 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding(.vertical)
        }
    }

    private var typeSection: some View {
        Section(header: Text("Note Type")) {
            Toggle("Is To-Do List?", isOn: $isTodo)
            Toggle("Add Location to Notes", isOn: $shouldAddLocation)
                .onChange(of: shouldAddLocation) {
                    if shouldAddLocation {
                        setupLocationHandling()
                    }
                }
        }
    }

    // MARK: - Toolbar Buttons

    private var saveButton: some View {
        Button("Save") {
            Task {
                let location = shouldAddLocation ? await LocationManager.shared.getUserLocation() : nil
                let newNote = Note(
                    title: title.isEmpty ? "Untitled" : title,
                    type: isTodo ? .todo : .textType,
                    color: selectedColor,
                    latitude: location?.latitude,
                    longitude: location?.longitude
                )
                onSave(newNote)
                dismiss()
            }
        }
    }

    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
    
    private func setupLocationHandling() {
        LocationManager.shared.checkIfLocationServicesIsEnabled()
        
        LocationManager.shared.locationError
            .receive(on: RunLoop.main)
            .sink { error in
                switch error {
                case .locationServicesDenied:
                    alertMessage = NSLocalizedString(
                        "Location access is denied for this app.\nPlease go to Settings → My Notes → Location and allow access.",
                        comment: "Shown when location access is denied by the user"
                    )
                    isMainSetting = false
                    showLocationAlert = true
                case .locationServicesDisabled:
                    alertMessage = NSLocalizedString(
                        "Location Services are disabled on your device.\nTo enable, go to Settings → Privacy & Security → Location Services.",
                        comment: "Shown when location services are turned off system-wide"
                    )
                    isMainSetting = true
                    showLocationAlert = true
                case .locationServicesError:
                    alertMessage = NSLocalizedString("An unexpected error occurred while trying to access location.", comment: "Shown when location access fails unexpectedly")
                    showLocationAlert = true
                }
            }
            .store(in: &cancellables)
    }
    
    private var locationAlert: Alert {
        Alert(
            title: Text("Location Services"),
            message: Text(alertMessage),
            primaryButton: .default(Text("Settings"), action: {
                if isMainSetting {
                    openMainSettings()
                } else {
                    openAppSettings()
                }
            }),
            secondaryButton: .cancel(Text("Cancel"), action: {
                shouldAddLocation = false
            })
        )
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func openMainSettings() {
        guard let url = URL(string: "App-Prefs:") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            openAppSettings() // fallback
        }
    }
    
    private func importNote(from url: URL) -> Note? {
        do {
            let data = try Data(contentsOf: url)
            let decrypted = try CryptoHelper.decrypt(data: data)
            let note = try JSONDecoder().decode(Note.self, from: decrypted)
            return note
        } catch {
            print("error - failed to import note")
            return nil
        }
    }
}
