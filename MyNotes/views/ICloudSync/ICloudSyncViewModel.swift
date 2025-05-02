//
//  ICloudSyncViewModel.swift
//  MyNotes
//
//  Created by David Noy on 02/05/2025.
//

import Foundation
import SwiftUI
import SwiftData
import CloudKit

@MainActor
class ICloudSyncViewModel: ObservableObject {
    @Published var isICloudAvailable: Bool = false

    init() {
        checkICloudStatus()
    }

    func checkICloudStatus() {
        isICloudAvailable = FileManager.default.ubiquityIdentityToken != nil
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url)
    }

//    func triggerSync(context: ModelContext?) async {
//        guard let container = context?.container.persistentModelCloudKitContainer else { return }
//
//        do {
//            try await container.sync()
//            print("✅ Manual sync completed.")
//        } catch {
//            print("❌ Sync failed: \(error.localizedDescription)")
//        }
//    }
}
