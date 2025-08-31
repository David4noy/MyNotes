//
//  ICloudSyncViewModel.swift
//  MyNotes
//
//  Created by David Noy on 02/05/2025.
//

import Foundation
import CloudKit
import UIKit

@MainActor
final class ICloudSyncViewModel: ObservableObject {
    @Published var isICloudAvailable: Bool = false
    @Published var statusDescription: String = "Unknown"
    let containerID: String

    init(containerID: String = "iCloud.com.davidnoy.mynotes") {
        self.containerID = containerID
        checkICloudStatus()
    }

    func checkICloudStatus() {
        let container = CKContainer(identifier: containerID)
        container.accountStatus { [weak self] status, error in
            Task { @MainActor in
                guard let self else { return }
                switch status {
                case .available:
                    self.isICloudAvailable = true
                    self.statusDescription = "Available"
                case .noAccount:
                    self.isICloudAvailable = false
                    self.statusDescription = "No iCloud account"
                case .restricted:
                    self.isICloudAvailable = false
                    self.statusDescription = "Restricted"
                case .couldNotDetermine:
                    fallthrough
                case .temporarilyUnavailable:
                    self.isICloudAvailable = false
                    self.statusDescription = "Temporarily unavailable"
                @unknown default:
                    self.isICloudAvailable = false
                    self.statusDescription = error?.localizedDescription ?? "Unknown"
                }
            }
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
