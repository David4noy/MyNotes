//
//  NotesListView.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI
import SwiftData

struct NotesListView: View {
    
    @State var importedNote: Note?
    
    @Environment(\.modelContext) private var context
    @Query var notes: [Note]
    @FocusState private var isSearchFieldFocused: Bool
    
//    @StateObject private var viewModel = NotesListViewModel()
//    @State private var path = NavigationPath()
    @State private var showNewNoteSheet = false
    @State private var selectedNote: Note? = nil
    @State private var showDeleteConfirmation = false
    @State private var noteToDelete: Note?
    @State private var isSearching = false
    @State private var searchText = ""
    @State var settings = AppSettings.load()
    @State private var showSettings = false
    
    private var filteredNotes: [Note] {
        let base = searchText.isEmpty
        ? notes
        : notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
        
        switch settings.sortBy {
        case .date:
            return base.sorted { $0.creationDate > $1.creationDate }
        case .color:
            let colorOrder: [NoteColor] = NoteColor.allCases
            let sortedByDate = base.sorted { $0.creationDate > $1.creationDate }
            return sortedByDate.sorted {
                guard let firstIndex = colorOrder.firstIndex(of: $0.color),
                      let secondIndex = colorOrder.firstIndex(of: $1.color) else {
                    return false
                }
                return firstIndex < secondIndex
            }
        case .alphabetically:
            return base.sorted { $0.title.lowercased() < $1.title.lowercased() }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                topSection
                notesList()
            }
            .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }
            .padding(.horizontal)
            
            
            .sheet(isPresented: $showNewNoteSheet) {
                NewNoteView { newNote in
                    addNote(newNote)
                    selectedNote = newNote
                    showNewNoteSheet = false
                }
            }
            
            .alert("Are you sure you want to delete this note?", isPresented: $showDeleteConfirmation, presenting: noteToDelete) { note in
                Button("Delete", role: .destructive) {
                    deleteNote(note)
                }
                Button("Cancel", role: .cancel) {}
            }
            
            .navigationDestination(item: $selectedNote) { note in
                ShowNoteView(note: note)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(settings: $settings)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
        }
        .task {
            if let note = importedNote {
                context.insert(note)
                importedNote = nil
                selectedNote = note
            }
        }
    }
    
    private var topSection: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 1)
            
            CustomNavBar(
                addNote: {showNewNoteSheet = true},
                toggleSearch: {
                    withAnimation {
                        isSearching.toggle()
                        if isSearching {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                isSearchFieldFocused = true
                            }
                        } else {
                            searchText = ""
                            isSearchFieldFocused = false
                        }
                    }
                },
                menuTapped: {
                    showSettings = true
                }
            )
            
            if isSearching {
                TextField("Search notes...", text: $searchText)
                    .font(.system(size: 22))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 12)
                    .focused($isSearchFieldFocused)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    private func notesList() -> some View {
        return List {
            ForEach(filteredNotes) { note in
                Button {
                    selectedNote = note
                } label: {
                    noteRow(for: note)
                }
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        noteToDelete = note
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .confirmationDialog(
            "Are you sure you want to delete this note?",
            isPresented: $showDeleteConfirmation,
            presenting: noteToDelete
        ) { note in
            Button("Delete", role: .destructive) {
                deleteNote(note)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func noteRow(for note: Note) -> some View {
        HStack {
            Text(note.title)
                .font(.system(size: 20))
                .fontWeight(.medium)
            
            Spacer()
            
            Text(formatDate(note.creationDate))
                .font(.system(size: 12))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(note.color.noteColor)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
    
    func addNote(_ note: Note) {
        context.insert(note)
    }
    
    func deleteNote(_ note: Note) {
        context.delete(note)
        noteToDelete = nil
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


//#Preview {
//    NotesListView()
//}

