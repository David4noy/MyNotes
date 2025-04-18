//
//  TextEditorPopup.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import SwiftUI

struct TextEditorPopup: View {
    @Binding var isPresented: Bool
    @Binding var internalText: String
    @Binding var note: Note
    var index: Int
    
    var body: some View {
        
        ZStack {
            Color.clear.ignoresSafeArea(.all).cornerRadius(25)
            ClearFullCoverBackground()
            
            VStack(spacing: 16) {
                Text("Edit Text")
                    .font(.headline)
                
                TextEditor(text: $internalText)
                    .frame(height: 150)
                //  .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Button("Save") {
                        note.todos[index].item = internalText
                        isPresented = false
                    }
                    .fontWeight(.bold)
                }
            }
            .padding()
            .background(note.color.cellColor)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: isPresented)
    }
}
