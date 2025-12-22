//
//  PostDetailViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import Foundation
import SwiftUI
import Combine

class PostDetailViewModel: ObservableObject {
    @Published var post: Post
    @Published var isLiked = false
    @Published var likesCount = 0
    
    init(post: Post) {
        self.post = post
        self.likesCount = post.likes
        checkIfUserLikedPost()
    }
    
    func likePost() {
        isLiked = true
        likesCount += 1
        
        PostService.likePost(post: post) { error in
            if let error = error {
                print("Like hatası: \(error.localizedDescription)")
                self.isLiked = false
                self.likesCount -= 1
            }
        }
    }
    
    func unlikePost() {
        isLiked = false
        likesCount = max(0, likesCount - 1)
        
        PostService.unlikePost(post: post) { error in
            if let error = error {
                print("Unlike hatası: \(error.localizedDescription)")
                // Hata varsa geri al
                self.isLiked = true
                self.likesCount += 1
            }
        }
    }
    
    func checkIfUserLikedPost() {
        PostService.checkIfUserLikedPost(post: post) { isLiked in
            self.isLiked = isLiked
        }
    }
}
