//
//  MapView.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/15/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @State private var currentRegion: MKCoordinateRegion = .init(center: .empowerStadium, span: MapViewModel.Constants.defaultSpan)
    @State private var showMarkerSheet = false
    @Bindable private var viewModel = MapViewModel()
    
    var body: some View {
        MapReader { proxy in
            Map(position: self.$viewModel.cameraPosition, selection: self.$viewModel.selectedTag) {
                UserAnnotation()
                
                if let userPlacedCoordinate = self.viewModel.userPlacedLocation?.location.coordinate {
                    Marker("", coordinate: userPlacedCoordinate)
                        .tag(MapViewModel.Constants.userPlacedLocationTag)
                }
                
                ForEach(self.viewModel.mapSearchResults.indices, id: \.self) { idx in
                    let mapItem = self.viewModel.mapSearchResults[idx]
                    Marker("", coordinate: mapItem.location.coordinate)
                        .tag(idx)
                }
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                self.currentRegion = context.region
            }
            .onChange(of: self.viewModel.selectedTag) {
                if self.viewModel.selectedTag != nil {
                    self.showMarkerSheet = true
                }
            }
            .onTapGesture { position in
                // FIXME: Ideally the sheet pops up automatically, but when setting the selected tag immediately, the view model gets asked for the selected tag twice in quick succession and the second time sets the tag to nil.  Additionally, when the user actually taps the pin, a new one is placed slightly off of the one the user tried to tap.  This can be fixed by having a "pin placing" state, though that isn't ideal user experience.
                if let coordinate = proxy.convert(position, from: .local) {
                    self.viewModel.setUserPlacedLocation(at: coordinate)
                }
            }
            .sheet(isPresented: self.$showMarkerSheet,
                   onDismiss: {
                withAnimation { self.viewModel.selectedTag = nil }
            }) {
                if let mapItem = self.viewModel.getSelectedLocation()  {
                    MarkerSheetView(mapItem: mapItem)
                } else {
                    Text("Error: Invalid location selected")
                        .presentationDetents([Constants.errorSheetDetents])
                }
            }
            .safeAreaInset(edge: .bottom) {
                self.searchBox
            }
        }
    }
    
    // MARK: - Search Box
    
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
                        .offset(x: Constants.searchCancelIconOffset)
                    }
                }
                .onSubmit {
                    Task {
                        await self.viewModel.search(self.currentRegion, searchText: self.searchText)
                        self.viewModel.selectedTag = nil
                    }
                }
            
        }
        .padding()
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let searchCancelIcon = "xmark.circle.fill"
        static let searchCancelIconOffset: CGFloat = -5
        static let errorSheetDetents: PresentationDetent = .height(50)
    }
}

// MARK: - Preview

#Preview {
    MapView()
}

extension CLLocationCoordinate2D {
    static let empowerStadium = CLLocationCoordinate2D(latitude: 39.7439, longitude: 105.0201)
}
