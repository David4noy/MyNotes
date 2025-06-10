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
    @State var importedNote: Note?
    @Binding var settings: AppSettings
    
    @StateObject private var viewModel = NotesListViewModel()
    @Query var notes: [Note]
    
    @FocusState private var isSearchFieldFocused: Bool
    @State private var showNewNoteSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showSettings = false
    
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
                    viewModel.setSelectedNote(to: newNote)
                    showNewNoteSheet = false
                }
            }
            .navigationDestination(item: $viewModel.selectedNote) { note in
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
                viewModel.setSelectedNote(to: note)
            }
        }
    }
    
    private var topSection: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 1)
            
            CustomNavBar(
                addNote: {showNewNoteSheet = true},
                toggleSearch: {
                    viewModel.isSearching.toggle()
                    if viewModel.isSearching {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            isSearchFieldFocused = true
                        }
                    } else {
                        viewModel.cleanSearch()
                        isSearchFieldFocused = false
                    }                },
                menuTapped: {
                    showSettings = true
                }
            )
            
            if viewModel.isSearching {
                searchBar()
            }
        }
        .animation(.easeInOut(duration: 0.15), value: viewModel.isSearching)
    }
    
    private func searchBar() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search notes...", text: $viewModel.searchText)
                .focused($isSearchFieldFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.cleanSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 12)
        .transition(.scale.combined(with: .opacity))
    }
    
    private func notesList() -> some View {
        return List {
            ForEach(viewModel.getFilteredNotes(from: notes, settings: settings)) { note in
                Button {
                    viewModel.setSelectedNote(to: note)
                } label: {
                    noteRow(for: note)
                }
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        viewModel.noteToDelete = note
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
            presenting: viewModel.noteToDelete
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
        viewModel.noteToDelete = nil
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

