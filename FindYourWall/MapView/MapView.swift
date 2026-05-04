//
//  MapView.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/15/25.
//

import MapKit
import SwiftUI

struct MapView: View {

    @State private var currentRegion: MKCoordinateRegion = .init(center: .empowerStadium, span: MapViewModel.Constants.defaultSpan)
    @Bindable private var viewModel: MapViewModel

    private let spotService: SpotService

    init(spotService: SpotService) {
        self.spotService = spotService
        self.viewModel = MapViewModel(spotService: spotService)
    }
    
    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(position: self.$viewModel.cameraPosition, selection: self.$viewModel.selectedTag) {
                    UserAnnotation()
                    
                    if let userPlacedCoordinate = self.viewModel.userPlacedLocation?.location.coordinate {
                        Marker("", coordinate: userPlacedCoordinate)
                            .tag(MapViewModel.Constants.userPlacedLocationTag)
                    }
                    
                    ForEach(self.viewModel.spots) { spot in
                        Annotation("", coordinate: spot.cLCoordinate, anchor: .bottom) {
                            Text("🥍")
                                .font(.system(size: Constants.laxEmojiFontSize))
                                .padding(Constants.laxEmojiPadding)
                                .background(.blue.gradient, in: .circle)
                                .onTapGesture {
                                    self.viewModel.selectedLocalSpot = spot
                                }
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
                .sheet(item: self.$viewModel.selectedLocalSpot,
                       onDismiss: { self.viewModel.selectedLocalSpot = nil }) { spot in
                    WallBallSpotSheetView(spot: spot,
                                          spotService: self.spotService,
                                          onDelete: { await self.viewModel.fetchSpots() },
                                          onSave: { await self.viewModel.fetchSpots() })
                }
                .sheet(isPresented: self.$viewModel.showMarkerSheet,
                       onDismiss: {
                    withAnimation { self.viewModel.selectedTag = nil }
                }) {
                    if let mapItem = self.viewModel.getSelectedLocation()  {
                        MarkerSheetView(mapItem: mapItem,
                                        spotService: self.spotService,
                                        onSave: { await self.viewModel.fetchSpots() })
                    } else {
                        Text("Error: Invalid location selected")
                            .presentationDetents([Constants.errorSheetDetents])
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    self.searchBox
                }
                .task {
                    await self.viewModel.fetchSpots()
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
                            self.viewModel.mapSearchResults = []
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
                    // Clear the previous set pin if user is trying to place another.
                    if self.viewModel.userIsPlacingPin {
                        self.viewModel.userPlacedLocation = nil
                    }
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
        
        static let laxEmojiFontSize: CGFloat = 12
        static let laxEmojiPadding: CGFloat = 7
        
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
    MapView(spotService: CloudKitSpotService())
}

extension CLLocationCoordinate2D {
    static let empowerStadium = CLLocationCoordinate2D(latitude: 39.7439, longitude: 105.0201)
}
