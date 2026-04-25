//
//  NotesListView.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI
import SwiftData
import Combine

struct NotesListView: View {
    
    @Environment(\.modelContext) private var context
    @Binding var importState: ImportState
    @State private var showImportAlert = false
    @State private var pendingImportedNote: [Note]?
    @State private var showImportFailedAlert = false
    @Binding var settings: AppSettings
    
    @StateObject private var viewModel = NotesListViewModel()
    @Query var notes: [Note]
    
    @FocusState private var isSearchFieldFocused: Bool
    @State private var showNewNoteSheet = false
    @State private var showDeleteConfirmation = false
    @State private var showSettings = false
    
    @StateObject private var iCloudManager = GlobalICloudManager()
    @State private var showToast = false
    
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
        .onReceive(Just(importState)) { state in
            switch state {
            case .didImport(let notes):
                showImportConfirmation(for: notes)

            case .didFail:
                presentImportFailedAlert()

            case .regular:
                break
            }
        }
        .task {
            let isAvailable = await iCloudManager.checkICloudStatus()
            if !isAvailable {
                showToastMessage()
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
        .alert("Import Notes",
               isPresented: $showImportAlert,
               presenting: pendingImportedNote) { notes in

            Button("Add", role: .none) {
                notes.forEach { context.insert($0) }
                try? context.save()
                importState = .regular
            }

            Button("Cancel", role: .cancel) {
                importState = .regular
            }

        } message: { _ in
            Text("Would you like to add the imported notes?")
        }
        .alert("Import Failed",
               isPresented: $showImportFailedAlert) {
            Button("OK", role: .cancel) {
                importState = .regular
            }
        } message: {
            Text("Unable to load the imported notes.")
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
    
    private func showImportConfirmation(for notes: [Note]) {
        pendingImportedNote = notes
        showImportAlert = true
    }
    
    private func presentImportFailedAlert() {
        showImportFailedAlert = true
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
        try? context.save()
    }
    
    func deleteNote(_ note: Note) {
        context.delete(note)
        try? context.save()
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

