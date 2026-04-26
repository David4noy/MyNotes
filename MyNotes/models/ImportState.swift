//
//  ImportState.swift
//  MyNotes
//
//  Created by David Noy on 26/04/2026.
//

enum ImportState {
    case regular
    case didImport([Note])
    case didFail
}
