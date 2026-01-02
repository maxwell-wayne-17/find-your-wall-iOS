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
    
    private enum FocusedField {
        case name, streetAddress, city, zipCode
    }
    @FocusState private var focusedField: FocusedField?
    
    var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
        
        self.streetAddress = mapItem.address?.shortAddress?.split(separator: ",").map(String.init).first ?? ""
        self.city = mapItem.addressRepresentations?.cityName ?? ""
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    TextField("Name (Required)", text: self.$name)
                        .focused(self.$focusedField, equals: .name)
                }
                
                Section(header: Text("Address (Optional)")) {
                    TextField("Street Address", text: self.$streetAddress)
                        .focused(self.$focusedField, equals: .streetAddress)
                    
                    TextField("City", text: self.$city)
                        .focused(self.$focusedField, equals: .city)
                    
                    TextField("ZIP Code", text: self.$zipcode)
                        .keyboardType(.numberPad)
                        .focused(self.$focusedField, equals: .zipCode)
                    
                }
            }
            .navigationTitle("Wall Ball Spot")
            .toolbar {
                ToolbarItem(placement: .keyboard) { Spacer() }
                ToolbarItem(placement: .keyboard) {
                    Button {
                        self.focusedField = nil
                    } label: {
                        Image(systemName: Constants.keyboardDismissIcon)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                
                // TODO: The color of this button is glitchy when it is disabled in dark mode
                Button("Save") {
                    if self.isFormValid {
                        submit()
                    }
                }
                // Ignoring the keyboard overlay wasn't working,
                // so worked around by making button invisible when text fields are in focus
                .disabled(!self.isFormValid || self.focusedField != nil)
                .opacity(self.focusedField != nil ? 0 : 1)
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
    
    private struct Constants {
        static let keyboardDismissIcon = "keyboard.chevron.compact.down"
    }
}


#Preview {
    SpotSaveFormView(mapItem: MKMapItem(location: .init(latitude: 123, longitude: 456), address: nil))
        .preferredColorScheme(.dark)
}
