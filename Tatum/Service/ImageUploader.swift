//
//  ImageUploader.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import UIKit
import FirebaseStorage

struct ImageUploader {
    
    /// Bir resmi Firebase Storage'a yükler ve indirme URL'ini döndürür.
    /// - Parameters:
    ///   - image: Yüklenecek UIImage
    ///   - folder: Storage içindeki klasör adı (örn: "post_images", "profile_images")
    ///   - completion: Başarılı olursa String URL, hata olursa Error döner
    static func uploadImage(image: UIImage, folder: String, completion: @escaping(String?, Error?) -> Void) {
        
        // 1. Resmi veriye (Data) çevir ve sıkıştır (0.5 kalitesi idealdir)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(nil, NSError(domain: "ImageUploader", code: 0, userInfo: [NSLocalizedDescriptionKey: "Resim veriye dönüştürülemedi."]))
            return
        }
        
        // 2. Dosya ismini oluştur (Benzersiz olması için UUID kullanıyoruz)
        let filename = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/\(folder)/\(filename)")
        
        // 3. Yükleme işlemini başlat
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // 4. Yükleme bitti, URL'i al
            ref.downloadURL { url, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                completion(imageUrl, nil)
            }
        }
    }
}
