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
    @FocusState private var isSearchFieldFocused: Bool
    
//    @StateObject private var viewModel = NotesListViewModel()
//    @State private var path = NavigationPath()
    @State private var showNewNoteSheet = false
    @State private var selectedNote: Note? = nil
    @State private var showDeleteConfirmation = false
    @State private var noteToDeleteIndex: Int?
    @State private var isSearching = false
    @State private var searchText = ""
    @State private var showMenuSheet = false
    @State private var selectedMenuItem: MenuItem? = nil
    @State var settings = AppSettings.load()

    
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
            return base.sorted {
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
            .sheet(isPresented: $showMenuSheet) {
                MenuSheet(selectedMenuItem: $selectedMenuItem, showMenuSheet: $showMenuSheet)
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
            .navigationDestination(item: $selectedMenuItem) { item in
                switch item {
                case .settings:
                    SettingsView(settings: $settings)
                case .about:
                    AboutView()
                case .terms:
                    TermsOfUseView()
                case .iCloudSync:
                    ICloudSyncView()
                }
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
                    showMenuSheet = true
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
        List {
            ForEach(filteredNotes) { note in
                Button {
                    selectedNote = note
                } label: {
                    noteRow(for: note)
                }
                .listRowSeparator(.hidden)
            }
            .onDelete { indexes in
                for index in indexes {
                    noteToDeleteIndex = index
                    showDeleteConfirmation = true
                }
            }
        }
        .listStyle(.plain)
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
    
    func deleteNote(at index: Int) {
        context.delete(notes[index])
        noteToDeleteIndex = nil
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

struct AboutView: View {
    var body: some View {
        Text("This app helps you manage notes.")
            .padding()
            .navigationTitle("About")
    }
}

struct TermsOfUseView: View {
    var body: some View {
        Text("Terms of Use coming soon.")
            .padding()
            .navigationTitle("Terms of Use")
    }
}
