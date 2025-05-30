//
//  ShowImageView.swift
//  MyNotes
//
//  Created by David Noy on 30/05/2025.
//

import SwiftUI

struct ShowImageView: View {
    let image: UIImage?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
        }
        .navigationTitle("Image")
        .navigationBarTitleDisplayMode(.inline)
    }
}
