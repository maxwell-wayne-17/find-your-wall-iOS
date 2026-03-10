//
//  LocalWallBallSpotSheetView.swift
//  FindYourWall
//
//  Created by Max Wayne on 1/8/26.
//

import SwiftUI
import SwiftData
import MapKit

struct LocalWallBallSpotSheetView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showSaveForm = false
    
    let spot: LocalWallBallSpot
    
    var body: some View {
        VStack(spacing: Constants.vstackSpacing) {
            
            Spacer()
            
            Text(spot.name)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top])
            
            Text(spot.streetAddress ?? "\(spot.cLCoordinate)")
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                        
            VStack(spacing: Constants.buttonVstackSpacing) {
                Button {
                    self.openInMaps()
                } label: {
                    Text("GO ➡️")
                }
                .buttonStyle(.primaryAction(.green))
                
                HStack {
                    Button {
                        self.showSaveForm = true
                    } label: {
                        Text("Edit")
                    }
                    .buttonStyle(.primaryAction())
                    
                    Button {
                        self.deleteSpot()
                        self.dismiss()
                    } label: {
                        Text("Delete")
                    }
                    .buttonStyle(.primaryAction(.red))
                }
            }
        }
        .padding()
        .presentationDetents([Constants.detents])
        .sheet(isPresented: self.$showSaveForm,
               onDismiss: { self.dismiss() }) {
            SpotSaveFormView(viewModel: .init(spot: self.spot))
        }
    }
    
    private func openInMaps() {
        let mapItem = MKMapItem(location: .init(latitude: spot.latitude,
                                                longitude: spot.longitude),
                                address: nil)
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    private func deleteSpot() {
        self.modelContext.delete(self.spot)
    }
    
    private struct Constants {
        static let vstackSpacing: CGFloat = 16
        static let buttonVstackSpacing: CGFloat = -20
        static let detents: PresentationDetent = .height(260)
    }
}

#Preview {
    SheetPreviewHost(content: LocalWallBallSpotSheetView(spot: .init(name: "Name",
                                                                     latitude: 123,
                                                                     longitude: 456,
                                                                     streetAddress: "123 Street St",
                                                                     cityName: "City Name",
                                                                     zipCode: "12345")))
}
