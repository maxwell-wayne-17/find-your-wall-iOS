//
//  MarkerSheetView.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/3/25.
//

import MapKit
import SwiftUI

struct MarkerSheetView: View {
    
    let mapItem: MKMapItem
    
    var body: some View {
        VStack(spacing: Constants.markerSheetSpacing) {
            Spacer()
            
            Text(self.mapItem.name ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top])
            
            Text(self.mapItem.addressRepresentations?.fullAddress(includingRegion: false, singleLine: true) ?? "")
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // TODO: Eventually we will be able to save locations
            Button(action: {
                print("Sheet button tapped")
            }) {
                Text("Save")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)

            }
        }
        .padding()
        .presentationDetents([Constants.markerSheetDetentHeight])
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
