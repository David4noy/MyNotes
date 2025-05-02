//
//  ShowNoteView.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI

struct ShowNoteView: View {
    @StateObject private var viewModel: ShowNoteViewModel
    @FocusState private var focusedTodoIndex: Int?
    @Environment(\.editMode) private var editMode
    @State private var showPopup = false
    @State private var todoIndex: Int?
    @State private var todoItem = ""
    @State private var showColorPicker = false

    init(note: Note) {
        _viewModel = StateObject(wrappedValue: ShowNoteViewModel(note: note))
    }

    var body: some View {
        VStack(alignment: .leading) {
            titleSection
            contentSection
            Spacer()
        }
        .padding()
        .background(viewModel.note.color.cellColor.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
        
        .overlay(popupOverlay)
    }

    private var titleSection: some View {
        VStack(spacing: 0) {
            HStack {
                TextField(
                    String(localized: "Title"),
                    text: $viewModel.note.title,
                    onEditingChanged: { isEditing in
                        if !isEditing {
                            viewModel.onSaveNote()
                        }
                    }
                )
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding()

                Button {
                    withAnimation {
                        showColorPicker.toggle()
                    }
                } label: {
                    Image(systemName: "paintpalette")
                        .padding()
                }
            }
            .background(.ultraThinMaterial)
            .cornerRadius(viewModel.note.type == .todo ? 5 : 20)

            if showColorPicker {
                colorPicker
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(NoteColor.allCases, id: \.self) { color in
                    Circle()
                        .fill(color.cellColor)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle().stroke(Color.black, lineWidth: viewModel.note.color == color ? 2 : 0)
                        )
                        .onTapGesture {
                            viewModel.note.color = color
                        }
                }
            }
            .padding(.vertical)
        }
    }



    private var contentSection: some View {
        Group {
            if viewModel.note.type == .todo {
                todoList
            } else if viewModel.note.type == .textType {
                textContent
            }
        }
    }
    
    private var popupOverlay: some View {
        Group {
            if showPopup {
                GeometryReader { geometry in
                    let size = min(geometry.size.width * 0.8, 400)

                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showPopup = false
                            }

                        if let todoIndex {
                            TextEditorPopup(
                                isPresented: $showPopup,
                                internalText: $todoItem,
                                note: $viewModel.note,
                                index: todoIndex
                            )
                            .frame(width: size, height: size)
                            .transition(.opacity)
                            .zIndex(1)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .animation(.easeInOut, value: showPopup)
    }


    private var todoList: some View {
        List {
            addButtonTop

            todoItemsSection

            addButtonBottom
        }
        .listStyle(.plain)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !showPopup {
                    EditButton()
                }
            }
        }
    }

    // MARK: - Components

    private var addButtonTop: some View {
        Button(action: {
            viewModel.insertTodo()
            focusedTodoIndex = 0
        }) {
            todoButtonLabel
        }
        .listRowBackground(Color.white.opacity(0.6))
    }

    private var addButtonBottom: some View {
        Button(action: {
            viewModel.addTodo()
            focusedTodoIndex = viewModel.note.todos.count - 1
        }) {
            todoButtonLabel
        }
        .listRowBackground(Color.white.opacity(0.6))
    }

    private var todoButtonLabel: some View {
        HStack {
            Image(systemName: "plus.circle")
            Text("Add Item")
                .font(.system(size: 24))
        }
    }

    private var todoItemsSection: some View {
        ForEach($viewModel.note.todos) { $todo in
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: todo.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.isComplete ? .green : .gray)
                        .onTapGesture {
                            todo.isComplete.toggle()
                        }

                    TextField("Write to-do", text: $todo.item, onEditingChanged: { isEditing in
                        if !isEditing {
                            viewModel.onSaveNote()
                        }
                    })
                    .font(.system(size: 24))
                    .focused(
                        $focusedTodoIndex,
                        equals: viewModel.note.todos.firstIndex(where: { $0.id == todo.id })
                    )
                    .padding(.vertical, 8)
                    .foregroundColor(todo.isComplete ? .gray : viewModel.note.color.textColor)
                    .strikethrough(todo.isComplete, color: .gray)

                    Spacer()

                    Button("Open") {
                        getTodoItemAndShowPopup(todoId: todo.id)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 8)

                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 0.5)
                    .padding(.top, 24)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.white.opacity(0.4))
        }
        .onDelete(perform: deleteTodo)
        .onMove(perform: moveTodo)
    }

    
    private func getTodoItemAndShowPopup(todoId: UUID) {
        if let index = viewModel.note.todos.firstIndex(where: { $0.id == todoId }) {
            todoIndex = index
            todoItem = viewModel.note.todos[index].item
            showPopup = true
        }
    }
    
    private var textContent: some View {
        MultilineTextView(note: $viewModel.note, textColor: viewModel.note.color.textColor)
            .frame(minHeight: 200)
//        TextEditor(text: $viewModel.note.content)
//            .padding(16) // Inner padding of text
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color(.systemBackground))
//            )
//            .foregroundColor(.primary)
//            .padding() // Outer padding
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    Spacer()
//                    Button("Done") {
//                        hideKeyboard()
//                    }
//                }
//            }
    }
    
    private func deleteTodo(at offsets: IndexSet) {
        viewModel.note.todos.remove(atOffsets: offsets)
        viewModel.onSaveNote()
    }

    private func moveTodo(from source: IndexSet, to destination: Int) {
        viewModel.note.todos.move(fromOffsets: source, toOffset: destination)
        viewModel.onSaveNote()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
