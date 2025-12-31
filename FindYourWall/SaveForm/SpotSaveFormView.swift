//
//  SpotSaveFormView.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/31/25.
//

import SwiftUI
import MapKit
import SwiftData

struct SpotSaveFormView: View {
    
    @Environment(\.modelContext) var modelContext
    
    let mapItem: MKMapItem
    
    // TODO: Create a form model
    @State private var streetAddress: String
    @State private var city: String
    @State private var name = ""
    @State private var zipcode = "" {
        willSet {
            self.zipcode = String(newValue.filter { $0.isNumber })
        }
    }
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        
        // TODO: This will include the city name. Maybe just make address a single string
        self.streetAddress = mapItem.address?.shortAddress ?? ""
        self.city = mapItem.addressRepresentations?.cityName ?? ""
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    TextField("Name (Required)", text: self.$name)
                }

                Section(header: Text("Address (Optional)")) {
                    TextField("Street Address", text: self.$streetAddress)
                    
                    TextField("City", text: self.$city)
                    
                    TextField("ZIP Code", text: self.$zipcode)
                        .keyboardType(.numberPad)
                    
                }
            }
            .navigationTitle("Wall Ball Spot")
            .safeAreaInset(edge: .bottom) {
                
                // TODO: Add an error view above the button if form is invalid
                // TODO: The color of this button was invisible when it was disabled
                Button("Submit") {
                    if isFormValid {
                        submit()
                    }
                }
                .disabled(!isFormValid)
                .buttonStyle(.primaryAction)
            }
        }
    }
    
    private func submit() {
        print("Name:", self.name)
        print("Street Address:", self.streetAddress.isEmpty ? "(none)" : self.streetAddress)
        print("City:", self.city.isEmpty ? "(none)" : self.city)
        print("Zipcode:", self.zipcode.isEmpty ? "(none)" : self.zipcode)
    }
    
    private func saveWallBallSpot() {
        let spot = LocalWallBallSpot(name: self.mapItem.name ?? "",
                                     coordinate: .init(from: self.mapItem.location.coordinate),
                                     address: .init(from: self.mapItem) )
        modelContext.insert(spot)
    }
}


#Preview {
    SpotSaveFormView(mapItem: MKMapItem(location: .init(latitude: 123, longitude: 456), address: nil))
}
