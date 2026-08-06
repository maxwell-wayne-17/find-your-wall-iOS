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
    @ScaledMetric(relativeTo: .body) private var noteMinHeight: CGFloat = Constants.noteBaseMinHeight
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
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .scrollBounceBehavior(.basedOnSize)
                .padding(Constants.notePadding)
                .frame(maxWidth: .infinity)
                // Note: The note claims its space before the image and the Spacers,
                // otherwise the image's bounded height wins and the note gets squeezed to a sliver.
                .frame(minHeight: self.noteMinHeight, maxHeight: Constants.noteMaxHeight)
                .layoutPriority(Constants.notePriority)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: Constants.cornerRadius))
            }

            Spacer()

            if let data = viewModel.spot.imageData, let uiImage = UIImage(data: data) {
                Button { viewModel.showImagePreview = true } label: {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: Constants.imageMaxHeight)
                        .clipped()
                        .clipShape(.rect(cornerRadius: Constants.cornerRadius))
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
                        .disabled(self.viewModel.isDeleting)

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
        .overlay {
            if self.viewModel.isDeleting {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
        }
        .presentationDetents([self.getDetents(), .large])
        .sheet(isPresented: self.$viewModel.showSaveForm,
               onDismiss: { self.dismiss() }) {
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
        if self.viewModel.spot.isOwnedByCurrentUser { return Constants.detentsOwnedWithoutNoteOrImage }
        return Constants.detentsNotOwnedWithoutNoteOrImage
    }
    
    private struct Constants {
        static let vstackSpacing: CGFloat = 16
        static let buttonVstackSpacing: CGFloat = -20
        static let cornerRadius: CGFloat = 8
        static let notePadding: CGFloat = 10
        static let noteBaseMinHeight: CGFloat = 86
        static let noteMaxHeight: CGFloat = 200
        static let notePriority: Double = 1
        static let imageMaxHeight: CGFloat = 300
        static let detentsNotOwnedWithoutNoteOrImage: PresentationDetent = .height(230)
        static let detentsOwnedWithoutNoteOrImage: PresentationDetent = .height(290)
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
