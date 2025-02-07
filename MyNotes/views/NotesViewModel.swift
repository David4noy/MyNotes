//
//  NotesViewModel.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import Foundation

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []

    init() {
        loadMockData()
    }

    private func loadMockData() {
        notes = [
            Note(
                title: "A very long title for testing lines and see what will happen and how the cell is dealing with it.",
                todoList: [Todo(item: "A very long item for testing lines", isComplete: false), Todo(item: "bla bla bla", isComplete: true)],
                content: "A very long title for testing lines A very long title for testing lines A very long title for testing lines A very long title for testing lines\nA very long title for testing lines\nA very long title for testing lines",
                isTodo: true,
                hasContent: true,
                creationDate: Date(),
                backgroundColor: .yellow
            ),
            Note(
                title: "Shopping List",
                todoList: [Todo(item: "Milk", isComplete: false), Todo(item: "Eggs", isComplete: true)],
                content: "",
                isTodo: true,
                hasContent: false,
                creationDate: Date(),
                backgroundColor: .yellow
            ),
            Note(
                title: "Meeting Notes",
                todoList: [],
                content: "Discuss project timeline and next steps.",
                isTodo: false,
                hasContent: true,
                creationDate: Date(),
                backgroundColor: .blue
            ),
            Note(
                title: "Workout Plan",
                todoList: [Todo(item: "Run 5km", isComplete: false), Todo(item: "Push-ups", isComplete: true)],
                content: "",
                isTodo: true,
                hasContent: false,
                creationDate: Date(),
                backgroundColor: .green
            ),
            Note(
                title: "Ideas for App",
                todoList: [],
                content: "1. Dark mode support\n2. Cloud sync\n3. Custom themes",
                isTodo: false,
                hasContent: true,
                creationDate: Date(),
                backgroundColor: .red
            ),
            Note(
                title: "Grocery List",
                todoList: [Todo(item: "Apples", isComplete: true), Todo(item: "Bananas", isComplete: false)],
                content: "",
                isTodo: true,
                hasContent: false,
                creationDate: Date(),
                backgroundColor: .pink
            ),
            Note(
                title: "Holiday Plans",
                todoList: [],
                content: "Visit the mountains, book a hotel, pack warm clothes.",
                isTodo: false,
                hasContent: true,
                creationDate: Date(),
                backgroundColor: .mint
            ),
            Note(
                title: "Reading List",
                todoList: [],
                content: "1. Atomic Habits\n2. The Pragmatic Programmer\n3. Clean Code",
                isTodo: false,
                hasContent: true,
                creationDate: Date(),
                backgroundColor: .gray
            ),
            Note(
                title: "Coding Tasks",
                todoList: [Todo(item: "Fix UI bug", isComplete: false), Todo(item: "Optimize database", isComplete: true)],
                content: "",
                isTodo: true,
                hasContent: false,
                creationDate: Date(),
                backgroundColor: .cyon
            ),
            Note(
                title: "Daily Journal",
                todoList: [],
                content: "Today was a productive day! Completed all tasks on time.",
                isTodo: false,
                hasContent: true,
                creationDate: Date(),
                backgroundColor: .mint
            ),
            Note(
                title: "Budget Planning",
                todoList: [],
                content: "Calculate monthly expenses and adjust savings.",
                isTodo: false,
                hasContent: true,
                creationDate: Date(),
                backgroundColor: .red
            )
        ]
    }
}
