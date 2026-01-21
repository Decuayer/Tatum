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
    
    // MARK: - Actions
    
    func follow(uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("DEBUG: Cannot follow - no authenticated user")
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Create relationship documents only (counters are fetched via aggregation)
        let followingRef = db.collection("users").document(currentUid).collection("user-following").document(uid)
        let followersRef = db.collection("users").document(uid).collection("user-followers").document(currentUid)
        
        batch.setData([:], forDocument: followingRef)
        batch.setData([:], forDocument: followersRef)
        
        batch.commit { error in
            if let error = error {
                print("DEBUG: Follow failed - \(error.localizedDescription)")
            } else {
                print("DEBUG: Successfully followed user \(uid)")
            }
            completion(error)
        }
    }
    
    func unfollow(uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("DEBUG: Cannot unfollow - no authenticated user")
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Delete relationship documents
        let followingRef = db.collection("users").document(currentUid).collection("user-following").document(uid)
        let followersRef = db.collection("users").document(uid).collection("user-followers").document(currentUid)
        
        batch.deleteDocument(followingRef)
        batch.deleteDocument(followersRef)
        
        batch.commit { error in
            if let error = error {
                print("DEBUG: Unfollow failed - \(error.localizedDescription)")
            } else {
                print("DEBUG: Successfully unfoll owed user \(uid)")
            }
            completion(error)
        }
    }
    
    func removeFollower(uid: String, completion: @escaping (Error?) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            print("DEBUG: Cannot remove follower - no authenticated user")
            return
        }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        // Remove from my followers and their following
        let myFollowerRef = db.collection("users").document(currentUid).collection("user-followers").document(uid)
        let theirFollowingRef = db.collection("users").document(uid).collection("user-following").document(currentUid)
        
        batch.deleteDocument(myFollowerRef)
        batch.deleteDocument(theirFollowingRef)
        
        batch.commit { error in
            if let error = error {
                print("DEBUG: Remove follower failed - \(error.localizedDescription)")
            } else {
                print("DEBUG: Successfully removed follower \(uid)")
            }
            completion(error)
        }
    }
    
    // MARK: - Data Fetching
    
    /// Fetch multiple users with their follower/following counts
    /// Note: This still has N+1 query issue (1 + 2N queries for N users)
    /// TODO: Consider denormalizing counts to user document for better performance
    func fetchUsersWithCounts(ids: [String], completion: @escaping ([TatumUser]) -> Void) {
        guard !ids.isEmpty else {
            completion([])
            return
        }
        
        let db = Firestore.firestore()
        var users: [TatumUser] = []
        let group = DispatchGroup()
        
        print("DEBUG: Fetching \(ids.count) users with counts")
        
        for uid in ids {
            group.enter()
            
            // 1. Fetch user data
            let userRef = db.collection("users").document(uid)
            userRef.getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Failed to fetch user \(uid) - \(error.localizedDescription)")
                    group.leave()
                    return
                }
                
                if let data = snapshot?.data() {
                    var user = TatumUser(data: data)
                    
                    // 2. Fetch counts in parallel
                    let countGroup = DispatchGroup()
                    
                    countGroup.enter()
                    userRef.collection("user-followers").count.getAggregation(source: .server) { snap, error in
                        if let error = error {
                            print("DEBUG: Failed to fetch followers count for \(uid) - \(error.localizedDescription)")
                        } else {
                            user.followersCount = Int(truncating: snap?.count ?? 0)
                        }
                        countGroup.leave()
                    }
                    
                    countGroup.enter()
                    userRef.collection("user-following").count.getAggregation(source: .server) { snap, error in
                        if let error = error {
                            print("DEBUG: Failed to fetch following count for \(uid) - \(error.localizedDescription)")
                        } else {
                            user.followingCount = Int(truncating: snap?.count ?? 0)
                        }
                        countGroup.leave()
                    }
                    
                    // When counts are fetched, add user to results
                    countGroup.notify(queue: .global()) {
                        users.append(user)
                        group.leave()
                    }
                } else {
                    print("DEBUG: User \(uid) document does not exist")
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            print("DEBUG: Fetched \(users.count) users successfully")
            completion(users)
        }
    }
    
    func fetchFollowers(uid: String, completion: @escaping ([TatumUser]) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("user-followers").getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch followers list - \(error.localizedDescription)")
                completion([])
                return
            }
            let ids = snapshot?.documents.map { $0.documentID } ?? []
            self.fetchUsersWithCounts(ids: ids, completion: completion)
        }
    }
    
    func fetchFollowing(uid: String, completion: @escaping ([TatumUser]) -> Void) {
        Firestore.firestore().collection("users").document(uid).collection("user-following").getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch following list - \(error.localizedDescription)")
                completion([])
                return
            }
            let ids = snapshot?.documents.map { $0.documentID } ?? []
            self.fetchUsersWithCounts(ids: ids, completion: completion)
        }
    }
    
    func fetchAllUsers(completion: @escaping ([TatumUser]) -> Void) {
        Firestore.firestore().collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch all users - \(error.localizedDescription)")
                completion([])
                return
            }
            let ids = snapshot?.documents.map { $0.documentID } ?? []
            self.fetchUsersWithCounts(ids: ids, completion: completion)
        }
    }
    
    func checkIfUserIsFollowed(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        Firestore.firestore().collection("users").document(currentUid).collection("user-following").document(uid).getDocument { snap, error in
            if let error = error {
                print("DEBUG: Failed to check follow status - \(error.localizedDescription)")
                completion(false)
            } else {
                completion(snap?.exists ?? false)
            }
        }
    }
    
    // MARK: - Post Fetching
    
    func fetchUserPosts(uid: String, completion: @escaping ([Post]) -> Void) {
        print("DEBUG: Fetching posts for user \(uid)")
        Firestore.firestore().collection("posts")
            .whereField("ownerUid", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Failed to fetch posts - \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("DEBUG: No posts found for user \(uid)")
                    completion([])
                    return
                }
                
                let posts = documents.compactMap { doc -> Post? in
                    let data = doc.data()
                    return Post(
                        id: doc.documentID,
                        ownerUid: data["ownerUid"] as? String ?? "",
                        studioId: data["studioId"] as? String ?? "",
                        caption: data["caption"] as? String ?? "",
                        likes: data["likes"] as? Int ?? 0,
                        imageUrl: data["imageUrl"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        user: nil
                    )
                }
                
                print("DEBUG: Fetched \(posts.count) posts for user \(uid)")
                completion(posts)
            }
    }
    
    // MARK: - Liked Posts Fetching (OPTIMIZED)
    
    /// Fetch liked posts with improved batching to reduce N+1 queries
    func fetchLikedPosts(uid: String, completion: @escaping ([Post]) -> Void) {
        print("DEBUG: Fetching liked posts for user \(uid)")
        Firestore.firestore().collection("users").document(uid).collection("user-likes").getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch liked posts - \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("DEBUG: No liked posts found")
                completion([])
                return
            }
            
            let postIds = documents.map { $0.documentID }
            print("DEBUG: Fetching \(postIds.count) liked posts")
            
            // OPTIMIZATION: Batch fetch posts in chunks of 10 (Firestore 'in' query limit)
            self.batchFetchPosts(postIds: postIds, completion: completion)
        }
    }
    
    /// Helper method to batch fetch posts (reduces queries from N to N/10)
    private func batchFetchPosts(postIds: [String], completion: @escaping ([Post]) -> Void) {
        guard !postIds.isEmpty else {
            completion([])
            return
        }
        
        var allPosts: [Post] = []
        let group = DispatchGroup()
        
        // Split into chunks of 10 (Firestore 'in' query limitation)
        let chunks = stride(from: 0, to: postIds.count, by: 10).map {
            Array(postIds[$0..<min($0 + 10, postIds.count)])
        }
        
        print("DEBUG: Fetching posts in \(chunks.count) batches")
        
        for chunk in chunks {
            group.enter()
            Firestore.firestore().collection("posts")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("DEBUG: Batch fetch failed - \(error.localizedDescription)")
                    } else if let documents = snapshot?.documents {
                        let posts = documents.compactMap { doc -> Post? in
                            let data = doc.data()
                            return Post(
                                id: doc.documentID,
                                ownerUid: data["ownerUid"] as? String ?? "",
                                studioId: data["studioId"] as? String ?? "",
                                caption: data["caption"] as? String ?? "",
                                likes: data["likes"] as? Int ?? 0,
                                imageUrl: data["imageUrl"] as? String ?? "",
                                timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                                user: nil
                            )
                        }
                        allPosts.append(contentsOf: posts)
                    }
                    group.leave()
                }
        }
        
        group.notify(queue: .main) {
            // Sort by timestamp
            let sortedPosts = allPosts.sorted(by: { $0.timestamp > $1.timestamp })
            print("DEBUG: Fetched \(sortedPosts.count) liked posts successfully")
            completion(sortedPosts)
        }
    }
    
    /// Helper method to fetch a single user
    private func fetchUser(uid: String, completion: @escaping (TatumUser?) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch user - \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = snapshot?.data() else {
                completion(nil)
                return
            }
            completion(TatumUser(data: data))
        }
    }
    
    func deleteUserFromFirestore(uid: String, completion: @escaping (Error?) -> Void) {
        Firestore.firestore().collection("users").document(uid).delete { error in
            if let error = error {
                print("DEBUG: Failed to delete user - \(error.localizedDescription)")
            } else {
                print("DEBUG: Successfully deleted user \(uid)")
            }
            completion(error)
        }
    }
}
