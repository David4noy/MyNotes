//
//  SettingsView.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var settings: AppSettings
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Sort Notes By")) {
                    Picker("Sort By", selection: $settings.sortBy) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Text("App Language")
                        Spacer()
                        Text("Current Language text")
                            .foregroundColor(.gray)
                        Image(systemName: isAppInHebrew ? "chevron.left" : "chevron.right")
                            .foregroundColor(.gray)
                    }
                }

                Section(header: Text("Options")) {
                    Toggle("Add Location to Notes", isOn: $settings.addLocationToNotes)
                    Toggle("iCloud Auto Sync", isOn: $settings.iCloudAutoSync)
                }
            }
            .navigationTitle("Settings")
        }
        .onChange(of: settings) { _ , newValue in
            newValue.save()
        }
    }
}
