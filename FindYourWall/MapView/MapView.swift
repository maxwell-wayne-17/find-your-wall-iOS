//
//  MapView.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/15/25.
//

import MapKit
import SwiftUI
import SwiftData

struct MapView: View {
    
    @State private var currentRegion: MKCoordinateRegion = .init(center: .empowerStadium, span: MapViewModel.Constants.defaultSpan)
    @Bindable private var viewModel = MapViewModel()
    @Query private var localWallBallSpots: [LocalWallBallSpot]
    
    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: self.$viewModel.cameraPosition, selection: self.$viewModel.selectedTag) {
                    UserAnnotation()
                    
                    if let userPlacedCoordinate = self.viewModel.userPlacedLocation?.location.coordinate {
                        Marker("", coordinate: userPlacedCoordinate)
                            .tag(MapViewModel.Constants.userPlacedLocationTag)
                    }
                    
                    ForEach(self.localWallBallSpots) { spot in
                        Annotation("", coordinate: spot.coordinate.cLCoordinate, anchor: .bottom) {
                            Image(systemName: "star.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .padding(7)
                                .background(.yellow.gradient, in: .circle)
                        }
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
                    self.viewModel.selectedTagDidChange()
                }
                .onTapGesture { position in
                    // Note: Ideally the user can just tap and the marker sheet automatically appears,
                    // however there was an issue where the selected tag would get set to nil
                    // and trying to tap on a placed pin would drop another pin.
                    // Therefore, we create a special "placing pin" state where the user can place a pin
                    // and cannot open a marker sheet.
                    if self.viewModel.userIsPlacingPin,
                       let coordinate = proxy.convert(position, from: .local) {
                        self.viewModel.setUserPlacedLocation(at: coordinate)
                    }
                }
                .sheet(isPresented: self.$viewModel.showMarkerSheet,
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
                .overlay(alignment: .bottomTrailing) {
                    self.fab
                        .padding(.bottom, Constants.fabBottomPaddings)
                }
            }
            
            VStack {
                Text("Tap to place a pin")
                    .font(.title2)
                    .padding()
                    .glassEffect()
                    .opacity(self.viewModel.userIsPlacingPin ? 1 : 0)
                    // Note: Using opacity instead of conditionally displaying this view enables the view to animate when it's no longer displayed
                
                Spacer()
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
    
    // MARK: - Floating Action Button
    
    private var fab: some View {
            Button(action: {
                withAnimation {
                    self.viewModel.userIsPlacingPin.toggle()
                }
            }) {
                Image(systemName: Constants.fabIconName)
                    .resizable()
                    .foregroundStyle(Color.blue)
                    .frame(width: Constants.fabEdgeSize, height: Constants.fabEdgeSize)
                    .rotationEffect(.degrees(self.viewModel.userIsPlacingPin ? 45 : 0))
            }
            .padding(.trailing)
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let searchCancelIcon = "xmark.circle.fill"
        static let searchCancelIconOffset: CGFloat = -5
        
        static let errorSheetDetents: PresentationDetent = .height(50)
        
        static let fabIconName = "plus.circle.fill"
        static let fabEdgeSize: CGFloat = 60
        static let fabBottomPaddings: CGFloat = 60
    }
}

// MARK: - Preview

#Preview {
    MapView()
}

extension CLLocationCoordinate2D {
    static let empowerStadium = CLLocationCoordinate2D(latitude: 39.7439, longitude: 105.0201)
}
