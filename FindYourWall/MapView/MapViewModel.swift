//
//  MapViewModel.swift
//  FindYourWall
//
//  Created by Max Wayne on 11/16/25.
//

import Foundation
import CoreLocation

@Observable
class MapViewModel: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    
    var currentLocation: CLLocation?
    var markedLocations: [CLLocation] = []
    
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
    
    func markCurrentLocation() {
        guard let location = self.locationManager.location else { return }
        self.markedLocations.append(location)
    }
    
}
