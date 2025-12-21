import Foundation
import Combine

class UserProfileViewModel: ObservableObject {
    @Published var user: TatumUser
    @Published var posts: [Post] = []
    
    @Published var isFollowed: Bool = false
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    
    private let service: ProfileServiceProtocol
    
    init(user: TatumUser, service: ProfileServiceProtocol = ProfileService()) {
        self.user = user
        self.service = service
        
        // Veri kaynağından (Service) gelen Taze Sayılar
        self.followersCount = user.followersCount
        self.followingCount = user.followingCount
        
        self.checkIfFollowed()
        self.fetchUserPosts()
    }
    
    func follow() {
        // Optimistic UI Update
        isFollowed = true
        followersCount += 1
        
        service.follow(uid: user.id) { error in
            if let error = error {
                print("Follow Error: \(error.localizedDescription)")
                // Rollback
                self.isFollowed = false
                self.followersCount -= 1
            }
        }
    }
    
    func unfollow() {
        // Optimistic UI Update
        isFollowed = false
        followersCount = max(0, followersCount - 1)
        
        service.unfollow(uid: user.id) { error in
            if let error = error {
                print("Unfollow Error: \(error.localizedDescription)")
                // Rollback
                self.isFollowed = true
                self.followersCount += 1
            }
        }
    }
    
    func checkIfFollowed() {
        service.checkIfUserIsFollowed(uid: user.id) { [weak self] isFollowed in
            DispatchQueue.main.async { self?.isFollowed = isFollowed }
        }
    }
    
    func fetchUserPosts() {
        service.fetchUserPosts(uid: user.id) { [weak self] posts in
            DispatchQueue.main.async { self?.posts = posts }
        }
    }
}
