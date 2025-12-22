//
//  CommentsViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import Foundation
import FirebaseAuth
import Combine

class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    private let post: Post
    
    init(post: Post) {
        self.post = post
        fetchComments()
    }
    
    func uploadComment(commentText: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
                
        let service = AuthService()
        service.fetchUser(uid: currentUid) { [weak self] user in
            guard let self = self, let user = user else { return }
            
            PostService.uploadComment(post: self.post, commentText: commentText, user: user) { success in
                if success {
                    print("Yorum başarıyla yüklendi")
                }
            }
        }
    }
    
    func fetchComments() {
        PostService.fetchComments(post: post) { [weak self] comments in
            self?.comments = comments
        }
    }
}
