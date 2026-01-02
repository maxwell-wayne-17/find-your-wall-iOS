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
        case name, streetAddress, city, zipCode
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
                    if self.viewModel.isFormValid {
                        self.saveWallBallSpot()
                        self.dismiss()
                    }
                }
                // Ignoring the keyboard overlay wasn't working,
                // so worked around by making button invisible when text fields are in focus
                .disabled(!self.viewModel.isFormValid || self.focusedField != nil)
                .opacity(self.focusedField != nil ? 0 : 1)
                .buttonStyle(.primaryAction)
            }
        }
    }
    
    private func saveWallBallSpot() {
        let spot = LocalWallBallSpot(name: self.viewModel.name,
                                     coordinate: .init(from: self.viewModel.mapItem.location.coordinate),
                                     address: self.viewModel.address )
        modelContext.insert(spot)
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
