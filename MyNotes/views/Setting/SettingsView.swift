//
//  SettingsView.swift
//  MyNotes
//
//  Created by David Noy on 18/04/2025.
//

import SwiftUI

struct SettingsView: View {
    @Binding var settings: AppSettings
    @State private var selectedMenuItem: MenuItem?
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    
    var body: some View {
        VStack {
            Form {
                sortSection()
                themeSection()
                menuSection()
            }

            Spacer()
            versionFooter()
        }
        .navigationTitle("Menu")
        .navigationDestination(item: $selectedMenuItem) { item in
            switch item {
            case .about:
                AboutView()
            case .terms:
                TermsOfUseView()
            case .iCloudSync:
                ICloudSyncView()
            }
        }
        .onChange(of: settings) { _, newValue in
            newValue.save()
        }
    }

    private func sortSection() -> some View {
        Section(header: Text("Sort Notes By")) {
            Picker("Sort By", selection: $settings.sortBy) {
                ForEach(SortOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    private func themeSection() -> some View {
        Section(header: Text("Appearance")) {
            Picker("Theme", selection: $settings.theme) {
                ForEach(ThemeMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    private func menuSection() -> some View {
        Section {
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

            ForEach(MenuItem.allCases) { item in
                Button(action: {
                    selectedMenuItem = item
                }) {
                    Text(item.title)
                }
            }
        }
    }

    private func versionFooter() -> some View {
        Text("Version: " + appVersion)
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 10)
    }
}
