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
    @State private var showImagePreview = false
    
    let spot: LocalWallBallSpot
    
    var body: some View {
        VStack(spacing: Constants.vstackSpacing) {
            
            Text(spot.name)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top])
            
            Text(spot.address ?? "\(spot.cLCoordinate)")
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            if let note = spot.note, !note.isEmpty {
                ScrollView {
                    Text(note)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: false)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            }
            
            Spacer()

            if let data = spot.imageData, let uiImage = UIImage(data: data) {
                Button { showImagePreview = true } label: {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .clipped()
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle()) // This is required, otherwise the tappable area includes the portion of the image that got clipped.
            }
            

            VStack(spacing: Constants.buttonVstackSpacing) {
                Button {
                    self.openInMaps()
                } label: {
                    Text("GO ➡️")
                }
                .buttonStyle(.primaryAction(.green))
                
                HStack {
                    
                    Button {
                        self.deleteSpot()
                        self.dismiss()
                    } label: {
                        Text("Delete")
                    }
                    .buttonStyle(.primaryAction(.red))
                    
                    Button {
                        self.showSaveForm = true
                    } label: {
                        Text("Edit")
                    }
                    .buttonStyle(.primaryAction())
                }
            }
        }
        .padding()
        .padding([.top], Constants.vstackSpacing)
        .presentationDetents([self.getDetents()])
        .sheet(isPresented: self.$showSaveForm) {
            SpotSaveFormView(viewModel: .init(spot: self.spot))
        }
        .fullScreenCover(isPresented: $showImagePreview) {
            if let data = spot.imageData, let uiImage = UIImage(data: data) {
                ImagePreviewView(uiImage: uiImage)
            }
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
    
    private func getDetents() -> PresentationDetent {
        if spot.imageData != nil { return .large }
        if !(spot.note ?? "").isEmpty { return Constants.detentsWithNote }
        return Constants.detentsWithoutNoteOrImage
    }

    private struct Constants {
        static let vstackSpacing: CGFloat = 16
        static let buttonVstackSpacing: CGFloat = -20
        static let detentsWithoutNoteOrImage: PresentationDetent = .height(260)
        static let detentsWithNote: PresentationDetent = .height(500)
    }
}

#Preview {
    SheetPreviewHost(content: LocalWallBallSpotSheetView(spot: .init(name: "Name",
                                                                     latitude: 123,
                                                                     longitude: 456,
                                                                     address: "123 Street St",
                                                                     note: "Show up to the building and turn left. Use the wall on the right.")))
}
