//
//  PostService.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct PostService {
    static func uploadPost(caption: String, image: UIImage, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image, folder: "post_images") { imageUrl, error in
            if let error = error {
                print("Resim yükleme hatası: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let imageUrl = imageUrl else { return }
            
            let data: [String: Any] = [
                "ownerUid": uid,
                "caption": caption,
                "likes": 0,
                "imageUrl": imageUrl,
                "timestamp": Timestamp(date: Date())
            ]
            
            Firestore.firestore().collection("posts").addDocument(data: data) { error in
                if let error = error {
                    print("Post kaydetme hatası: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                // İsteğe bağlı: Kullanıcının kendi profili altına da referans eklenebilir
                // Ama şimdilik global 'posts' koleksiyonu yeterli.
                
                completion(true)
            }
        }
    }
    
    static func likePost(post: Post, completion: @escaping(Error?) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let postId = post.id else { return }
            
            let db = Firestore.firestore()
            let batch = db.batch()
            
            let postLikeRef = db.collection("posts").document(postId).collection("post-likes").document(uid)
            batch.setData([:], forDocument: postLikeRef)
            
            let postRef = db.collection("posts").document(postId)
            batch.updateData(["likes": FieldValue.increment(Int64(1))], forDocument: postRef)
            

            let userLikesRef = db.collection("users").document(uid).collection("user-likes").document(postId)
            batch.setData([:], forDocument: userLikesRef)
            
            batch.commit(completion: completion)
        }
    
    static func unlikePost(post: Post, completion: @escaping(Error?) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let postId = post.id else { return }
            
            let db = Firestore.firestore()
            let batch = db.batch()
            
            let postLikeRef = db.collection("posts").document(postId).collection("post-likes").document(uid)
            batch.deleteDocument(postLikeRef)
            
            let postRef = db.collection("posts").document(postId)
            batch.updateData(["likes": FieldValue.increment(Int64(-1))], forDocument: postRef)
            
            let userLikesRef = db.collection("users").document(uid).collection("user-likes").document(postId)
            batch.deleteDocument(userLikesRef)
            
            batch.commit(completion: completion)
        }
    
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
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
        
        // Post'un altına 'post-comments' koleksiyonuna ekle
        Firestore.firestore().collection("posts").document(postId).collection("post-comments").addDocument(data: data) { error in
            if let error = error {
                print("Yorum yükleme hatası: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    // Yorumları Getir (Real-time Dinleme)
    static func fetchComments(post: Post, completion: @escaping([Comment]) -> Void) {
        guard let postId = post.id else { return }
        
        // Tarihe göre sırala (Eskiden yeniye veya tam tersi)
        Firestore.firestore().collection("posts").document(postId).collection("post-comments")
            .order(by: "timestamp", descending: false) // Eskiler üstte, yeniler altta
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Yorum çekme hatası: \(error?.localizedDescription ?? "")")
                    return
                }
                
                let comments = documents.compactMap { doc -> Comment? in
                    return Comment(documentId: doc.documentID, data: doc.data())
                }
                
                completion(comments)
            }
    }
}
