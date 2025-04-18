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
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Language")) {
                    Picker("App Language", selection: $settings.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
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
