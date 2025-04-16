//
//  ShowNoteView.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI

struct ShowNoteView: View {
    @StateObject private var viewModel: ShowNoteViewModel

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
    }

    private var titleSection: some View {
        HStack {
            TextField("Title", text: $viewModel.note.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding()
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            hideKeyboard()
                        }
                    }
                }
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
            ForEach(Array(viewModel.note.todos.enumerated()), id: \.offset) { index, todo in
                HStack {
                    Image(systemName: todo.isComplete ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todo.isComplete ? .green : .gray)
                        .onTapGesture {
                            viewModel.toggleTodoComplete(index)
                        }

                    TextField("Todo Item", text: $viewModel.note.todos[index].item)
                        .padding(.vertical, 8)
                        .foregroundColor(todo.isComplete ? .gray : .black)
                        .strikethrough(todo.isComplete, color: .gray)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    hideKeyboard()
                                }
                            }
                        }
                }
                .padding(.vertical, 8)
            }

            Button(action: {
                viewModel.addTodo()
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
        TextEditor(text: $viewModel.note.content)
            .padding()
            .font(.body)
            .cornerRadius(10)
            .foregroundColor(Color.primary)
            .padding()
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
