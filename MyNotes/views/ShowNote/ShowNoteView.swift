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
        HStack {
            TextField("Title", text: $viewModel.note.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding()
            Spacer()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(viewModel.note.type == .todo ? 5 : 20)
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
        }
    }

    private var todoItemsSection: some View {
        ForEach($viewModel.note.todos) { $todo in
            HStack {
                Image(systemName: todo.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isComplete ? .green : .gray)
                    .onTapGesture {
                        todo.isComplete.toggle()
                    }

                TextField("To-do", text: $todo.item)
                    .focused(
                        $focusedTodoIndex,
                        equals: viewModel.note.todos.firstIndex(where: { $0.id == todo.id })
                    )
                    .padding(.vertical, 8)
                    .foregroundColor(todo.isComplete ? .gray : .black)
                    .strikethrough(todo.isComplete, color: .gray)
                
                Spacer()

                Button("Open") {
                    getTodoItemAndShowPopup(todoId: todo.id)
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 8)
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
        MultilineTextView(text: $viewModel.note.content)
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
    }

    private func moveTodo(from source: IndexSet, to destination: Int) {
        viewModel.note.todos.move(fromOffsets: source, toOffset: destination)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
