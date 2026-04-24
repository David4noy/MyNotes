//
//  GlobalICloudManager.swift
//  MyNotes
//
//  Created by David Noy on 24/04/2026.
//

import Foundation
import CloudKit

@MainActor
final class GlobalICloudManager: ObservableObject {
    private let containerID = "iCloud.com.davidnoy.mynotes"
    
    func checkICloudStatus() async -> Bool {
        let container = CKContainer(identifier: containerID)
        
        return await withCheckedContinuation { continuation in
            container.accountStatus { status, error in
                switch status {
                case .available:
                    continuation.resume(returning: true)
                case .noAccount, .restricted, .couldNotDetermine, .temporarilyUnavailable:
                    continuation.resume(returning: false)
                @unknown default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
}

