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
    private let user: TatumUser // Hangi kullanıcının profili?
    
    init(user: TatumUser, service: ProfileServiceProtocol = ProfileService()) {
        self.user = user
        self.service = service
        loadData()
    }
    
    func loadData() {
        // Eğer sanatçıysa kendi postlarını çek
        if user.role == "artist" {
            service.fetchUserPosts(uid: user.id) { [weak self] posts in
                self?.userPosts = posts
            }
        }
        
        // Herkesin beğendiği postları çek
        service.fetchLikedPosts(uid: user.id) { [weak self] posts in
            self?.likedPosts = posts
        }
    }
}
