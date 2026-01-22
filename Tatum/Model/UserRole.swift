import Foundation

/// Defines the role types in the Tatum platform
enum UserRole: String, Codable, CaseIterable {
    case member = "member"           // Regular user (can browse, save, message)
    case artist = "artist"           // Tattoo artist (can post publicly)
    case studio = "studio"           // Studio account (can post, has carousel)
    case studioEmployee = "studio_employee"  // Artist affiliated with studio
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .member:
            return "Member"
        case .artist:
            return "Artist"
        case .studio:
            return "Studio"
        case .studioEmployee:
            return "Studio Artist"
        }
    }
    
    /// Whether this role can create posts
    var canPost: Bool {
        switch self {
        case .artist, .studio, .studioEmployee:
            return true
        case .member:
            return false
        }
    }
    
    /// Whether this role requires subscription (future implementation)
    var requiresSubscription: Bool {
        switch self {
        case .artist, .studio:
            return true  // Artists and studios need paid subscription
        case .member, .studioEmployee:
            return false
        }
    }
    
    /// Whether this role can have a studio affiliation
    var canHaveStudioAffiliation: Bool {
        switch self {
        case .artist, .studioEmployee:
            return true
        case .member, .studio:
            return false
        }
    }
}
