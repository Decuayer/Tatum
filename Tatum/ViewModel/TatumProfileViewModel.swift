
//
//  TatumProfilViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 21.01.2026.
//

import Foundation
import Combine
import FirebaseAuth

class TatumProfileViewModel: ObservableObject {
    
    @Published var user: TatumUser
    @Published var posts: [Post] = []
    @Published var likedPosts: [Post] = []
    
    @Published var isFollowed: Bool = false
    
    private let service: ProfileServiceProtocol
    
    init(user: TatumUser, service: ProfileServiceProtocol = ProfileService()) {
        self.user = user
        self.service = service
        
        loadUserData()
        
        if !user.isCurrentUser {
            checkIfFollowed()
        }
    }
    
    func loadUserData() {
        fetchUserPosts()
        fetchLikedPosts()
        refreshUserStats()
    }
    
    func fetchUserPosts() {
        service.fetchUserPosts(uid: user.id) { [weak self] fetchedPosts in
            DispatchQueue.main.async {
                self?.posts = fetchedPosts
            }
        }
    }
    
    func fetchLikedPosts() {
        service.fetchLikedPosts(uid: user.id) { [weak self] fetchedPosts in
            DispatchQueue.main.async {
                self?.likedPosts = fetchedPosts
            }
        }
    }
    
    func follow() {
        isFollowed = true
        user.followersCount += 1
        
        service.follow(uid: user.id) { [weak self] error in
            if let error = error {
                print("DEBUG: Follow error: \(error.localizedDescription)")
                // Hata olursa geri al
                DispatchQueue.main.async {
                    self?.isFollowed = false
                    self?.user.followersCount -= 1
                }
            }
        }
    }
    
    func unfollow() {
        isFollowed = false
        user.followersCount = max(0, user.followersCount - 1)
        
        service.unfollow(uid: user.id) { [weak self] error in
            if let error = error {
                print("DEBUG: Unfollow error: \(error.localizedDescription)")
                // Hata olursa geri al
                DispatchQueue.main.async {
                    self?.isFollowed = true
                    self?.user.followersCount += 1
                }
            }
        }
    }
    
    func checkIfFollowed() {
        service.checkIfUserIsFollowed(uid: user.id) { [weak self] isFollowed in
            DispatchQueue.main.async {
                self?.isFollowed = isFollowed
            }
        }
    }
    
    func refreshUserStats() {
        let authService = AuthService()
        authService.fetchUser(uid: user.id) { [weak self] updatedUser in
            if let updatedUser = updatedUser {
                DispatchQueue.main.async {
                    self?.user = updatedUser
                }
            }
        }
    }
}
