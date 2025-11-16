//
//  MapView.swift
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
    
    @State private var viewModel = MapViewModel()
    
    private struct Constants {
        static let defaultSpan: MKCoordinateSpan = .init(latitudeDelta: 0.01,
                                                         longitudeDelta: 0.01)
        static let fabIconName = "plus.circle.fill"
        static let fabEdgeSize: CGFloat = 60
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()
            }
            .onAppear {
                self.updateCameraPositionToUserLocation()
            }
            
            self.fab
        }
    }
    
    private var fab: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    print("Floating button tapped")
                }) {
                    Image(systemName: Constants.fabIconName)
                        .resizable()
                        .foregroundStyle(Color.blue)
                        .frame(width: Constants.fabEdgeSize, height: Constants.fabEdgeSize)
                }
                .padding()
            }
        }
    }
    
    private func updateCameraPositionToUserLocation() {
        if let userLocation = self.viewModel.currentLocation?.coordinate {
            self.cameraPosition = .region(
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
