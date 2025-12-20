//
//  TestDataManager.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class TestDataManager {
    static let shared = TestDataManager()
    
    // Completion artık şu değerleri döndürüyor: (Mesaj, Eklenen Takipçi Sayısı, Eklenen Takip Edilen Sayısı)
    func createTestUsers(completion: @escaping (String, Int, Int) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion("Hata: Giriş yapmış kullanıcı yok.", 0, 0)
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Test ID'leri
        let artistId = "test_artist_01"
        let memberId = "test_member_01"
        
        // Senkronizasyon grubu (İki kontrolün bitmesini beklemek için)
        let group = DispatchGroup()
        
        var shouldAddFollowing = false
        var shouldAddFollower = false
        
        // 1. KONTROL: Atlas Tattoo'yu zaten takip ediyor muyum?
        group.enter()
        db.collection("users").document(currentUid).collection("user-following").document(artistId).getDocument { snapshot, _ in
            if let snapshot = snapshot, !snapshot.exists {
                shouldAddFollowing = true
            }
            group.leave()
        }
        
        // 2. KONTROL: Selin Yılmaz beni zaten takip ediyor mu?
        group.enter()
        db.collection("users").document(currentUid).collection("user-followers").document(memberId).getDocument { snapshot, _ in
            if let snapshot = snapshot, !snapshot.exists {
                shouldAddFollower = true
            }
            group.leave()
        }
        
        // Kontroller bitince Batch'i hazırla
        group.notify(queue: .main) {
            
            // --- HER ZAMAN: Test Kullanıcılarının Profil Verilerini Güncelle/Oluştur ---
            // (Veri modeli değişirse test verisi de güncellensin diye bunu hep yapıyoruz)
            
            // Atlas Tattoo (Sanatçı)
            let artistRef = db.collection("users").document(artistId)
            let artistData: [String: Any] = [
                "uid": artistId,
                "username": "atlas_tattoo",
                "fullName": "Atlas Tattoo Studio",
                "email": "atlas@test.com",
                "role": "artist",
                "bio": "Profesyonel minimal dövme stüdyosu. Kadıköy.",
                "followersCount": 1250,
                "followingCount": 45,
                "website": "www.atlastattoo.com",
                "phoneNumber": "+90 532 000 00 00",
                "profileImageUrl": "https://images.unsplash.com/photo-1598371839696-5c5bb62d49c0?auto=format&fit=crop&w=200&q=80"
            ]
            batch.setData(artistData, forDocument: artistRef)
            
            // Selin Yılmaz (Üye)
            let memberRef = db.collection("users").document(memberId)
            let memberData: [String: Any] = [
                "uid": memberId,
                "username": "selin_yilmaz",
                "fullName": "Selin Yılmaz",
                "email": "selin@test.com",
                "role": "member",
                "bio": "Dövme tutkunu.",
                "followersCount": 45,
                "followingCount": 120,
                "profileImageUrl": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80"
            ]
            batch.setData(memberData, forDocument: memberRef)
            
            // --- KOŞULLU: İlişkileri Ekle ---
            
            // Eğer Atlas takip edilmiyorsa ekle
            if shouldAddFollowing {
                let myFollowingRef = db.collection("users").document(currentUid).collection("user-following").document(artistId)
                batch.setData([:], forDocument: myFollowingRef)
                
                // Benim sayacımı artır
                let myRef = db.collection("users").document(currentUid)
                batch.updateData(["followingCount": FieldValue.increment(Int64(1))], forDocument: myRef)
            }
            
            // Eğer Selin takip etmiyorsa ekle
            if shouldAddFollower {
                let myFollowersRef = db.collection("users").document(currentUid).collection("user-followers").document(memberId)
                batch.setData([:], forDocument: myFollowersRef)
                
                // Benim sayacımı artır
                let myRef = db.collection("users").document(currentUid)
                batch.updateData(["followersCount": FieldValue.increment(Int64(1))], forDocument: myRef)
            }
            
            // Sadece değişiklik varsa commit et
            batch.commit { error in
                if let error = error {
                    completion("Hata: \(error.localizedDescription)", 0, 0)
                } else {
                    var message = "Test Verileri Güncellendi."
                    if shouldAddFollowing { message += " +1 Takip Edilen." }
                    if shouldAddFollower { message += " +1 Takipçi." }
                    if !shouldAddFollowing && !shouldAddFollower { message += " (Zaten Ekli)" }
                    
                    // Eklenen sayıları geri döndür
                    completion(message, shouldAddFollower ? 1 : 0, shouldAddFollowing ? 1 : 0)
                }
            }
        }
    }
}
