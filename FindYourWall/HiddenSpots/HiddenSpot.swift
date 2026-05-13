//
//  HiddenSpot.swift
//  FindYourWall
//

import Foundation

struct HiddenSpot: Codable, Identifiable, Equatable, Hashable, Comparable {
    
    let id: String
    let name: String
    let address: String?
    
    init(id: String, name: String, address: String?) {
        self.id = id
        self.name = name
        self.address = address
    }
    
    init(from spot: WallBallSpot) {
        self.id = spot.id.uuidString
        self.name = spot.name
        self.address = spot.address
    }

    static func == (lhs: HiddenSpot, rhs: HiddenSpot) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func < (lhs: HiddenSpot, rhs: HiddenSpot) -> Bool {
        lhs.name < rhs.name
    }
}
