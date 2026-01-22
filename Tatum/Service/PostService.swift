//
//  PostService.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import Foundation
import FirebaseFirestore

struct PostService {
    static func uploadPost(caption: String, image: UIImage, completion: @escaping(Bool) -> Void) {
        guard let uid = AuthService.getCurrentUserId() else { return }
        
        ImageUploader.uploadImage(image: image, folder: "post_images") { imageUrl, error in
            if let error = error {
                print("DEBUG: (Error) (PostService) Image Upload Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let imageUrl = imageUrl else { return }
            
            let data: [String: Any] = [
                "ownerUid": uid,
                "caption": caption,
                "likes": 0,
                "imageUrl": imageUrl,
                "timestamp": Timestamp(date: Date()),
                "isPrivate": false 
            ]
            
            Firestore.firestore().collection("posts").addDocument(data: data) { error in
                if let error = error {
                    print("DEBUG: (Error) (PostService) Post save error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                                
                completion(true)
            }
        }
    }
    
    static func likePost(post: Post, completion: @escaping(Error?) -> Void) {
            guard let uid = AuthService.getCurrentUserId() else { return }
            guard let postId = post.id else { return }
            
            let db = Firestore.firestore()
            let postLikeRef = db.collection("posts").document(postId).collection("post-likes").document(uid)
            
            postLikeRef.getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: (Error) (PostService) Error checking like status: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                if snapshot?.exists == true {
                    print("DEBUG: (PostService) Post already liked by user, skipping")
                    completion(nil)
                    return
                }
                
                let batch = db.batch()
                
                batch.setData([:], forDocument: postLikeRef)
                
                let postRef = db.collection("posts").document(postId)
                batch.updateData(["likes": FieldValue.increment(Int64(1))], forDocument: postRef)
                
                let userLikesRef = db.collection("users").document(uid).collection("user-likes").document(postId)
                batch.setData([:], forDocument: userLikesRef)
                
                batch.commit(completion: completion)
            }
        }
    
    static func unlikePost(post: Post, completion: @escaping(Error?) -> Void) {
            guard let uid = AuthService.getCurrentUserId() else { return }
            guard let postId = post.id else { return }
            
            let db = Firestore.firestore()
            let postLikeRef = db.collection("posts").document(postId).collection("post-likes").document(uid)
            
            postLikeRef.getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: (Error) (PostService) Error checking like status: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                if snapshot?.exists == false {
                    print("DEBUG: (PostService) Post not liked by user, skipping")
                    completion(nil)
                    return
                }
                
                let batch = db.batch()
                
                batch.deleteDocument(postLikeRef)
                
                let postRef = db.collection("posts").document(postId)
                batch.updateData(["likes": FieldValue.increment(Int64(-1))], forDocument: postRef)
                
                let userLikesRef = db.collection("users").document(uid).collection("user-likes").document(postId)
                batch.deleteDocument(userLikesRef)
                
                batch.commit(completion: completion)
            }
        }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = AuthService.getCurrentUserId() else { return }
        guard let postId = post.id else { return }
        
        Firestore.firestore().collection("posts").document(postId).collection("post-likes").document(uid).getDocument { snapshot, _ in
            guard let snapshot = snapshot else { return }
            completion(snapshot.exists)
        }
    }
    
    // MARK: - COMMENTS
    
    static func uploadComment(post: Post, commentText: String, user: TatumUser, completion: @escaping(Bool) -> Void) {
        guard let postId = post.id else { return }
        
        let data: [String: Any] = [
            "uid": user.id,
            "username": user.username,
            "profileImageUrl": user.profileImageUrl ?? "",
            "postOwnerUid": post.ownerUid,
            "commentText": commentText,
            "timestamp": Timestamp(date: Date())
        ]
        
        Firestore.firestore().collection("posts").document(postId).collection("post-comments").addDocument(data: data) { error in
            if let error = error {
                print("DEBUG: (Error) (PostService) Comment upload error: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    static func fetchComments(post: Post, completion: @escaping([Comment]) -> Void) {
        guard let postId = post.id else { return }
        
        Firestore.firestore().collection("posts").document(postId).collection("post-comments")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("DEBUG: (Error) (PostService) Comment pulling error: \(error?.localizedDescription ?? "")")
                    return
                }
                
                let comments = documents.compactMap { doc -> Comment? in
                    return Comment(documentId: doc.documentID, data: doc.data())
                }
                
                completion(comments)
            }
    }
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        Firestore.firestore().collection("posts")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("DEBUG: (Error) (PostService) Error while retrieving posts: \(error?.localizedDescription ?? "")")
                    return
                }
                
                let posts = documents.compactMap({ try? $0.data(as: Post.self) })
                completion(posts)
            }
    }
    
    // MARK: - User Fetching
    
    static func fetchPostOwner(uid: String, completion: @escaping (TatumUser?) -> Void) {
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: (Error) (PostService) OwnerID:\(uid) - Error fetching post owner: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let data = snapshot?.data() else {
                    completion(nil)
                    return
                }
                
                let user = TatumUser(data: data)
                completion(user)
            }
    }
    
    // MARK: - Likes Count
    
    static func fetchPostLikesCount(postId: String, completion: @escaping (Int) -> Void) {
        Firestore.firestore()
            .collection("posts")
            .document(postId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: (Error) (PostService) PostID:\(postId) - Error fetching likes count: \(error.localizedDescription)")
                    completion(0)
                    return
                }
                
                guard let data = snapshot?.data(),
                      let likes = data["likes"] as? Int else {
                    print("DEBUG: (Warning) (PostService) PostID:\(postId) - Likes field not found")
                    completion(0)
                    return
                }
                
                completion(likes)
            }
    }
}
