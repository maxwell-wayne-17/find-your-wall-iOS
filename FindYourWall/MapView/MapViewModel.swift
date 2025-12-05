//
//  MapViewModel.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/16/25.
//

import Foundation
import CoreLocation
import MapKit
import _MapKit_SwiftUI

@Observable
class MapViewModel: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    
    var cameraPosition: MapCameraPosition = .region(.init(center: .empowerStadium, span: Constants.defaultSpan))
       
    var mapSearchResults: [MKMapItem] = []    
    var selectedTag: Int?
    var userPlacedLocation: MKMapItem?
    var userIsPlacingPin = false
    var showMarkerSheet = false
    
    init(withLocationManager locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.setCameraPosition(for: locationManager.location)
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
    
    private func setCameraPosition(for location: CLLocation?) {
        guard let userLocation = location?.coordinate else { return }
        self.cameraPosition = .region(
            .init(center: userLocation, span: Constants.defaultSpan)
        )
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
