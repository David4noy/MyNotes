//
//  CustomNavBar.swift
//  MyNotes
//
//  Created by David Noy on 07/02/2025.
//

import SwiftUI

struct CustomNavBar: View {
    var body: some View {
        HStack {
            Button(action: {
                print("Menu button tapped")
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
                    print("Plus button tapped")
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                }
                
                Button(action: {
                    print("Search button tapped")
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

#Preview {
    CustomNavBar()
}
