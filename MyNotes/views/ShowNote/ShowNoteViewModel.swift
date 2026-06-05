//
//  ShowNoteViewModel.swift
//  MyNotes
//
//  Created by David Noy on 16/04/2025.
//

import Foundation
import CoreLocation
import UIKit
import SwiftUI

enum PrepareTheNoteState {
    case notPrepare
    case preparing
    case error
    
    var title: String {
        switch self {
        case .notPrepare:
            return String(localized: "Prepare The Note")
        case .preparing:
            return String(localized: "Preparing..")
        case .error:
            return String(localized: "Error: Failed to prepare the note.")
        }
    }
    
    var color: Color {
        switch self {
        case .notPrepare:
            return .blue
        case .preparing:
            return .black
        case .error:
            return .red
        }
    }
}

class ShowNoteViewModel: ObservableObject {
    @Published var note: Note
    @Published var address: String?
    @Published var editingTodoIndex: Int?
    @Published var selectedUIImage: UIImage?
    @Published var noteShareURL: URL?
    @Published var notePDFShareURL: URL?
    @Published var shareLabelText: String = PrepareTheNoteState.notPrepare.title
    @Published var exportLabelText: String = PrepareTheNoteState.notPrepare.title
    
    var prepareToShareState: PrepareTheNoteState = .notPrepare {
        didSet {
            shareLabelText = prepareToShareState.title
        }
    }
    
    var prepareToExportState: PrepareTheNoteState = .notPrepare {
        didSet {
            exportLabelText = prepareToExportState.title
        }
    }

    init(note: Note) {
        self.note = note
    }
    
    func isRelatedRightToLeft() -> Bool {
        return isAppInHebrew != note.isRightToLeft
    }
    
    func getInitialNoteImage() {
        if selectedUIImage == nil {
            selectedUIImage = note.getImage()
        }
    }
    
    func setNoteImage(oldImage: UIImage?, newImage: UIImage) {
        note.setImage(from: newImage)
        if oldImage != nil {
            onSaveNote()
        }
    }
    
    func deleteNoteImage() {
        note.deleteImage()
        onSaveNote()
    }
    
    func loadAddressIfNeeded() async {
        guard
            let lat = note.latitude,
            let lon = note.longitude
        else {
            return
        }

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let result = await LocationManager.shared.getFullAddress(from: coordinate)
        await MainActor.run {
            self.address = result
        }
    }
    
    func deleteLocation() {
        note.latitude = nil
        note.longitude = nil
        address = nil
        onSaveNote()
    }

    func toggleTodoComplete(_ index: Int) {
        note.todos[index].isComplete.toggle()
        onSaveNote()
    }
    
    func toggleTextDirection() {
        note.isRightToLeft.toggle()
        onSaveNote()
    }
    
    func insertTodoAndGetID() -> UUID {
        let newTodo = TodoItem(item: "", isComplete: false)
        note.todos.insert(newTodo, at: 0)
        onSaveNote()
        return newTodo.id
    }

    func addTodoAndGetID() -> UUID {
        let newTodo = TodoItem(item: "", isComplete: false)
        note.todos.append(newTodo)
        onSaveNote()
        return newTodo.id
    }
    
    func indexOfTodo(withId id: UUID) -> Int? {
        note.todos.firstIndex { $0.id == id }
    }
    
    func sortTodosByCompletion() {
        note.todos.sort { !$0.isComplete && $1.isComplete }
        onSaveNote()
    }
    
    func onSaveNote() {
        note.creationDate = Date()
    }
    
    func getNoteToPDFToShareTempURL() {
        Task {
            if let pdfURL = NoteExporter.export(note: note, locationName: address) {
                await MainActor.run {
                    notePDFShareURL = pdfURL
                    prepareToExportState = .notPrepare
                }
            } else {
                notePDFShareURL = nil
                prepareToExportState = .error
            }
        }
    }
    
    func getNoteToShareTempURL() {
        prepareToShareState = .preparing

        Task {
            do {
                // 1) Create export structure with ONE note
                let exportData = NotesExportData(
                    exportDate: Date(),
                    notesCount: 1,
                    appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0",
                    notes: [note]
                )

                // 2) Encode to JSON (same format as full backup)
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                encoder.outputFormatting = .prettyPrinted

                let jsonData = try encoder.encode(exportData)

                // Optional debug print
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Single note export JSON:\n\(jsonString)")
                }

                // 3) Prepare filename
                let filename = note.title.isEmpty ? "Note" : note.title
                let safeFilename = filename.replacingOccurrences(of: "/", with: "_")

                // 4) Create folder
                let sharedFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("SharedNotes", isDirectory: true)

                try FileManager.default.createDirectory(at: sharedFolder, withIntermediateDirectories: true)

                // 5) Save file
                let fileURL = sharedFolder.appendingPathComponent("\(safeFilename).mynotes")
                try jsonData.write(to: fileURL)

                // 6) Update UI
                await MainActor.run {
                    noteShareURL = fileURL
                    prepareToShareState = .notPrepare
                }

            } catch {
                print("error - failed to export note: \(error.localizedDescription)")
                await MainActor.run {
                    noteShareURL = nil
                    prepareToShareState = .error
                }
            }
        }
    }
}
