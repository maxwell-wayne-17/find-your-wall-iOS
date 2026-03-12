//
// Created for SwiftData-Camera-Photo
// by  Stewart Lynch on 2024-03-17
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
// ('me' refers to Stewart Lynch)


import SwiftUI
import PhotosUI


@Observable
class ImagePicker {
    
    var image: Image?
    var images: [Image] = []
  
    var vm: SpotSaveFormViewModel?
    
    func setup(_ vm: SpotSaveFormViewModel) {
        self.vm = vm
    }
    var imageSelection: PhotosPickerItem? {
        didSet {
            if let imageSelection {
                Task {
                    try await loadTransferable(from: imageSelection)
                }
            }
        }
    }
    
    @MainActor
    func loadTransferable(from imageSelection: PhotosPickerItem?) async throws {
        do {
            if let data = try await imageSelection?.loadTransferable(type: Data.self) {
                vm?.imageData = data
                if let uiImage = UIImage(data: data) {
                    self.image = Image(uiImage: uiImage)
                }
            }
        } catch {
            print(error.localizedDescription)
            image = nil
        }
    }
}
