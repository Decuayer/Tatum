//
//  TatumUser.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation

struct TatumUser: Identifiable, Codable {
    let id: String
    let email: String
    let username: String
    var fullName: String
    var profileImageUrl: String?
    var role: String
    var bio: String?
    
    // YENİ EKLENEN DETAYLI ALANLAR
    var website: String?
    var phoneNumber: String?
    
    var followersCount: Int
    var followingCount: Int
    
    // Varsayılan init (Mock Data için)
    static var mockUser: TatumUser {
        return TatumUser(
            id: "123",
            email: "test@tatum.com",
            username: "polenaktar",
            fullName: "Polen Aktar",
            profileImageUrl: nil,
            role: "member",
            bio: "Tattoo enthusiast & art lover.",
            website: "www.tatum.app",
            phoneNumber: "+90 555 123 45 67",
            followersCount: 150,
            followingCount: 85
        )
    }
}
