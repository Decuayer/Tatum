import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol ProfileServiceProtocol {
    func fetchUserPosts(uid: String, completion: @escaping ([Post]) -> Void)
    func fetchLikedPosts(uid: String, completion: @escaping ([Post]) -> Void)
    func fetchFollowers(uid: String, completion: @escaping ([TatumUser]) -> Void)
    func fetchFollowing(uid: String, completion: @escaping ([TatumUser]) -> Void)
    
    func follow(uid: String, completion: @escaping (Error?) -> Void)
    func unfollow(uid: String, completion: @escaping (Error?) -> Void)
    func checkIfUserIsFollowed(uid: String, completion: @escaping (Bool) -> Void)
    func removeFollower(uid: String, completion: @escaping (Error?) -> Void)
}

class ProfileService: ProfileServiceProtocol {
    
    // MARK: - ACTIONS (SADELEŞTİRİLMİŞ)
    
    func follow(uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Sadece ilişki dokümanlarını oluşturuyoruz. Sayaç güncellemek yok!
        let followingRef = db.collection("users").document(currentUid).collection("user-following").document(uid)
        let followersRef = db.collection("users").document(uid).collection("user-followers").document(currentUid)
        
        batch.setData([:], forDocument: followingRef)
        batch.setData([:], forDocument: followersRef)
        
        batch.commit(completion: completion)
    }
    
    func unfollow(uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Sadece dokümanları siliyoruz.
        let followingRef = db.collection("users").document(currentUid).collection("user-following").document(uid)
        let followersRef = db.collection("users").document(uid).collection("user-followers").document(currentUid)
        
        batch.deleteDocument(followingRef)
        batch.deleteDocument(followersRef)
        
        batch.commit(completion: completion)
    }
    
    func removeFollower(uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Benim takipçimden, onun takip ettiklerinden sil.
        let myFollowerRef = db.collection("users").document(currentUid).collection("user-followers").document(uid)
        let hisFollowingRef = db.collection("users").document(uid).collection("user-following").document(currentUid)
        
        batch.deleteDocument(myFollowerRef)
        batch.deleteDocument(hisFollowingRef)
        
        batch.commit(completion: completion)
    }
    
    // MARK: - DATA FETCHING (REVİZE EDİLMİŞ)
    
    // Bir ID listesi (ids) geldiğinde User detaylarını çekerken, o userların da sayaçlarını çekmemiz lazım!
    // Bu kısım çok önemli. Yoksa listede herkesin takipçisi 0 görünür.
    func fetchUsersWithCounts(ids: [String], completion: @escaping ([TatumUser]) -> Void) {
        guard !ids.isEmpty else { completion([]); return }
        
        let db = Firestore.firestore()
        var users: [TatumUser] = []
        let group = DispatchGroup()
        
        for uid in ids {
            group.enter()
            
            // 1. User Verisi
            let userRef = db.collection("users").document(uid)
            userRef.getDocument { snapshot, _ in
                if let data = snapshot?.data() {
                    var user = TatumUser(data: data)
                    
                    // 2. İçerde tekrar Group (Sayaçlar için)
                    let countGroup = DispatchGroup()
                    
                    countGroup.enter()
                    userRef.collection("user-followers").count.getAggregation(source: .server) { snap, _ in
                        user.followersCount = Int(truncating: snap?.count ?? 0)
                        countGroup.leave()
                    }
                    
                    countGroup.enter()
                    userRef.collection("user-following").count.getAggregation(source: .server) { snap, _ in
                        user.followingCount = Int(truncating: snap?.count ?? 0)
                        countGroup.leave()
                    }
                    
                    // Sayaçlar bitince ana gruba haber ver
                    countGroup.notify(queue: .global()) {
                        users.append(user)
                        group.leave()
                    }
                } else {
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(users)
        }
    }
    
    // fetchFollowers ve fetchFollowing artık 'fetchUsersWithCounts' kullanmalı
    func fetchFollowers(uid: String, completion: @escaping ([TatumUser]) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("user-followers").getDocuments { snapshot, _ in
            let ids = snapshot?.documents.map { $0.documentID } ?? []
            self.fetchUsersWithCounts(ids: ids, completion: completion)
        }
    }
    
    func fetchFollowing(uid: String, completion: @escaping ([TatumUser]) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("user-following").getDocuments { snapshot, _ in
            let ids = snapshot?.documents.map { $0.documentID } ?? []
            self.fetchUsersWithCounts(ids: ids, completion: completion)
        }
    }
    
    // Diğerleri aynı...
    func fetchAllUsers(completion: @escaping ([TatumUser]) -> Void) {
        Firestore.firestore().collection("users").getDocuments { snapshot, _ in
            let ids = snapshot?.documents.map { $0.documentID } ?? []
            self.fetchUsersWithCounts(ids: ids, completion: completion)
        }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { completion(false); return }
        Firestore.firestore().collection("users").document(currentUid).collection("user-following").document(uid).getDocument { snap, _ in
            completion(snap?.exists ?? false)
        }
    }
    
    // Gereksizler
    func fetchUserPosts(uid: String, completion: @escaping ([Post]) -> Void) { completion([]) }
    func fetchLikedPosts(uid: String, completion: @escaping ([Post]) -> Void) { completion([]) }
    func deleteUserFromFirestore(uid: String, completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("users").document(uid).delete(completion: completion)
    }
}
