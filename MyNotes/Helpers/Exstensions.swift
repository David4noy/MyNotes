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

extension DateFormatter {
    static let backupFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}

// Toast View Modifier
extension View {
    func toast<Content: View>(
        isShowing: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay(
            VStack {
                Spacer()
                if isShowing.wrappedValue {
                    content()
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        )
    }
}
