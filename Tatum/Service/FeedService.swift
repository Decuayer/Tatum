//
//  FeedService.swift
//  Tatum
//
//  Created by Demir Cücü on 24.12.2025.
//

import FirebaseFirestore
import FirebaseAuth

protocol FeedServiceProtocol {
    func fetchFeedPosts(completion: @escaping ([Post]) -> Void)
    func fetchSuggestedPosts(completion: @escaping ([Post]) -> Void)
}

class FeedService: FeedServiceProtocol, @unchecked Sendable {
    
    /// Fetch posts from users that the current user is following
    func fetchFeedPosts(completion: @escaping ([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: Cannot fetch feed - no authenticated user")
            completion([])
            return
        }
        
        print("DEBUG: Fetching feed posts for user \(uid)")
        
        Firestore.firestore().collection("users").document(uid).collection("user-following").getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch following list - \(error.localizedDescription)")
                completion([])
                return
            }
            
            var followingUids = snapshot?.documents.map({ $0.documentID }) ?? []
            followingUids.append(uid) // Include own posts
            
            if followingUids.isEmpty {
                print("DEBUG: No users to fetch posts from")
                completion([])

                return
            }
            
            // Limit to first 10 UIDs due to Firestore 'in' query limitation
            let queryIds = Array(followingUids.prefix(10))
            print("DEBUG: Fetching posts from \(queryIds.count) users")
            
            Firestore.firestore().collection("posts")
                .whereField("ownerUid", in: queryIds)
                .order(by: "timestamp", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("DEBUG: Failed to fetch feed posts - \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    let posts = snapshot?.documents.compactMap({ try? $0.data(as: Post.self) }) ?? []
                    print("DEBUG: Fetched \(posts.count) feed posts")
                    completion(posts)
                }
        }
    }
    
    /// Fetch suggested posts based on popularity (likes)
    func fetchSuggestedPosts(completion: @escaping ([Post]) -> Void) {
        print("DEBUG: Fetching suggested posts")
        Firestore.firestore().collection("posts")
            .order(by: "likes", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Failed to fetch suggested posts - \(error.localizedDescription)")
                    completion([])
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("DEBUG: No suggested posts found")
                    completion([])
                    return
                }
                let posts = documents.compactMap({ try? $0.data(as: Post.self) })
                print("DEBUG: Fetched \(posts.count) suggested posts")
                completion(posts)
            }
    }
}
