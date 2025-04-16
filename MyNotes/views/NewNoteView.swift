//
//  NewNoteView.swift
//  MyNotes
//
//  Created by David Noy on 16/04/2025.
//

import SwiftUI

struct NewNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var selectedColor: NoteColor = .yellow
    @State private var isTodo: Bool = false
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
                    saveButton
                }
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
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
                        .fill(color.cellColor)
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
        }
    }

    // MARK: - Toolbar Buttons

    private var saveButton: some View {
        Button("Save") {
            let newNote = Note(
                title: title.isEmpty ? "Untitled" : title,
                type: isTodo ? .todo : .textType,
                color: selectedColor
            )
            onSave(newNote)
            dismiss()
        }
    }

    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
    }
}
