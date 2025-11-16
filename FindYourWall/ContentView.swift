//
//  ContentView.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/15/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
   
    @State private var cameraPosition: MapCameraPosition = .region(
        .init(center: .empowerStadium, span: Constants.defaultSpan)
    )
    
    private struct Constants {
        static let defaultSpan: MKCoordinateSpan = .init(latitudeDelta: 0.01,
                                                         longitudeDelta: 0.01)
    }
    
    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
        }
        .onAppear {
            updateCameraPositionToUserLocation()
        }
    }
    
    private func updateCameraPositionToUserLocation() {
        if let userLocation = CLLocationManager().location?.coordinate {
            cameraPosition = .region(
                .init(center: userLocation, span: Constants.defaultSpan)
            )
        }
    }
    
}

#Preview {
    ContentView()
}

extension CLLocationCoordinate2D {
    static let empowerStadium = CLLocationCoordinate2D(latitude: 39.7439, longitude: 105.0201)
}
