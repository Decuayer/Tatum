//
//  Post.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation

struct Post: Identifiable, Codable {
    let id: String
    let ownerUid: String
    let caption: String
    let likes: Int
    let imageUrl: String
    let timestamp: Date
    let user: TatumUser? // Postu kimin attığını göstermek için
}
