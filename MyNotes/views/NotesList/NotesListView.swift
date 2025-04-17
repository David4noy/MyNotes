//
//  NotesListView.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI
import SwiftData

struct NotesListView: View {
    
    @Environment(\.modelContext) private var context
    @Query var notes: [Note]
    
//    @StateObject private var viewModel = NotesListViewModel()
    @State private var path = NavigationPath()
    @State private var showNewNoteSheet = false
    @State private var selectedNote: Note? = nil
    @State private var showDeleteConfirmation = false
    @State private var noteToDeleteIndex: Int?

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 10) {
                topSection
                notesList()
            }
            .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }
            .padding(.horizontal)
            .navigationDestination(for: Note.self) { selectedNote in
                ShowNoteView(note: selectedNote)
            }
            
            .sheet(isPresented: $showNewNoteSheet) {
                NewNoteView { newNote in
                    addNote(newNote)
                    selectedNote = newNote
                    showNewNoteSheet = false
                }
            }
            .alert("Are you sure you want to delete this note?", isPresented: $showDeleteConfirmation, presenting: noteToDeleteIndex) { index in
                Button("Delete", role: .destructive) {
                    deleteNote(at: index)
                }
                Button("Cancel", role: .cancel) {}
            }
            .navigationDestination(item: $selectedNote) { note in
                ShowNoteView(note: note)
            }
        }
    }

    private var topSection: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 1)
            
            CustomNavBar(addNote: {
                showNewNoteSheet = true
            })
        }
    }
    
    private func notesList() -> some View {
        List {
            ForEach(notes) { note in
                NavigationLink(value: note) {
                    noteRow(for: note)
                }
                .listRowSeparator(.hidden)
            }
            .onDelete { indexes in
                for index in indexes {
                    noteToDeleteIndex = index
                    showDeleteConfirmation = true
//                    deleteNote(at: index)
                }
            }
        }
        .listStyle(.plain)
    }

    private func noteRow(for note: Note) -> some View {
        HStack {
            Text(note.title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(formatDate(note.creationDate))
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(note.color.cellColor)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    func addNote(_ note: Note) {
        context.insert(note)
    }
    
    func deleteNote(at index: Int) {
        context.delete(notes[index])
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}


//#Preview {
//    NotesListView()
//}
