//
//  ImageUploader.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import UIKit
import FirebaseStorage

struct ImageUploader {
    
    /// Uploads an image to Firebase Storage and returns the download URL
    /// - Parameters:
    ///   - image: The UIImage to upload
    ///   - folder: Storage folder name (e.g., "post_images", "profile_images")
    ///   - maxDimension: Maximum width or height in pixels (default: 1920)
    ///   - compressionQuality: JPEG compression quality 0.0-1.0 (default: 0.8)
    ///   - completion: Returns URL string on success, Error on failure
    static func uploadImage(
        image: UIImage,
        folder: String,
        maxDimension: CGFloat = 1920,
        compressionQuality: CGFloat = 0.8,
        completion: @escaping(String?, Error?) -> Void
    ) {
        // 1. Resize image to prevent massive uploads
        let resizedImage = image.resized(toMaxDimension: maxDimension)
        
        // 2. Convert to JPEG data with compression
        guard let imageData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
            let error = NSError(
                domain: "ImageUploader",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data."]
            )
            print("DEBUG: Image conversion failed")
            completion(nil, error)
            return
        }
        
        // 3. Validate file size (10MB limit)
        let maxSizeInBytes = 10 * 1024 * 1024 // 10MB
        guard imageData.count <= maxSizeInBytes else {
            let error = NSError(
                domain: "ImageUploader",
                code: 1002,
                userInfo: [NSLocalizedDescriptionKey: "Image size exceeds 10MB limit. Please use a smaller image."]
            )
            print("DEBUG: Image too large - \(imageData.count) bytes")
            completion(nil, error)
            return
        }
        
        // 4. Create unique filename
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/\(folder)/\(filename)")
        
        // 5. Set metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 6. Upload image
        print("DEBUG: Uploading image to \(folder)/\(filename) (\(imageData.count) bytes)")
        ref.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("DEBUG: Image upload failed - \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            // 7. Retrieve download URL
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: Failed to get download URL - \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                guard let imageUrl = url?.absoluteString else {
                    let error = NSError(
                        domain: "ImageUploader",
                        code: 1003,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve image URL."]
                    )
                    print("DEBUG: Download URL is nil")
                    completion(nil, error)
                    return
                }
                
                print("DEBUG: Image uploaded successfully - \(imageUrl)")
                completion(imageUrl, nil)
            }
        }
    }
}

// MARK: - UIImage Extension

extension UIImage {
    /// Resize image to fit within maxDimension while maintaining aspect ratio
    func resized(toMaxDimension maxDimension: CGFloat) -> UIImage {
        let currentMaxDimension = max(size.width, size.height)
        
        // If image is already smaller than max, return original
        guard currentMaxDimension > maxDimension else {
            return self
        }
        
        let scale = maxDimension / currentMaxDimension
        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
