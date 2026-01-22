//
//  DevPostViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//


import SwiftUI
import PhotosUI
import Combine

class DevPostViewModel: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { await loadImage() } }
    }
    @Published var selectedImage: UIImage?
    @Published var isUploading = false
    @Published var uploadStatusMessage = ""
    
    // Load selected photo from gallery and convert to UIImage
    func loadImage() async {
        guard let item = selectedItem else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        
        await MainActor.run {
            self.selectedImage = uiImage
        }
    }
    
    // Upload the post
    func uploadDevPost() {
        guard let image = selectedImage else {
            uploadStatusMessage = "Please select an image first."
            return
        }
        
        isUploading = true
        uploadStatusMessage = "Uploading..."
        
        // Generate random caption
        let randomCaptions = ["Amazing tattoo work!", "My new design.", "Minimalist art.", "Art with Tatum.", "Blackwork style."]
        let caption = randomCaptions.randomElement() ?? "My cool tattoo"
        
        PostService.uploadPost(caption: caption, image: image) { success in
            DispatchQueue.main.async {
                self.isUploading = false
                if success {
                    self.uploadStatusMessage = "✅ Success! Post uploaded."
                    self.selectedImage = nil
                } else {
                    self.uploadStatusMessage = "❌ Error occurred."
                }
            }
        }
    }
}
