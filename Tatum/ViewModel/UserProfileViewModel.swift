//
//  UserProfileViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import Combine

class UserProfileViewModel: ObservableObject {
    @Published var user: TatumUser
    @Published var posts: [Post] = []
    @Published var isFollowed: Bool = false
    @Published var stats: UserStats = UserStats(followers: 0, following: 0, posts: 0)
    
    private let service: ProfileServiceProtocol
    
    init(user: TatumUser, service: ProfileServiceProtocol = ProfileService()) {
        self.user = user
        self.service = service
        // Başlarken verileri çekiyoruz
        self.checkIfFollowed()
        self.fetchUserPosts()
        self.fetchUserStats()
    }
    
    // MARK: - TAKİP MANTIĞI
    
    func follow() {
        // Optimistic Update: Servis cevabını beklemeden UI'ı güncelle (Hız hissi için)
        self.isFollowed = true
        
        service.follow(uid: user.id) { error in
            if let error = error {
                print("DEBUG: Follow error \(error.localizedDescription)")
                // Hata olursa işlemi geri al
                self.isFollowed = false
                return
            }
            // Başarılı olursa bildirim gönderme vs. burada yapılabilir
        }
    }
    
    func unfollow() {
        // Optimistic Update
        self.isFollowed = false
        
        service.unfollow(uid: user.id) { error in
            if let error = error {
                print("DEBUG: Unfollow error \(error.localizedDescription)")
                self.isFollowed = true // Geri al
                return
            }
        }
    }
    
    func checkIfFollowed() {
        service.checkIfUserIsFollowed(uid: user.id) { [weak self] isFollowed in
            self?.isFollowed = isFollowed
        }
    }
    
    // MARK: - VERİ ÇEKME
    
    func fetchUserPosts() {
        service.fetchUserPosts(uid: user.id) { [weak self] posts in
            self?.posts = posts
        }
    }
    
    func fetchUserStats() {
        // Şu anlık user objesindeki veriyi alıyoruz.
        // İleride buraya "fetchUserStats" servisi yazıp güncel sayıları çekeceğiz.
        self.stats = UserStats(
            followers: user.followersCount,
            following: user.followingCount,
            posts: 0 // Servisten post sayısı gelince güncellenecek
        )
    }
}

// İstatistikleri toplu tutmak için yardımcı yapı
struct UserStats {
    let followers: Int
    let following: Int
    let posts: Int
}
