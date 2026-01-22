import Foundation
import FirebaseFirestore
import FirebaseAuth

struct TatumUser: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let email: String
    let username: String
    var fullName: String
    var profileImageUrl: String?
    var role: String  // Stored as String for Firestore compatibility
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

// MARK: - Role System
extension TatumUser {
    /// Type-safe role accessor
    var userRole: UserRole {
        UserRole(rawValue: role) ?? .member
    }
    
    /// Whether this user can create posts
    var canPost: Bool {
        userRole.canPost
    }
    
    /// Whether this user is an artist (includes studio employees)
    var isArtist: Bool {
        userRole == .artist || userRole == .studioEmployee
    }
    
    /// Whether this user is a studio account
    var isStudio: Bool {
        userRole == .studio
    }
    
    /// Whether this user is a regular member
    var isMember: Bool {
        userRole == .member
    }
    
    /// Whether this user can have a studio affiliation
    var canHaveStudioAffiliation: Bool {
        userRole.canHaveStudioAffiliation
    }
}

// MARK: - Current User Check
extension TatumUser {
    var isCurrentUser: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return id == currentUid
    }
}

