//
//  MapView.swift
//  MyNotes
//
//  Created by David Noy on 09/05/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    let cameraPosition: MapCameraPosition = .region(.init(center: .init(latitude: 37.3346, longitude: -122.0090), latitudinalMeters: 1300, longitudinalMeters: 1300))
    
    let locationManager = CLLocationManager()
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var  isShowingLookAroundView = false
    
    var body: some View {
        Map(initialPosition: cameraPosition) {
//            Marker("Apple", systemImage: "laptopcomputer", coordinate: .appleVisitorCenter)
            
            Annotation("Apple Visitor Center", coordinate: .appleVisitorCenter, anchor: .bottom) {
                Image(systemName: "laptopcomputer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .padding(7)
                    .background(.pink.gradient, in: .circle)
                    .contextMenu {
                        Button("Open Lookaround", systemImage: "binoculars") {
                            
                        }
                        
                        Button("Get Direction", systemImage: "arrow.turn.down.right") {
                            
                        }
                    }
            }
            
            UserAnnotation()
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
        .mapStyle(.hybrid(elevation: .realistic))
//        .mapStyle(.standard(elevation: .realistic))
        .lookAroundViewer(isPresented: $isShowingLookAroundView, initialScene: lookAroundScene)
    }
}

extension CLLocationCoordinate2D {
    static let appleHQ = CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090)
    static let appleVisitorCenter = CLLocationCoordinate2D(latitude: 37.332753, longitude: -122.005372)
    static let panamaPark = CLLocationCoordinate2D(latitude: 37.347730, longitude: -122.018715)
}

#Preview {
    MapView()
}
