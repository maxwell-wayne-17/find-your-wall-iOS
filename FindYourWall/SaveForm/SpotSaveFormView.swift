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
    @Environment(\.dismiss) private var dismiss
    
    @Bindable private var viewModel: SpotSaveFormViewModel
    
    private enum FocusedField {
        case name, streetAddress, city, zipCode, note
    }
    @FocusState private var focusedField: FocusedField?
    
    init(viewModel: SpotSaveFormViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    TextField("Name (Required)", text: self.$viewModel.name)
                        .focused(self.$focusedField, equals: .name)
                }
                
                Section(header: Text("Address (Optional)")) {
                    TextField("Street Address", text: self.$viewModel.streetAddress)
                        .focused(self.$focusedField, equals: .streetAddress)

                    TextField("City", text: self.$viewModel.city)
                        .focused(self.$focusedField, equals: .city)

                    TextField("ZIP Code", text: self.$viewModel.zipCode)
                        .keyboardType(.numberPad)
                        .focused(self.$focusedField, equals: .zipCode)

                }

                Section(header: Text("Note (Optional)")) {
                    TextEditor(text: self.$viewModel.note)
                        .focused(self.$focusedField, equals: .note)
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
                
                HStack {
                    Button("Cancel") {
                        self.dismiss()
                    }
                    .buttonStyle(.primaryAction())
                    
                    // TODO: The color of this button is glitchy when it is disabled in dark mode
                    Button("Save") {
                        if self.viewModel.isFormValid {
                            self.saveWallBallSpot()
                            self.dismiss()
                        }
                    }
                    .disabled(!self.viewModel.isFormValid || self.focusedField != nil)
                    .buttonStyle(.primaryAction())
                }
                // Ignoring the keyboard overlay wasn't working,
                // so worked around by making button invisible when text fields are in focus
                .opacity(self.focusedField != nil ? 0 : 1)
            }
        }
    }
    
    private func saveWallBallSpot() {
        let noteValue: String? = self.viewModel.note.isEmpty ? nil : self.viewModel.note
        if let spot = self.viewModel.existingSpot {
            spot.name = self.viewModel.name
            spot.streetAddress = self.viewModel.streetAddress
            spot.cityName = self.viewModel.city
            spot.zipCode = self.viewModel.zipCode
            spot.note = noteValue
        } else {
            let spot = LocalWallBallSpot(name: self.viewModel.name,
                                         latitude: self.viewModel.coordinate.latitude,
                                         longitude: self.viewModel.coordinate.longitude,
                                         streetAddress: self.viewModel.streetAddress,
                                         cityName: self.viewModel.city,
                                         zipCode: self.viewModel.zipCode,
                                         note: noteValue)
            self.modelContext.insert(spot)
        }
    }
    
    private struct Constants {
        static let keyboardDismissIcon = "keyboard.chevron.compact.down"
    }
}


#Preview {
    let viewModel = SpotSaveFormViewModel(mapItem: MKMapItem(location: .init(latitude: 123, longitude: 456), address: nil))
    SpotSaveFormView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
