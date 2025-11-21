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
    
    @State private var currentRegion: MKCoordinateRegion = .init(center: .empowerStadium, span: Constants.defaultSpan)
    
    @State private var viewModel = MapViewModel()
    
    private struct Constants {
        static let defaultSpan: MKCoordinateSpan = .init(latitudeDelta: 0.01,
                                                         longitudeDelta: 0.01)
        static let fabIconName = "plus.circle.fill"
        static let fabEdgeSize: CGFloat = 60
        
        static let searchCancelIcon = "xmark.circle.fill"
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                ForEach(self.viewModel.mapSearchResults, id: \.self) { mapItem in
                    Marker("", coordinate: mapItem.location.coordinate)
                }
            }
            .onAppear {
                self.updateCameraPositionToUserLocation()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                self.currentRegion = context.region
            }
            .safeAreaInset(edge: .bottom) {
                self.searchBox
            }
        }
    }
    
    // MARK: Search Box
    
    @State private var searchText = ""
    @FocusState private var searchFieldFocus: Bool
    
    private var searchBox: some View {
        HStack {
            TextField("Search...", text: self.$searchText)
                .textFieldStyle(.roundedBorder)
                .focused(self.$searchFieldFocus)
                .overlay(alignment: .trailing) {
                    if self.searchFieldFocus {
                        Button {
                            self.searchText = ""
                            self.searchFieldFocus = false
                        } label: {
                            Image(systemName: Constants.searchCancelIcon)
                        }
                        .offset(x: -5)
                    }
                }
                .onSubmit {
                    Task {
                        await self.viewModel.search(self.currentRegion, searchText: self.searchText)
                    }
                }
            
        }
        .padding()
    }
    
    // MARK: Helpers
    
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
