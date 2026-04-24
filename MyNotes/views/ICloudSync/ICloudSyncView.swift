//
//  ICloudSyncView.swift
//  MyNotes
//
//  Created by David Noy on 02/05/2025.
//

import SwiftUI
import SwiftData

struct ICloudSyncView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel = ICloudSyncViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Sync Status")
                        Spacer()
                        Label(viewModel.isICloudAvailable ? "Enabled" : "Disabled",
                              systemImage: viewModel.isICloudAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(viewModel.isICloudAvailable ? .green : .red)
                    }
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(viewModel.statusDescription)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Options") {
                    Button {
                        viewModel.openSettings()
                    } label: {
                        HStack {
                            Text("Change iCloud Settings")
                            Spacer()
                            Image(systemName: isAppInHebrew ? "chevron.left" : "chevron.right")
                                .foregroundStyle(.gray)
                        }
                    }

                    Button("Recheck Status") {
                        viewModel.checkICloudStatus()
                    }
                }

                // Only show when it actually matters:
                if modelContext.hasChanges {
                    Section("Pending Changes") {
                        Button {
                            do {
                                try modelContext.save() // Triggers sync if CloudKit is enabled
                            } catch {
                                // In production, present an error to the user
                                print("Save failed: \(error)")
                            }
                        } label: {
                            HStack {
                                Text("Save Pending Changes")
                                Spacer()
                                Image(systemName: "arrow.clockwise")
                                    .foregroundStyle(.gray)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("iCloud Sync")
            .task { viewModel.checkICloudStatus() }
        }
    }
}
