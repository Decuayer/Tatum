import Foundation
import FirebaseFirestore

struct TatumUser: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let email: String
    let username: String
    var fullName: String
    var profileImageUrl: String?
    var role: String
    var bio: String?
    var website: String?
    var phoneNumber: String?
    var studioId: String?
    
    var followersCount: Int = 0
    var followingCount: Int = 0
    
    init(data: [String: Any]) {
        self.id = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.fullName = data["fullName"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String
        self.role = data["role"] as? String ?? "member"
        self.bio = data["bio"] as? String
        self.website = data["website"] as? String
        self.phoneNumber = data["phoneNumber"] as? String
        self.studioId = data["studioId"] as? String
    }
    
    init(id: String, email: String, username: String, fullName: String, profileImageUrl: String?, role: String, bio: String?, website: String?, phoneNumber: String?, studioId: String?, followersCount: Int, followingCount: Int) {
        self.id = id
        self.email = email
        self.username = username
        self.fullName = fullName
        self.profileImageUrl = profileImageUrl
        self.role = role
        self.bio = bio
        self.website = website
        self.phoneNumber = phoneNumber
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.studioId = studioId
    }
}
