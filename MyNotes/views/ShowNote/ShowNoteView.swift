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
    }

    private var titleSection: some View {
        HStack {
            TextField("Title", text: $viewModel.note.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding()
            Spacer()
        }
        .background(.ultraThinMaterial)
        .cornerRadius(10)
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

    private var todoList: some View {
        List {
            Button(action: {
                viewModel.insertTodo()
                focusedTodoIndex = 0
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add Item")
                }
            }
            
            ForEach(Array(viewModel.note.todos.enumerated()), id: \.offset) { index, todo in
                
                HStack {
                    Image(systemName: todo.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.isComplete ? .green : .gray)
                        .onTapGesture {
                            viewModel.toggleTodoComplete(index)
                        }

                    TextField("To-do", text: Binding(
                                get: { viewModel.note.todos[index].item },
                                set: { viewModel.note.todos[index].item = $0 }
                            ))
                        .focused($focusedTodoIndex, equals: index)
                        .padding(.vertical, 8)
                        .foregroundColor(todo.isComplete ? .gray : .black)
                        .strikethrough(todo.isComplete, color: .gray)
                }
                .padding(.vertical, 8)
            }

            Button(action: {
                viewModel.addTodo()
                focusedTodoIndex = viewModel.note.todos.count - 1
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add Item")
                }
            }
        }
        .listStyle(.plain)
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
