//
//  HiddenSpot.swift
//  FindYourWall
//

import Foundation

struct HiddenSpot: Codable, Identifiable, Equatable {

    let id: String
    let name: String
    let address: String?

    static func == (lhs: HiddenSpot, rhs: HiddenSpot) -> Bool {
        lhs.id == rhs.id
    }
}
