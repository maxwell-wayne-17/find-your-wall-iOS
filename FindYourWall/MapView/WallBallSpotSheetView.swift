//
//  WallBallSpotSheetView.swift
//  FindYourWall
//
//  Created by Max Wayne on 1/8/26.
//

import SwiftUI
import MapKit

struct WallBallSpotSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: WallBallSpotSheetViewModel

    init(spot: WallBallSpot, spotService: SpotService, hiddenSpotsStore: HiddenSpotsStore = .init()) {
        self._viewModel = State(wrappedValue: WallBallSpotSheetViewModel(spot: spot,
                                                                          spotService: spotService,
                                                                          hiddenSpotsStore: hiddenSpotsStore))
    }

    var body: some View {
        VStack(spacing: Constants.vstackSpacing) {

            HStack() {
                Text(viewModel.spot.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !self.viewModel.spot.isOwnedByCurrentUser {
                    
                    Spacer()
                    
                    Button {
                        self.viewModel.hideSpot()
                    } label: {
                        Label("Hide", systemImage: "eye.slash")
                    }
                }
            }
            .padding([.top])

            Text(viewModel.spot.address ?? "\(viewModel.spot.cLCoordinate)")
                .font(.body)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            if let note = viewModel.spot.note, !note.isEmpty {
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

            if let data = viewModel.spot.imageData, let uiImage = UIImage(data: data) {
                Button { viewModel.showImagePreview = true } label: {
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
            
            Spacer()

            VStack(spacing: Constants.buttonVstackSpacing) {

                if viewModel.spot.isOwnedByCurrentUser {
                    HStack {

                        Button {
                            Task { await self.viewModel.deleteSpot() }
                        } label: {
                            Text("Delete")
                        }
                        .buttonStyle(.primaryAction(.red))

                        Button {
                            self.viewModel.showSaveForm = true
                        } label: {
                            Text("Edit")
                        }
                        .buttonStyle(.primaryAction())
                    }
                }

                Button {
                    self.viewModel.openInMaps()
                } label: {
                    Text("GO ➡️")
                }
                .buttonStyle(.primaryAction(.green))
            }
        }
        .padding()
        .padding([.top], Constants.vstackSpacing)
        .presentationDetents([self.getDetents()])
        .sheet(isPresented: self.$viewModel.showSaveForm) {
            SpotSaveFormView(viewModel: .init(spot: self.viewModel.spot, spotService: self.viewModel.spotService))
        }
        .fullScreenCover(isPresented: $viewModel.showImagePreview) {
            if let data = viewModel.spot.imageData, let uiImage = UIImage(data: data) {
                ImagePreviewView(uiImage: uiImage)
            }
        }
        .onChange(of: self.viewModel.didDelete) {
            if self.viewModel.didDelete { self.dismiss() }
        }
        .onChange(of: self.viewModel.didHide) {
            if self.viewModel.didHide { self.dismiss() }
        }
        .alert("Error", isPresented: Binding(
            get: { self.viewModel.errorMessage != nil },
            set: { if !$0 { self.viewModel.errorMessage = nil } }
        )) {
            Button("OK") { self.viewModel.errorMessage = nil }
        } message: {
            Text(self.viewModel.errorMessage ?? "")
        }
    }

    private func getDetents() -> PresentationDetent {
        let hasNote = !(self.viewModel.spot.note ?? "").isEmpty
        let hasImage = self.viewModel.spot.imageData != nil
        if hasNote && hasImage { return .large }
        if hasNote && !hasImage { return Constants.detentsWithOnlyNote }
        if !hasNote && hasImage { return Constants.detentsWithOnlyImage }
        return Constants.detentsWithoutNoteOrImage
    }
    
    private struct Constants {
        static let vstackSpacing: CGFloat = 16
        static let buttonVstackSpacing: CGFloat = -20
        static let detentsWithoutNoteOrImage: PresentationDetent = .height(260)
        static let detentsWithOnlyNote: PresentationDetent = .height(500)
        static let detentsWithOnlyImage: PresentationDetent = .height(600)
    }
}

#Preview {
    SheetPreviewHost(content: WallBallSpotSheetView(spot: .init(name: "Name",
                                                                     latitude: 123,
                                                                     longitude: 456,
                                                                     address: "123 Street St",
                                                                     note: "Show up to the building and turn left. Use the wall on the right."),
                                                    spotService: CloudKitSpotService()))
}
