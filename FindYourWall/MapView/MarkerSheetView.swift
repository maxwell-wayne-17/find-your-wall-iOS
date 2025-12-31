//
//  MarkerSheetView.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/3/25.
//

import MapKit
import SwiftUI

struct MarkerSheetView: View {
    @State private var showSaveForm = false
    let mapItem: MKMapItem
    
    var body: some View {
        VStack(spacing: Constants.markerSheetSpacing) {
            Spacer()
            
            Text(self.mapItem.name ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top])
            
            Text(self.mapItem.addressRepresentations?.fullAddress(includingRegion: false, singleLine: true) ??
                 "\(self.mapItem.location.coordinate.description ?? "")")
            .font(.body)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: {
                self.showSaveForm = true
            }) {
                Text("Add")
                
            }
            .buttonStyle(.primaryAction)
        }
        .padding()
        .presentationDetents([Constants.markerSheetDetentHeight])
        .sheet(isPresented: self.$showSaveForm) {
            SpotSaveFormView(mapItem: self.mapItem)
        }
    }
    
    // MARK: - Constants
    
    private struct Constants {
        static let markerSheetSpacing: CGFloat = 16
        static let markerSheetDetentHeight: PresentationDetent = .height(185)
    }
}

#Preview {
    MarkerSheetView(mapItem: .init())
}

extension CLLocationCoordinate2D {
    var description: String? {
        let formatter = NumberFormatter()
            formatter.maximumFractionDigits = 4
            formatter.numberStyle = .decimal
        
        guard let latitudeString = formatter.string(from: self.latitude as NSNumber),
              let longitudeString = formatter.string(from: self.longitude as NSNumber) else { return nil }
        
        return "\(latitudeString)°, \(longitudeString)°"
    }
}
