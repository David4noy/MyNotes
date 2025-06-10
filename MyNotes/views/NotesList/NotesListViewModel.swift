//
//  NotesListViewModel.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftData
import Combine

class NotesListViewModel: ObservableObject {
    
    @Published var searchText: String = ""
    @Published var isSearching = false
    @Published var noteToDelete: Note? = nil
    @Published var selectedNote: Note? = nil
    
    func getFilteredNotes(from notes: [Note], settings: AppSettings) -> [Note] {
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
    
    func setSelectedNote(to newNote: Note) {
        selectedNote = newNote
    }
    
    func cleanSearch() {
        searchText = ""
    }
}
