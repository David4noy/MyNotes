//
//  ClearFullCoverBackground.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import SwiftUI

struct ClearFullCoverBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
