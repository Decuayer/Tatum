//
//  FeedService.swift
//  Tatum
//
//  Created by Demir Cücü on 24.12.2025.
//

import FirebaseFirestore
import FirebaseAuth

class FeedService: @unchecked Sendable {
    
    func fetchFeedPosts(completion: @escaping ([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).collection("user-following").getDocuments { snapshot, _ in
            
            var followingUids = snapshot?.documents.map({ $0.documentID }) ?? []
            followingUids.append(uid)
            
            if followingUids.isEmpty {
                completion([])
                return
            }
            
            let queryIds = Array(followingUids.prefix(10))
            
            Firestore.firestore().collection("posts")
                .whereField("ownerUid", in: queryIds)
                .order(by: "timestamp", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("DEBUG: Feed çekme hatası: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    let posts = snapshot?.documents.compactMap({ try? $0.data(as: Post.self) }) ?? []
                    completion(posts)
                }
        }
    }
    
    func fetchSuggestedPosts(completion: @escaping ([Post]) -> Void) {
        Firestore.firestore().collection("posts")
            .order(by: "likes", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                let posts = documents.compactMap({ try? $0.data(as: Post.self) })
                completion(posts)
            }
    }
}
