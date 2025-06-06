//
//  Exstensions.swift
//  MyNotes
//
//  Created by David Noy on 06/06/2025.
//

import SwiftUI

extension String: @retroactive Identifiable {
    public var id: String { self }
}

extension View {
    func alignedText(isHebrew: Bool) -> some View {
        self.multilineTextAlignment(isHebrew ? .trailing : .leading)
    }

    func alignedTextField(isHebrew: Bool) -> some View {
        self.multilineTextAlignment(isHebrew ? .trailing : .leading)
            .frame(maxWidth: .infinity, alignment: isHebrew ? .trailing : .leading)
    }
}
