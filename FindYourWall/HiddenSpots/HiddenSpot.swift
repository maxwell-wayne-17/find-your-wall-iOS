//
//  HiddenSpot.swift
//  FindYourWall
//

import Foundation

struct HiddenSpot: Codable, Identifiable, Equatable, Hashable, Comparable {

    let id: String
    let name: String
    let address: String?

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
