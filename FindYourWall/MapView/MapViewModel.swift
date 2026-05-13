//
//  MapViewModel.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/16/25.
//

import Combine
import CoreLocation
import Foundation
import MapKit
import _MapKit_SwiftUI

@Observable
class MapViewModel: NSObject, CLLocationManagerDelegate {
    private let notificationCenter: NotificationCenter
    private var locationManager: CLLocationManager
    private let spotService: SpotService
    private let hiddenSpotsStore: HiddenSpotsStore
    private var cancellables = Set<AnyCancellable>()

    var cameraPosition: MapCameraPosition = .region(.init(center: .empowerStadium, span: Constants.defaultSpan))

    var mapSearchResults: [MKMapItem] = []
    var selectedTag: Int?
    var userPlacedLocation: MKMapItem?
    var userIsPlacingPin = false
    var showMarkerSheet = false
    var selectedLocalSpot: WallBallSpot?
    var spots: [WallBallSpot] = []
    var showHiddenSpotsSheet = false
    var errorMessage: String?

    var visibleSpots: [WallBallSpot] {
        self.spots.filter { !self.hiddenSpotsStore.isHidden(id: $0.id.uuidString) }
    }

    init(spotService: SpotService,
         hiddenSpotsStore: HiddenSpotsStore = .init(),
         notificationCenter: NotificationCenter = .default,
         locationManager: CLLocationManager = .init()) {
        self.spotService = spotService
        self.hiddenSpotsStore = hiddenSpotsStore
        self.notificationCenter = notificationCenter
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.setCameraPosition(for: locationManager.location)

        self.notificationCenter.publisher(for: .wallBallSpotDidSave)
            .compactMap { $0.object as? WallBallSpot }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] savedSpot in
                guard let self else { return }
                if let idx = self.spots.firstIndex(where: { $0.id == savedSpot.id }) {
                    self.spots[idx] = savedSpot
                } else {
                    self.spots.append(savedSpot)
                }
            }
            .store(in: &self.cancellables)

        self.notificationCenter.publisher(for: .wallBallSpotDidDelete)
            .compactMap { $0.object as? String }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recordName in
                self?.spots.removeAll { $0.recordName == recordName }
            }
            .store(in: &self.cancellables)
    }
    
    deinit {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    @MainActor
    func search(_ region: MKCoordinateRegion, searchText: String) async {
        self.mapSearchResults = []
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let response = try? await MKLocalSearch(request: request).start()
        self.mapSearchResults = response?.mapItems ?? []
    }
    
    func setUserPlacedLocation(at coordinate: CLLocationCoordinate2D) {
        self.userPlacedLocation = MKMapItem(location: .init(latitude: coordinate.latitude,
                                                            longitude: coordinate.longitude),
                                            address: nil)
    }
    
    func getSelectedLocation() -> MKMapItem? {
        if self.selectedTag == Constants.userPlacedLocationTag { return self.userPlacedLocation }
        
        guard let tag = self.selectedTag, tag >= 0, tag < self.mapSearchResults.count else { return nil }
        return self.mapSearchResults[tag]
    }
    
    func selectedTagDidChange() {
        if self.userIsPlacingPin == false &&
            self.selectedTag != nil {
            self.showMarkerSheet = true
        } else {
            self.selectedTag = nil
            self.showMarkerSheet = false
        }
    }
    
    func clearMapMarkers() {
        self.mapSearchResults = []
        self.userPlacedLocation = nil
    }
    
    private func setCameraPosition(for location: CLLocation?) {
        guard let userLocation = location?.coordinate else { return }
        self.cameraPosition = .region(
            .init(center: userLocation, span: Constants.defaultSpan)
        )
    }
    
    // MARK: - Spots

    @MainActor
    func fetchSpots() async {
        let result = await self.spotService.fetchAllSpots { spots in
            self.spots.append(contentsOf: spots)
        }
        switch result {
        case .success:
            return
        case .failure(let error):
            self.errorMessage = error.localizedDescription
        }
    }

    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.setCameraPosition(for: locations.first)
    }
    
    // MARK: - Constants
    
    struct Constants {
        static let defaultSpan: MKCoordinateSpan = .init(latitudeDelta: 0.01,
                                                         longitudeDelta: 0.01)
        static let userPlacedLocationTag = -1
    }
}
