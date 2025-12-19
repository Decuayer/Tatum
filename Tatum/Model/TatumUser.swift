//
//  TatumUser.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation

struct TatumUser: Identifiable, Codable {
    let id: String // Firebase Auth ID
    let email: String
    let username: String
    var fullName: String
    var profileImageUrl: String?
    var role: String // 'member', 'artist', 'owner'
    var bio: String?
    var followersCount: Int
    var followingCount: Int
    
    static var mockUser: TatumUser {
        return TatumUser(
            id: "123",
            email: "test@tatum.com",
            username: "Decu",
            fullName: "Demir Cücü",
            profileImageUrl: nil,
            role: "member",
            bio: "Tattoo lover",
            followersCount: 0,
            followingCount: 0
        )
    }
    
}
