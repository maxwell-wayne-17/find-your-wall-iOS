//
//  SpotSaveFormView.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/31/25.
//

import SwiftUI
import MapKit
import PhotosUI

struct SpotSaveFormView: View {

    @Environment(\.dismiss) private var dismiss

    @Bindable private var viewModel: SpotSaveFormViewModel

    private let spotService: SpotService
    private var onSave: () async -> Void

    private enum FocusedField {
        case name, address, note
    }
    @FocusState private var focusedField: FocusedField?

    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showImageSourceSheet = false
    @State private var cameraError: CameraPermission.CameraError?
    @State private var selectedImage: UIImage?
    @State private var isSaving = false

    init(viewModel: SpotSaveFormViewModel, spotService: SpotService, onSave: @escaping () async -> Void) {
        self.viewModel = viewModel
        self.spotService = spotService
        self.onSave = onSave
    }

    var body: some View {

        NavigationView {
            Form {
                Section {
                    TextField("Name (Required)", text: self.$viewModel.name)
                        .focused(self.$focusedField, equals: .name)
                }

                Section(header: Text("Address (Optional)")) {
                    TextEditor(text: self.$viewModel.address)
                        .focused(self.$focusedField, equals: .address)
                        .frame(minHeight: 35)
                }

                Section(header: Text("Note (Optional)")) {
                    TextEditor(text: self.$viewModel.note)
                        .focused(self.$focusedField, equals: .note)
                        .frame(minHeight: 60)
                }

                Section(header: Text("Image (Optional)")) {
                    if let data = self.viewModel.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipped()
                            .listRowInsets(EdgeInsets())
                            .onTapGesture { self.showImageSourceSheet = true }
                    } else {
                        HStack(alignment: .center) {

                            Button("Camera", systemImage: "camera") {
                                if let error = CameraPermission.checkPermissions() {
                                    self.cameraError = error
                                } else {
                                    showCamera.toggle()
                                }
                            }
                            .alert(isPresented: .constant(self.cameraError != nil),
                                   error: self.cameraError) { _ in
                                Button("OK") {
                                    self.cameraError = nil
                                }
                            } message: { error in
                                Text(error.recoverySuggestion ?? "Try again later")
                            }
                            .sheet(isPresented: self.$showCamera) {
                                UIKitCamera(selectedImage: self.$selectedImage)
                                    .ignoresSafeArea()
                            }

                            Spacer()

                            PhotosPicker(selection: self.$photosPickerItem) {
                                Label("Photos", systemImage: "photo")
                            }
                            // Note: without this modifier, the Section view merges both buttons into a single tappable area for the section, so tapping one button automatically taps both at the same time.
                            .buttonStyle(.borderless)
                        }
                    }

                    if let data = self.viewModel.imageData, let _ = UIImage(data: data) {
                        HStack {
                            Spacer()
                            Button("Clear Image") {
                                self.viewModel.clearImage()
                                self.photosPickerItem = nil
                            }
                            Spacer()
                        }
                    }
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

                    Button("Save") {
                        if self.viewModel.isFormValid {
                            self.saveWallBallSpot()
                        }
                    }
                    .disabled(!self.viewModel.isFormValid || self.focusedField != nil || self.isSaving)
                    .buttonStyle(.primaryAction())
                }
                // Ignoring the keyboard overlay wasn't working,
                // so worked around by making button invisible when text fields are in focus
                .opacity(self.focusedField != nil ? 0 : 1)
            }
            .onChange(of: self.photosPickerItem) {
                Task {
                    if let data = try? await photosPickerItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        self.viewModel.imageData = uiImage.jpegData(compressionQuality: Constants.compressionQuality)
                    }
                }
            }
            .onChange(of: self.selectedImage) {
                if let image = self.selectedImage {
                    self.viewModel.imageData = image.jpegData(compressionQuality: Constants.compressionQuality)
                }
            }
        }
        .overlay {
            if self.isSaving {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
        }
    }

    private func saveWallBallSpot() {
        let noteValue: String? = self.viewModel.note.isEmpty ? nil : self.viewModel.note

        var spot: WallBallSpot
        if var existingSpot = self.viewModel.existingSpot {
            existingSpot.name = self.viewModel.name
            existingSpot.address = self.viewModel.address
            existingSpot.note = noteValue
            existingSpot.imageData = self.viewModel.imageData
            spot = existingSpot
        } else {
            spot = WallBallSpot(name: self.viewModel.name,
                                latitude: self.viewModel.coordinate.latitude,
                                longitude: self.viewModel.coordinate.longitude,
                                address: self.viewModel.address,
                                note: noteValue,
                                imageData: self.viewModel.imageData)
        }

        self.isSaving = true
        Task {
            do {
                let _ = try await self.spotService.saveSpot(spot)
                // TODO: The map is not displaying the spot on save. We should try to retrieve the individual record and add it to the map view model
                await self.onSave()
                await MainActor.run { self.dismiss() }
            } catch {
                print("CloudKit save failed: \(error)")
                await MainActor.run { self.isSaving = false }
            }
        }
    }

    private struct Constants {
        static let keyboardDismissIcon = "keyboard.chevron.compact.down"
        static let compressionQuality = 0.8
    }
}


#Preview {
    let viewModel = SpotSaveFormViewModel(mapItem: MKMapItem(location: .init(latitude: 123, longitude: 456), address: nil))
    SpotSaveFormView(viewModel: viewModel, spotService: CloudKitSpotService(), onSave: {})
        .preferredColorScheme(.dark)
}
