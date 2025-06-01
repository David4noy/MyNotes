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
    @State private var showMenuSheet = false
    @State private var selectedMenuItem: MenuItem? = nil
    @State var settings = AppSettings.load()
    
    @State var didLoad = false

    
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
            
            .alert("Are you sure you want to delete this note?", isPresented: $showDeleteConfirmation, presenting: noteToDelete) { note in
                Button("Delete", role: .destructive) {
                    deleteNote(note)
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
        return List {
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
                    noteToDelete = filteredNotes[index]
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
    
    func getBackupToDo() -> Note? {
        let json = """
        {
          "todos": [
            {
              "item": "קפיצה לסוף או תחילת הטבלה בהוספת פריט\\n- זה נכנס לראשון הקודם",
              "isComplete": true,
              "id": "3DC8D208-F85F-44EF-8A9B-A9C6223327A6"
            },
            {
              "item": "ביטול צבע כחול או שינוי כפתורים",
              "isComplete": true,
              "id": "97FFDA10-EEBE-49D4-B03E-CD47623E882D"
            },
            {
              "item": "תיקון התא במצב עריכה של פריט ברשימת ביצוע",
              "isComplete": true,
              "id": "4A86DA28-E3F1-4FED-A340-3A634A77665F"
            },
            {
              "item": "לבדוק שגיאות",
              "isComplete": false,
              "id": "D87247AD-8A44-442B-A64A-A6A506E71AD0"
            },
            {
              "item": "ייצוא של פתק מאובטח עם שיתוף",
              "isComplete": false,
              "id": "A9BBABD7-DD4F-40D0-89F0-5CA2578103C0"
            },
            {
              "item": "יצוא של pdf",
              "isComplete": false,
              "id": "173CDDE1-BB99-4535-8138-4C5734195926"
            },
            {
              "item": "נוטיפיקציות מתוזמנות לוקאליות",
              "isComplete": false,
              "id": "AF190297-3758-43DF-B37E-770D70EE4FF2"
            },
            {
              "item": "מסך הגדרות",
              "isComplete": false,
              "id": "7546B288-F576-440F-BAC6-F46ECF4FC0E9"
            },
            {
              "item": "לקיחת תמונה",
              "isComplete": true,
              "id": "19A107BE-A205-45BC-AEEA-F11EBEB938A5"
            },
            {
              "item": "Accessibility ",
              "isComplete": false,
              "id": "F95593DD-E87B-4135-9206-9BDDADF7250A"
            },
            {
              "item": "פוש נוטיפיקיישן עם חיוב עדכון גירסה",
              "isComplete": false,
              "id": "8CD967E8-15CF-4A75-8429-13BF445B2D2F"
            },
            {
              "item": "iCloud ",
              "isComplete": false,
              "id": "33CC4FEB-67DA-438D-AD92-2A0B0FBD25E1"
            },
            {
              "item": "Widget",
              "isComplete": false,
              "id": "56E3F0A3-A072-4D28-B6DE-C3A75DC74B04"
            },
            {
              "item": "תנאי שימוש",
              "isComplete": false,
              "id": "6BFAA6A0-0538-441C-8ACA-F9B4E00C3F68"
            },
            {
              "item": "כפתור תפריט עם:\\nשיתוף\\nייצוא\\nשינוי צבע\\nכתובת\\nצילום תמונה\\nעריכה",
              "isComplete": false,
              "id": "5614018A-3789-4C3D-BD17-D5E92EAAC484"
            }
          ],
          "color": {
            "orange": {}
          },
          "id": "2FF537E3-9014-44FA-AC99-BF7C515DA262",
          "title": "לאפליקציה - מינימום",
          "type": "todo",
          "content": "",
          "creationDate": 770466339.680477
        }
        """

        let data = Data(json.utf8)
        do {
            let note = try JSONDecoder().decode(Note.self, from: data)
            return note
        } catch {
            print("❌ Failed to decode Note: \(error.localizedDescription)")
            return nil
        }
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
