//
//  ICloudSyncView.swift
//  MyNotes
//
//  Created by David Noy on 02/05/2025.
//

import SwiftUI

struct ICloudSyncView: View {
    @ObservedObject var viewModel = ICloudSyncViewModel()

    var body: some View {
        NavigationStack {
            Form {
                
                Text("iCloud explanation")
                    .padding(4)
                
                Section() {
                    HStack {
                        Text("Sync Status")
                        Spacer()
                        Text(viewModel.isICloudAvailable ? "Enabled" : "Disabled")
                            .foregroundColor(viewModel.isICloudAvailable ? .green : .red)
                    }
                }
                
                Section(header: Text("Options")) {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Change iCloud Settings")
                            Spacer()
                            Image(systemName:  isAppInHebrew ? "chevron.left" : "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button {
                        Task { } // await viewModel.triggerSync(context: context)
                    } label: {
                        HStack {
                            Text("Sync Now")
                            Spacer()
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.gray)
                        }
                    }
                }

            }
            .navigationTitle("iCloud Sync")
        }
    }
}
