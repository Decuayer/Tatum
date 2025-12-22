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
    
    // Galeriden seçilen item'ı UIImage'a çevirir
    func loadImage() async {
        guard let item = selectedItem else { return }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        
        await MainActor.run {
            self.selectedImage = uiImage
        }
    }
    
    // Postu Yükle
    func uploadDevPost() {
        guard let image = selectedImage else {
            uploadStatusMessage = "Lütfen önce bir resim seç."
            return
        }
        
        isUploading = true
        uploadStatusMessage = "Yükleniyor..."
        
        // Rastgele bir açıklama oluştur
        let randomCaptions = ["Harika bir dövme çalışması!", "Yeni tasarımım.", "Minimalist art.", "Tatum ile sanat.", "Blackwork style."]
        let caption = randomCaptions.randomElement() ?? "My cool tattoo"
        
        PostService.uploadPost(caption: caption, image: image) { success in
            DispatchQueue.main.async {
                self.isUploading = false
                if success {
                    self.uploadStatusMessage = "✅ Başarılı! Post yüklendi."
                    self.selectedImage = nil // Resmi temizle
                } else {
                    self.uploadStatusMessage = "❌ Hata oluştu."
                }
            }
        }
    }
}
