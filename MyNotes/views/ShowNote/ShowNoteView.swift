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
    @State private var showColorPicker = false
    @State private var isShowingMap = false
    @State private var showImageOptions = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var isShowingFullImage = false
    @State private var showDeleteAlert = false
    @State private var showDeleteImageAlert = false
    @State private var showMenuPanel = false
    @State private var isAddingInTopOfList = false
    
    init(note: Note) {
        _viewModel = StateObject(wrappedValue: ShowNoteViewModel(note: note))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if showMenuPanel {
                    menuPanelView()
                }
                HStack {
                    imageSection
                    titleSection
                        .layoutPriority(1)
                }
                
                contentSection
                
                Spacer()
            }
            .padding()
            .background(viewModel.note.color.noteColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            showMenuPanel.toggle()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .padding(.vertical, 16)
                            .padding(.horizontal, 4)
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Add Next") {
                        addTodo(insertAtTop: isAddingInTopOfList)
                    }
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
            .task {
                viewModel.getInitialNoteImage()
                await viewModel.loadAddressIfNeeded()
            }
            .overlay(popupOverlay)
            .onChange(of: showMenuPanel) {
                if !showMenuPanel {
                    viewModel.noteShareURL = nil
                    viewModel.notePDFShareURL = nil
                }
            }
        }
        .navigationDestination(isPresented: $isShowingMap) {
            MapView(
                title: viewModel.note.title,
                latitude: viewModel.note.latitude ?? 0.0,
                longitude: viewModel.note.longitude ?? 0.0
            )
        }
        .navigationDestination(isPresented: $isShowingFullImage) {
            ShowImageView(image: viewModel.selectedUIImage)
        }
        .alert("Delete Location", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteLocation()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove the saved location from this note?")
        }
        .alert("Delete Image", isPresented: $showDeleteImageAlert) {
            Button("Delete", role: .destructive) {
                viewModel.selectedUIImage = nil
                viewModel.deleteNoteImage()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete the image from this note?")
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 0) {
            HStack (spacing: 4) {
                TextField(
                    String(localized: "Title"),
                    text: $viewModel.note.title,
                    onEditingChanged: { isEditing in
                        if !isEditing {
                            viewModel.onSaveNote()
                        }
                    }
                )
                .alignedText(isHebrew: viewModel.note.isRightToLeft)
                .font(.title)
                .minimumScaleFactor(0.7)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding()
                .layoutPriority(1)
            }
            .background(.ultraThinMaterial)
            .cornerRadius(viewModel.note.type == .todo ? 5 : 20)
        }
        .confirmationDialog("Choose Image Source", isPresented: $showImageOptions) {
            Button("Take a New Photo") {
                showCamera = true
            }
            Button("Choose from Library") {
                showPhotoLibrary = true
            }
            if viewModel.selectedUIImage != nil {
                Button("Delete Photo", role: .destructive) {
                    showDeleteImageAlert = true
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $viewModel.selectedUIImage)
        }
        .sheet(isPresented: $showPhotoLibrary) {
            PhotoLibraryPicker(image: $viewModel.selectedUIImage)
        }
        .onChange(of: viewModel.selectedUIImage) { oldImage, newImage in
            if let newImage {
                viewModel.setNoteImage(oldImage: oldImage, newImage: newImage)
            }
        }
    }
    
    func menuPanelView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            colorPicker
            
            noteLocationSection
            
            Button(action: {
                viewModel.toggleTextDirection()
            }) {
                Label("Change note's text direction", systemImage: "arrow.left.arrow.right")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
            }
            
            Button(action: {
                showImageOptions = true
            }) {
                Label("Photo Options", systemImage: "photo")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
            }
            
            if let noteShareURL = viewModel.noteShareURL {
                ShareLink(
                    item: noteShareURL,
                    preview: SharePreview("Note Share", image: Image("AppIconShare"))
                ) {
                    Label("Share Note", systemImage: "square.and.arrow.up")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.green)
                }
            } else {
                Button(action: {
                    viewModel.getNoteToShareTempURL()
                }) {
                    Label("Share Note: \(viewModel.shareLabelText) for sharing", systemImage: "square.and.arrow.up")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundStyle(viewModel.prepareToShareState.color)
                }
            }
            
            if let noteShareURL = viewModel.notePDFShareURL {
                ShareLink(
                    item: noteShareURL,
                    preview: SharePreview("Export Note As PDF", image: Image("AppIconShare"))
                ) {
                    Label("Export Note As PDF", systemImage: "square.and.arrow.up")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.green)
                }
            } else {
                Button(action: {
                    viewModel.getNoteToPDFToShareTempURL()
                }) {
                    Label("Export PDF: \(viewModel.exportLabelText) for exporting", systemImage: "square.and.arrow.up")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundStyle(viewModel.prepareToExportState.color)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(12)
        .transition(.scale.combined(with: .opacity))
    }
    
    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(NoteColor.allCases, id: \.self) { color in
                    Circle()
                        .fill(color.noteColor)
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
    
    @ViewBuilder
    private var noteLocationSection: some View {
        if let address = viewModel.address {
            HStack {
                noteLocation(address: address)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
            .padding(.vertical, 4)
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
    
    private func noteLocation(address: String) -> some View {
        Button {
            isShowingMap = true
        } label: {
            Label(address, systemImage: "location")
                .font(.subheadline)
                .foregroundColor(viewModel.note.color.textColor)
        }
        .padding(4)
    }
    
    private var imageSection: some View {
        Group {
            if let image = viewModel.selectedUIImage {
                HStack {
                    Spacer()
                    Button {
                        isShowingFullImage = true
                    } label: {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxHeight: 42)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .shadow(radius: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
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
                        
                        if let index = viewModel.todoIndex {
                            TextEditorPopup(
                                isPresented: $showPopup,
                                internalText: $viewModel.todoItem,
                                note: $viewModel.note,
                                index: index
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
            
            addButton(insertAtTop: true)
            
            todoItemsSection
            
            addButton(insertAtTop: false)
            
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
    
    private func addButton(insertAtTop: Bool) -> some View {
        Button(action: {
            addTodo(insertAtTop: insertAtTop)
        }) {
            todoButtonLabel
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.6))
                .cornerRadius(6)
                .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 4, leading: 2, bottom: 4, trailing: 2))
    }
    
    private func addTodo(insertAtTop: Bool) {
        isAddingInTopOfList = insertAtTop

        let newId = insertAtTop
            ? viewModel.insertTodoAndGetID()
            : viewModel.addTodoAndGetID()
        
        focusedTodoIndex = nil
        DispatchQueue.main.async {
            focusedTodoIndex = viewModel.indexOfTodo(withId: newId)
        }
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
            let index = viewModel.note.todos.firstIndex(where: { $0.id == todo.id })
            let isFocused = focusedTodoIndex == index
            let shouldEdit = (todo.item.isEmpty || isFocused)
            let completeColor: Color = .black.opacity(0.3)
            
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    if viewModel.note.isRightToLeft {
                        chevronImage()
                        Spacer()
                        todoTextField(todo: $todo, index: index, shouldEdit: shouldEdit, completeColor: completeColor)
                        completionImage(todo: $todo)
                    } else {
                        completionImage(todo: $todo)
                        todoTextField(todo: $todo, index: index, shouldEdit: shouldEdit, completeColor: completeColor)
                        Spacer()
                        chevronImage()
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    getTodoItemAndShowPopup(todoId: todo.id)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.white.opacity(0.4))
                .cornerRadius(10)
                .shadow(radius: 4)
                
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 4, leading: 2, bottom: 4, trailing: 2))
        }
        .onDelete(perform: deleteTodo)
        .onMove(perform: moveTodo)
    }
    
    private func completionImage(todo: Binding<TodoItem>) -> some View {
        Image(systemName: todo.wrappedValue.isComplete ? "checkmark.circle.fill" : "circle")
            .foregroundColor(todo.wrappedValue.isComplete ? .green : .blue)
            .onTapGesture {
                todo.wrappedValue.isComplete.toggle()
                viewModel.onSaveNote()
            }
    }
    
    private func todoTextField(todo: Binding<TodoItem>, index: Int?, shouldEdit: Bool, completeColor: Color) -> some View {
        Group {
            if shouldEdit {
                TextField("Write to-do", text: todo.item, axis: .vertical)
                    .onChange(of: todo.item.wrappedValue) {
                        viewModel.onSaveNote()
                    }
                    .alignedTextField(isHebrew: viewModel.note.isRightToLeft)
                    .font(.system(size: 24))
                    .focused($focusedTodoIndex, equals: index)
                    .foregroundColor(todo.wrappedValue.isComplete ? completeColor : viewModel.note.color.textColor)
                    .strikethrough(todo.wrappedValue.isComplete, color: completeColor)
                    .padding(.vertical, 8)
            } else {
                Text(todo.wrappedValue.item.isEmpty ? "Write to-do" : todo.wrappedValue.item)
                    .alignedText(isHebrew: viewModel.note.isRightToLeft)
                    .font(.system(size: 24))
                    .foregroundColor(todo.wrappedValue.isComplete ? completeColor : viewModel.note.color.textColor)
                    .strikethrough(todo.wrappedValue.isComplete, color: completeColor)
                    .padding(.vertical, 8)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }
    
    private func chevronImage() -> some View {
        Image(systemName: isAppInHebrew == viewModel.note.isRightToLeft ? "chevron.right" : "chevron.left")
            .foregroundColor(viewModel.note.todos.first?.isComplete == true ? .black.opacity(0.3) : viewModel.note.color.textColor)
    }
    
    private func getTodoItemAndShowPopup(todoId: UUID) {
        if let index = viewModel.note.todos.firstIndex(where: { $0.id == todoId }) {
            viewModel.setTodoItemAndShowPopup(index: index)
            showPopup = true
        }
    }
    
    private var textContent: some View {
        MultilineTextView(note: $viewModel.note, textColor: viewModel.note.color.textColor)
            .frame(minHeight: 200)
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

