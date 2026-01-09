//
//  LocalWallBallSpotSheetView.swift
//  FindYourWall
//
//  Created by Max Wayne on 1/8/26.
//

import SwiftUI
import SwiftData

struct LocalWallBallSpotSheetView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let spot: LocalWallBallSpot
    
    var body: some View {
        VStack(spacing: Constants.vstackSpacing) {
            
            Spacer()
            
            Text(spot.name)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top])
            
            Text(spot.address?.shortAddress ?? "\(spot.coordinate.cLCoordinate)")
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            HStack {
                Button {
                    // TODO: Edit with spot save form
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
        .padding()
        .presentationDetents([Constants.detents])
    }
    
    private func deleteSpot() {
        self.modelContext.delete(self.spot)
    }
    
    private struct Constants {
        static let vstackSpacing: CGFloat = 16
        static let detents: PresentationDetent = .height(200)
    }
}

#Preview {
    SheetPreviewHost(content: LocalWallBallSpotSheetView(spot: .init(name: "Name",
                                                                     coordinate: .init(from: .empowerStadium),
                                                                     address: .init(shortAddress: "1234 Address St."))))
}
