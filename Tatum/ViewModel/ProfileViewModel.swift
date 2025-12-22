//
//  ProfileViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userPosts: [Post] = []
    @Published var likedPosts: [Post] = []
    
    private let service: ProfileServiceProtocol
    let user: TatumUser
    
    init(user: TatumUser, service: ProfileServiceProtocol = ProfileService()) {
        self.user = user
        self.service = service
        loadData()
    }
    
    func loadData() {
        fetchUserPosts()
        fetchLikedPosts()
    }
    
    func fetchUserPosts() {
        guard user.role == "artist" else { return }
        
        service.fetchUserPosts(uid: user.id) { [weak self] posts in
            self?.userPosts = posts
        }
    }
    
    func fetchLikedPosts() {
        service.fetchLikedPosts(uid: user.id) { [weak self] posts in
            self?.likedPosts = posts
        }
    }
}
