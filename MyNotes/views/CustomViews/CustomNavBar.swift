//
//  CustomNavBar.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI

struct CustomNavBar: View {
    var addNote: () -> Void
    var toggleSearch: () -> Void
    var menuTapped: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                menuTapped()
            }) {
                Image(systemName: "line.horizontal.3")
                    .font(.title2)
            }

            Spacer()

            Text("My Notes")
                .font(.headline)
                .fontWeight(.bold)

            Spacer()

            HStack(spacing: 16) {
                Button(action: {
                    addNote()
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                }

                Button(action: {
                    toggleSearch() 
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

