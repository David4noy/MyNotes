//
//  NotesListView.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI

struct NotesListView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var path = NavigationPath() // Keeps track of navigation

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 10) {
                Spacer().frame(height: 1)
                CustomNavBar()
                notesList()
            }
            .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }
            .padding(.horizontal)
            .navigationDestination(for: Note.self) { selectedNote in
                ShowNote(note: selectedNote)
            }
        }
    }
    
    private func notesList() -> some View {
        List(viewModel.notes) { note in
            NavigationLink(value: note) { // Push ShowNote when tapped
                HStack {
                    Text(note.title)
                        .font(.body)
                        .fontWeight(.medium)

                    Spacer()

                    Text(formatDate(note.creationDate))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(note.backgroundColor.cellColor)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    NotesListView()
}
