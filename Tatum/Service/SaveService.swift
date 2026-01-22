//
//  SaveService.swift
//  Tatum
//
//  Service for handling post save/unsave operations
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol SaveServiceProtocol {
    static func savePost(post: Post, completion: @escaping(Error?) -> Void)
    static func unsavePost(post: Post, completion: @escaping(Error?) -> Void)
    static func checkIfUserSavedPost(post: Post, completion: @escaping(Bool) -> Void)
    static func fetchSavedPosts(completion: @escaping([Post]) -> Void)
}

struct SaveService: SaveServiceProtocol {
    
    /// Save a post to user's saved collection
    static func savePost(post: Post, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post.id else { return }
        
        let data: [String: Any] = [
            "timestamp": Timestamp(date: Date())
        ]
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("saved-posts")
            .document(postId)
            .setData(data, completion: completion)
    }
    
    /// Remove a post from user's saved collection
    static func unsavePost(post: Post, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postId = post.id else { return }
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("saved-posts")
            .document(postId)
            .delete(completion: completion)
    }
    
    /// Check if user has saved a specific post
    static func checkIfUserSavedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        guard let postId = post.id else {
            completion(false)
            return
        }
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("saved-posts")
            .document(postId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error checking if post is saved - \(error.localizedDescription)")
                    completion(false)
                    return
                }
                completion(snapshot?.exists ?? false)
            }
    }
    
    /// Fetch all saved posts for current user
    static func fetchSavedPosts(completion: @escaping([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("saved-posts")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching saved posts - \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let postIds = documents.map { $0.documentID }
                
                // Batch fetch the actual posts
                fetchPostsByIds(postIds: postIds, completion: completion)
            }
    }
    
    /// Helper: Fetch posts by their IDs
    private static func fetchPostsByIds(postIds: [String], completion: @escaping([Post]) -> Void) {
        guard !postIds.isEmpty else {
            completion([])
            return
        }
        
        // Firestore 'in' query limit is 10
        let chunks = postIds.chunked(into: 10)
        var allPosts: [Post] = []
        let group = DispatchGroup()
        
        for chunk in chunks {
            group.enter()
            Firestore.firestore()
                .collection("posts")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snapshot, error in
                    defer { group.leave() }
                    
                    if let error = error {
                        print("DEBUG: Error fetching posts batch - \(error.localizedDescription)")
                        return
                    }
                    
                    if let documents = snapshot?.documents {
                        let posts = documents.compactMap { try? $0.data(as: Post.self) }
                        allPosts.append(contentsOf: posts)
                    }
                }
        }
        
        group.notify(queue: .main) {
            completion(allPosts)
        }
    }
}

// MARK: - Array Extension for Chunking
fileprivate extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
