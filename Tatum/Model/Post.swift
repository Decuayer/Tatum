//
//  Post.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable, Hashable, Sendable {
    @DocumentID var id: String?
    let ownerUid: String
    let caption: String
    var likes: Int
    let imageUrl: String
    let timestamp: Date
    
    // User data (denormalized for performance)
    var user: TatumUser?
    
    // Studio tagging
    var studioId: String?           // If posted by studio or tagged studio
    var studioName: String?         // Denormalized studio name for display
    
    // Categorization & Metadata
    var categories: [String]?        // Array of TattooCategory raw values
    var bodyPlacement: String?       // BodyPlacement raw value
    var isPrivate: Bool?             // Privacy setting (visible only to followers)
    
    // Artist attribution (for studio posts)
    var artistUid: String?           // If studio post, which artist did it
    var artistName: String?          // Denormalized artist name
    
    init(id: String? = nil, ownerUid: String, caption: String, likes: Int, imageUrl: String, timestamp: Date, user: TatumUser? = nil, studioId: String? = nil, studioName: String? = nil, categories: [String]? = nil, bodyPlacement: String? = nil, isPrivate: Bool? = nil, artistUid: String? = nil, artistName: String? = nil) {
        // NOTE: @DocumentID (id) is managed by Firestore - don't assign it manually
        self.ownerUid = ownerUid
        self.caption = caption
        self.likes = likes
        self.imageUrl = imageUrl
        self.timestamp = timestamp
        self.user = user
        self.studioId = studioId
        self.studioName = studioName
        self.categories = categories
        self.bodyPlacement = bodyPlacement
        self.isPrivate = isPrivate
        self.artistUid = artistUid
        self.artistName = artistName
    }
}

// MARK: - Category Helpers
extension Post {
    /// Type-safe category accessors
    var tattooCategories: [TattooCategory] {
        (categories ?? []).compactMap { TattooCategory(rawValue: $0) }
    }
    
    /// Primary category (first one)
    var primaryCategory: TattooCategory? {
        tattooCategories.first
    }
    
    /// Type-safe body placement accessor
    var placement: BodyPlacement? {
        guard let bodyPlacement = bodyPlacement else { return nil }
        return BodyPlacement(rawValue: bodyPlacement)
    }
    
    /// Whether post is tagged to a studio
    var hasStudioTag: Bool {
        studioId != nil
    }
    
    /// Whether post has artist attribution (studio post)
    var hasArtistAttribution: Bool {
        artistUid != nil
    }
    
    /// Whether post is public
    var isPublic: Bool {
        !(isPrivate ?? false)
    }
}
