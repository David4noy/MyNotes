//
//  MenuSheet.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import SwiftUI

struct MenuSheet: View {
    @Binding var selectedMenuItem: MenuItem?
    @Binding var showMenuSheet: Bool

    var body: some View {
        NavigationView {
            List {
                ForEach(MenuItem.allCases) { item in
                    Button(action: {
                        selectedMenuItem = item
                        showMenuSheet = false
                    }) {
                        Text(item.title)
                    }
                }

                Section {
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Menu")
        }
    }
}
