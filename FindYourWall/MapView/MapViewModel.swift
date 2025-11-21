//
//  MapViewModel.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/16/25.
//

import Foundation
import CoreLocation
import MapKit

@Observable
class MapViewModel: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    
    var currentLocation: CLLocation?
    var mapSearchResults: [MKMapItem] = []
    
    init(withLocationManager locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startMonitoringSignificantLocationChanges()
        self.currentLocation = locationManager.location
    }
    
    deinit {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first, location.timestamp > self.currentLocation?.timestamp ?? Date.distantPast {
            self.currentLocation = location
        }
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
}
