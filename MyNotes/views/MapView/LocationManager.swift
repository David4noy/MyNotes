//
//  LocationManager.swift
//  MyNotes
//
//  Created by David Noy on 16/05/2025.
//

import MapKit
import Combine

enum LocationError: Error {
    case locationServicesDisabled
    case locationServicesDenied
    case locationServicesError
}

class LocationManager: NSObject {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    
    let locationError = PassthroughSubject<LocationError, Never>()
    var canUseLocation = false
    
    private override init() {
        super.init()
        locationManager.delegate = self
        handleAuthorization(locationManager.authorizationStatus)
    }
    
    func checkIfLocationServicesIsEnabled() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func handleAuthorization(_ status: CLAuthorizationStatus) {
        canUseLocation = false
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationError.send(.locationServicesDenied)
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            canUseLocation = true
        @unknown default:
            break
        }
    }
    
    func getUserLocation() async -> CLLocationCoordinate2D? {
        guard canUseLocation else {
            return nil
        }
        let updates = CLLocationUpdate.liveUpdates()
        do {
            let update = try await updates.first { $0.location?.coordinate != nil }
            return update?.location?.coordinate
        } catch {
            print("Cannot get user location: \(error)")
            locationError.send(.locationServicesError)
            return nil
        }
    }
    
    func getFullAddress(from coordinate: CLLocationCoordinate2D, locale: Locale = .current) async -> String? {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location, preferredLocale: locale)
            
            guard let placemark = placemarks.first else {
                return nil
            }

            // Extract components
            let streetNumber = placemark.subThoroughfare ?? ""
            let street = placemark.thoroughfare ?? ""
            let city = placemark.locality ?? ""
            let country = placemark.country ?? ""

            // Build address components list
            var components: [String] = []

            if !(street.isEmpty && streetNumber.isEmpty) {
                components.append("\(street) \(streetNumber)".trimmingCharacters(in: .whitespaces))
            }

            if !city.isEmpty {
                components.append(city)
            }

            if !country.isEmpty {
                components.append(country)
            }

            // Combine components into a full address
            let address = components.joined(separator: ", ")

            // Optionally add name if it's useful (not just the street or something unknown)
//            if let name = placemark.name,
//               name != street,
//               !name.lowercased().contains("unnamed"),
//               !name.trimmingCharacters(in: .whitespaces).isEmpty {
//                address = "\(name), \(address)"
//            }

            return address.isEmpty ? nil : address

        } catch {
            print("Geocoding failed: \(error.localizedDescription)")
            return nil
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization(manager.authorizationStatus)
    }
}
