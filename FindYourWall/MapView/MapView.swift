//
//  MapView.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/15/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var currentRegion: MKCoordinateRegion = .init(center: .empowerStadium, span: MapViewModel.Constants.defaultSpan)
    @State private var selectedTag: Int?
    @State private var viewModel = MapViewModel()
    
    var body: some View {
        ZStack {
            Map(position: self.$viewModel.cameraPosition, selection: self.$selectedTag) {
                UserAnnotation()
                
                ForEach(self.viewModel.mapSearchResults.indices, id: \.self) { idx in
                    let mapItem = self.viewModel.mapSearchResults[idx]
                    Marker("", coordinate: mapItem.location.coordinate)
                        .tag(idx)
                }
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                self.currentRegion = context.region
            }
            .onChange(of: self.selectedTag) {
                print("Tag tapped: \(String(describing: self.selectedTag))")
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
                            Image(systemName: MapViewModel.Constants.searchCancelIcon)
                        }
                        .offset(x: -5)
                    }
                }
                .onSubmit {
                    Task {
                        await self.viewModel.search(self.currentRegion, searchText: self.searchText)
                        self.selectedTag = nil
                    }
                }
            
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}

extension CLLocationCoordinate2D {
    static let empowerStadium = CLLocationCoordinate2D(latitude: 39.7439, longitude: 105.0201)
}
