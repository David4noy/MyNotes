//
//  ShowNote.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI

struct ShowNote: View {
    @State private var note: Note
    @State private var isEditingContent = false
    
    init(note: Note) {
        _note = State(initialValue: note) // Use State to allow modifications
    }

    var body: some View {
        VStack(alignment: .leading) {
            headerView()

            if note.isTodo {
                todoListView()
            }

            if note.hasContent {
                contentView()
                .padding(.top, 10) 
            }

            Spacer()
        }
        .padding()
        .navigationTitle("") // No default title
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header View
    private func headerView() -> some View {
        HStack {
            Text(note.title)
                .font(.title)
                .fontWeight(.bold)

            Spacer()

            Button(action: {
                print("Settings tapped") // Placeholder for action
            }) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.title2)
            }
        }
    }

    // MARK: - To-Do List View
    private func todoListView() -> some View {
        List {
            ForEach(Array(note.todoList.indices), id: \.self) { index in
                HStack {
                    Image(systemName: note.todoList[index].isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(note.todoList[index].isComplete ? .green : .gray)
                        .onTapGesture {
                            note.todoList[index].isComplete.toggle() // Toggle completion
                        }

                    Text(note.todoList[index].item)
                        .strikethrough(note.todoList[index].isComplete, color: .gray)
                        .onTapGesture {
                            print("Edit tapped for: \(note.todoList[index].item)") // Future edit action
                        }

//                    Spacer()
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Content View
    private func contentView() -> some View {
        VStack(alignment: .leading) {
            if isEditingContent {
                TextEditor(text: $note.content)
                    .font(.body)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                    .onDisappear {
                        print("Updated content: \(note.content)") // Save changes action
                    }
            } else {
                Text(note.content)
                    .font(.body)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .onTapGesture {
                        isEditingContent.toggle()
                    }
            }
        }
    }
}
