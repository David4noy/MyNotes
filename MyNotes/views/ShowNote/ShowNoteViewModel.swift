//
//  ShowNoteViewModel.swift
//  MyNotes
//
//  Created by David Noy on 16/04/2025.
//

import Foundation
import CoreLocation
import UIKit

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
}

//@Observable
class ShowNoteViewModel: ObservableObject {
    @Published var note: Note
    @Published var address: String?
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
            exportLabelText = prepareToShareState.title
        }
    }

    init(note: Note) {
        self.note = note
    }
    
    func getInitialNoteImage() -> UIImage? {
        return note.getImage()
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
                let noteToShare = note
                noteToShare.id = UUID().uuidString
                noteToShare.creationDate = Date()

                let noteData = try JSONEncoder().encode(noteToShare)

                // Optional, but can be removed if large
                if let jsonString = String(data: noteData, encoding: .utf8) {
                    print("Note JSON to share:\n\(jsonString)")
                }

                let encryptedData = try CryptoHelper.encrypt(data: noteData)

                let filename = noteToShare.title.isEmpty ? "Note" : noteToShare.title
                let safeFilename = filename.replacingOccurrences(of: "/", with: "_")

                let sharedFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("SharedNotes", isDirectory: true)

                try FileManager.default.createDirectory(at: sharedFolder, withIntermediateDirectories: true)

                let fileURL = sharedFolder.appendingPathComponent("\(safeFilename).mynote")
                try encryptedData.write(to: fileURL)

                await MainActor.run {
                    noteShareURL = fileURL
                    prepareToShareState = .notPrepare
                }
            } catch {
                print("error - failed to encrypt or write file: \(error.localizedDescription)")
                await MainActor.run {
                    noteShareURL = nil
                    prepareToShareState = .error
                }
            }
        }
    }
}
