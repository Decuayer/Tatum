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
    
    // MARK: - LIST FETCHING (GÜNCELLENEN KISIM)
    
    // Takipçileri Getir (Followers)
    func fetchFollowers(uid: String, completion: @escaping ([TatumUser]) -> Void) {
        // 1. 'user-followers' koleksiyonundaki ID'leri çek
        Firestore.firestore().collection("users").document(uid).collection("user-followers").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                completion([])
                return
            }
            
            // Dokümanların ID'si = Kullanıcı ID'si
            let userIds = documents.map { $0.documentID }
            
            // 2. Bu ID'lerin detaylarını çek
            self.fetchUsers(ids: userIds, completion: completion)
        }
    }
    
    // Takip Edilenleri Getir (Following)
    func fetchFollowing(uid: String, completion: @escaping ([TatumUser]) -> Void) {
        // 1. 'user-following' koleksiyonundaki ID'leri çek
        Firestore.firestore().collection("users").document(uid).collection("user-following").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                completion([])
                return
            }
            
            let userIds = documents.map { $0.documentID }
            
            // 2. Bu ID'lerin detaylarını çek
            self.fetchUsers(ids: userIds, completion: completion)
        }
    }
    
    // YARDIMCI FONKSİYON: ID Listesinden User Objelerini Getirir
    private func fetchUsers(ids: [String], completion: @escaping ([TatumUser]) -> Void) {
        guard !ids.isEmpty else {
            completion([])
            return
        }
        
        var users: [TatumUser] = []
        let group = DispatchGroup() // Asenkron işlemleri beklemek için
        
        for uid in ids {
            group.enter()
            
            // AuthService içindeki fetchUser mantığının aynısını buraya entegre ediyoruz
            Firestore.firestore().collection("users").document(uid).getDocument { snapshot, _ in
                if let data = snapshot?.data() {
                    let user = TatumUser(
                        id: data["uid"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        fullName: data["fullName"] as? String ?? "",
                        profileImageUrl: data["profileImageUrl"] as? String,
                        role: data["role"] as? String ?? "member",
                        bio: data["bio"] as? String,
                        website: data["website"] as? String,
                        phoneNumber: data["phoneNumber"] as? String,
                        followersCount: data["followersCount"] as? Int ?? 0,
                        followingCount: data["followingCount"] as? Int ?? 0
                    )
                    users.append(user)
                }
                group.leave()
            }
        }
        
        // Tüm çekme işlemleri bitince listeyi döndür
        group.notify(queue: .main) {
            completion(users)
        }
    }
    
    // MARK: - ACTIONS (AYNI KALDI)
    
    func follow(uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(currentUid).collection("user-following").document(uid).setData([:]) { error in
            if let error = error { completion(error); return }
            
            Firestore.firestore().collection("users").document(uid).collection("user-followers").document(currentUid).setData([:]) { error in
                if let error = error { completion(error); return }
                completion(nil)
            }
        }
    }
    
    func unfollow(uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(currentUid).collection("user-following").document(uid).delete { error in
            if let error = error { completion(error); return }
            
            Firestore.firestore().collection("users").document(uid).collection("user-followers").document(currentUid).delete { error in
                completion(error)
            }
        }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
            guard let snapshot = snapshot else { completion(false); return }
            completion(snapshot.exists)
        }
    }
    
    func removeFollower(uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // 1. Benim 'user-followers' listemden onu sil
        Firestore.firestore().collection("users").document(currentUid).collection("user-followers").document(uid).delete { error in
            if let error = error { completion(error); return }
            
            // 2. Onun 'user-following' listesinden beni sil
            Firestore.firestore().collection("users").document(uid).collection("user-following").document(currentUid).delete { error in
                completion(error)
            }
        }
    }
    
    // MARK: - POST FETCHING (MOCK HALİYLE KALABİLİR ŞİMDİLİK)
    func fetchUserPosts(uid: String, completion: @escaping ([Post]) -> Void) { completion([]) }
    func fetchLikedPosts(uid: String, completion: @escaping ([Post]) -> Void) { completion([]) }
}
