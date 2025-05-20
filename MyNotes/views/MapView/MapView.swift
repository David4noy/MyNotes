//
//  MapView.swift
//  MyNotes
//
//  Created by David Noy on 09/05/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    let title: String
    let latitude: Double
    let longitude: Double
    
    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private var cameraPosition: MapCameraPosition {
        .region(.init(center: coordinate, latitudinalMeters: 100, longitudinalMeters: 100))
    }
    
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var isShowingLookAroundView = false
    @State private var route: MKRoute?

    var body: some View {
        Map(initialPosition: cameraPosition) {
            Annotation(title, coordinate: coordinate, anchor: .bottom) {
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .background(.red.gradient, in: .circle)
                    .contextMenu {
                        Button("Open Lookaround", systemImage: "binoculars") {
                            Task {
                                lookAroundScene = await getLookAroundScene(from: coordinate)
                                guard lookAroundScene != nil else { return }
                                isShowingLookAroundView = true
                            }
                        }

                        Button("Get Direction", systemImage: "arrow.turn.down.right") {
                            getDirections(to: coordinate)
                        }
                    }
            }

            UserAnnotation()

            if let route {
                MapPolyline(route)
                    .stroke(.green, lineWidth: 4)
            }
        }
        .onAppear {
            LocationManager.shared.checkIfLocationServicesIsEnabled()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
        .mapStyle(.hybrid(elevation: .realistic))
        .lookAroundViewer(isPresented: $isShowingLookAroundView, initialScene: lookAroundScene)
    }

    private func getLookAroundScene(from coordinate: CLLocationCoordinate2D) async -> MKLookAroundScene? {
        do {
            return try await MKLookAroundSceneRequest(coordinate: coordinate).scene
        } catch {
            print("Cannot retrieve Look Around scene: \(error.localizedDescription)")
            return nil
        }
    }

    private func getDirections(to destination: CLLocationCoordinate2D) {
        Task {
            guard let userLocation = await LocationManager.shared.getUserLocation() else { return }

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.transportType = .walking

            do {
                let directions = try await MKDirections(request: request).calculate()
                route = directions.routes.first
            } catch {
                print("Failed to calculate directions: \(error.localizedDescription)")
            }
        }
    }
}
