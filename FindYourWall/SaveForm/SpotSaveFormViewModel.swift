//
//  SpotSaveFormViewModel.swift
//  FindYourWall
//
//  Created by Max Wayne on 1/2/26.
//

import Foundation
import MapKit

@Observable
class SpotSaveFormViewModel: NSObject {
    
    let mapItem: MKMapItem
    
    var streetAddress: String
    var city: String
    var name = ""
    
    private var _zipCode: String = ""
    var zipCode: String {
        get {
            self._zipCode
        }
        set {
            self._zipCode = String(newValue.filter { $0.isNumber }.prefix(5))
        }
    }
    
    var isFormValid: Bool {
        !self.name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        
        self.streetAddress = mapItem.address?.shortAddress?.split(separator: ",").map(String.init).first ?? ""
        self.city = mapItem.addressRepresentations?.cityName ?? ""
    }
    
    private var shortAddress: String {
        var shortAddress = ""
        
        if !self.streetAddress.isEmpty {
            shortAddress = self.streetAddress
        } else {
            return ""
        }
        
        if !self.city.isEmpty {
            shortAddress = "\(shortAddress), \(self.city)"
        } else {
            return shortAddress
        }
        
        if !self.zipCode.isEmpty {
            shortAddress = "\(shortAddress), \(self.zipCode)"
        }
        
        return shortAddress
    }
    
    var address: Address {
        if self.shortAddress.isEmpty {
            return Address(from: self.mapItem)
        }
        
        return Address(shortAddress: self.shortAddress.isEmpty ? nil : self.shortAddress,
                cityName: self.city.isEmpty ? nil : self.city)
    }
}
