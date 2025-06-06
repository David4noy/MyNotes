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
                Section(header: Text("Sort Notes By")) {
                    Picker("Sort By", selection: $settings.sortBy) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section() {
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
            
            Spacer()
            
            Text("Version: " + appVersion)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 10)
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
}
