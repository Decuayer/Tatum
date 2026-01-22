//
//  PostViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import Foundation
import SwiftUI
import Combine

class PostViewModel: ObservableObject {
    @Published var post: Post
    @Published var isLiked = false
    @Published var likesCount = 0
    @Published var postOwner: TatumUser?
    
    init(post: Post) {
        self.post = post
        self.likesCount = post.likes
        checkIfUserLikedPost()
        fetchPostOwner()
    }
    
    func likePost() {
        isLiked = true
        
        PostService.likePost(post: post) { error in
            if let error = error {
                print("DEBUG: (Error) (PostViewModel) PostID:\(self.post.id ?? "NoPostID") OwnerID:\(self.post.ownerUid) Like error: \(error.localizedDescription)")
                self.isLiked = false
                }
        }
        fetchLikesCount()
    }
    
    func unlikePost() {
        isLiked = false
        
        PostService.unlikePost(post: post) { error in
            if let error = error {
                print("DEBUG: (Error) (PostViewModel) PostID:\(self.post.id ?? "NoPostID") OwnerID:\(self.post.ownerUid) - Unlike error: \(error.localizedDescription)")
                self.isLiked = true
            }
        }
        fetchLikesCount()
    }
    
    func checkIfUserLikedPost() {
        PostService.checkIfUserLikedPost(post: post) { isLiked in
            self.isLiked = isLiked
        }
    }
    
    func fetchLikesCount() {
        PostService.fetchPostLikesCount(postId: post.id ?? "") { count in
            DispatchQueue.main.async {
                self.likesCount = count
                self.post.likes = count
            }
        }
        likesCount = post.likes
    }
    
    // MARK: - User Fetching
    
    func fetchPostOwner() {
        PostService.fetchPostOwner(uid: post.ownerUid) { [weak self] user in
            DispatchQueue.main.async {
                self?.postOwner = user ?? self?.createFallbackUser()
            }
        }
    }
    
    // MARK: - Refresh
    
    func refresh() {
        fetchPostOwner()
        checkIfUserLikedPost()
        fetchLikesCount()
    }
    
    private func createFallbackUser() -> TatumUser {
        TatumUser(
            id: post.ownerUid,
            email: "",
            username: "User",
            fullName: "User",
            profileImageUrl: nil,
            role: "member",
            bio: nil,
            website: nil,
            phoneNumber: nil,
            studioId: nil,
            followersCount: 0,
            followingCount: 0
            )
    }
    
    var ownerOrFallback: TatumUser {
        postOwner ?? createFallbackUser()
    }
}
