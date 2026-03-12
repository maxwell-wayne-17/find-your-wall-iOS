//
//  SpotSaveFormView.swift
//  FindYourWall
//
//  Created by Max Wayne on 12/31/25.
//

import SwiftUI
import MapKit
import SwiftData
import PhotosUI

struct SpotSaveFormView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable private var viewModel: SpotSaveFormViewModel
    
    private enum FocusedField {
        case name, address, note
    }
    @FocusState private var focusedField: FocusedField?
    
    @State private var imagePicker = ImagePicker()
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showImageSourceSheet = false
    @State private var cameraError: CameraPermission.CameraError?
    @State private var selectedImage: UIImage?
    
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
                            
                            PhotosPicker(selection: self.$imagePicker.imageSelection) {
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
                                self.imagePicker.imageSelection = nil
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
            .onAppear {
                imagePicker.setup(self.viewModel)
            }
            .onChange(of: self.selectedImage) {
                if let image = self.selectedImage {
                    self.viewModel.imageData = image.jpegData(compressionQuality: Constants.compressionQuality)
                }
            }
        }
    }
    
    private func saveWallBallSpot() {
        let noteValue: String? = self.viewModel.note.isEmpty ? nil : self.viewModel.note
        if let spot = self.viewModel.existingSpot {
            spot.name = self.viewModel.name
            spot.address = self.viewModel.address
            spot.note = noteValue
            spot.imageData = self.viewModel.imageData
        } else {
            let spot = LocalWallBallSpot(name: self.viewModel.name,
                                         latitude: self.viewModel.coordinate.latitude,
                                         longitude: self.viewModel.coordinate.longitude,
                                         address: self.viewModel.address,
                                         note: noteValue,
                                         imageData: self.viewModel.imageData)
            self.modelContext.insert(spot)
        }
    }
    
    private struct Constants {
        static let keyboardDismissIcon = "keyboard.chevron.compact.down"
        static let compressionQuality = 0.8
    }
}


#Preview {
    let viewModel = SpotSaveFormViewModel(mapItem: MKMapItem(location: .init(latitude: 123, longitude: 456), address: nil))
    SpotSaveFormView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}
