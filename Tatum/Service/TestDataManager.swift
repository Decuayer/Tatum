//
//  TestDataManager.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

#if DEBUG
import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Test data manager for development/testing only
/// WARNING: This class should NEVER be available in production builds
class TestDataManager {
    static let shared = TestDataManager()
    
    func createTestUsers(completion: @escaping (String, Int, Int) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion("Error: No logged in user.", 0, 0)
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        let artistId = "test_artist_01"
        let memberId = "test_member_01"
        
        let group = DispatchGroup()
        
        var shouldAddAtlasAsFollower = false
        var shouldAddSelinAsFollower = false
        
        group.enter()
        db.collection("users").document(currentUid).collection("user-followers").document(artistId).getDocument { snapshot, _ in
            if let snapshot = snapshot, !snapshot.exists {
                shouldAddAtlasAsFollower = true
            }
            group.leave()
        }
        
        group.enter()
        db.collection("users").document(currentUid).collection("user-followers").document(memberId).getDocument { snapshot, _ in
            if let snapshot = snapshot, !snapshot.exists {
                shouldAddSelinAsFollower = true
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            
            
            let artistRef = db.collection("users").document(artistId)
            let artistData: [String: Any] = [
                "uid": artistId,
                "username": "atlas_tattoo",
                "fullName": "Atlas Tattoo Studio",
                "email": "atlas@test.com",
                "role": "artist",
                "bio": "Professional minimal tattoo studio. Kadıköy.",
                "website": "www.atlastattoo.com",
                "phoneNumber": "+90 532 000 00 00",
                "profileImageUrl": "https://mir-s3-cdn-cf.behance.net/project_modules/max_1200_webp/d6dfcb29775387.5602fe2490841.jpg"
            ]
            batch.setData(artistData, forDocument: artistRef)
            
            let memberRef = db.collection("users").document(memberId)
            let memberData: [String: Any] = [
                "uid": memberId,
                "username": "selin_yilmaz",
                "fullName": "Selin Yılmaz",
                "email": "selin@test.com",
                "role": "member",
                "bio": "Tattoo enthusiast.",
                "profileImageUrl": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80"
            ]
            batch.setData(memberData, forDocument: memberRef)
            
            
            if shouldAddAtlasAsFollower {
                let myFollowerRef = db.collection("users").document(currentUid).collection("user-followers").document(artistId)
                batch.setData([:], forDocument: myFollowerRef)
                
                let atlasFollowingRef = db.collection("users").document(artistId).collection("user-following").document(currentUid)
                batch.setData([:], forDocument: atlasFollowingRef)
            }
            
            if shouldAddSelinAsFollower {
                let myFollowerRef = db.collection("users").document(currentUid).collection("user-followers").document(memberId)
                batch.setData([:], forDocument: myFollowerRef)
                
                let selinFollowingRef = db.collection("users").document(memberId).collection("user-following").document(currentUid)
                batch.setData([:], forDocument: selinFollowingRef)
            }
            
            batch.commit { error in
                if let error = error {
                    completion("Error: \(error.localizedDescription)", 0, 0)
                } else {
                    var message = "Test Data Updated."
                    var addedFollowersCount = 0
                    
                    if shouldAddAtlasAsFollower {
                        message += " Atlas followed."
                        addedFollowersCount += 1
                    }
                    if shouldAddSelinAsFollower {
                        message += " Selin followed."
                        addedFollowersCount += 1
                    }
                    
                    if !shouldAddAtlasAsFollower && !shouldAddSelinAsFollower {
                        message += " (Already followers)"
                    }
                    
                    completion(message, addedFollowersCount, 0)
                }
            }
        }
    }
}
#endif
