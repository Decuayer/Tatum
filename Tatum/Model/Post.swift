//
//  Post.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable, Hashable {
    let id: String?
    let ownerUid: String
    let studioId: String?
    let caption: String
    var likes: Int
    let imageUrl: String
    let timestamp: Date
    
    var user: TatumUser?
    
    init(id: String?, ownerUid: String, studioId: String?, caption: String, likes: Int, imageUrl: String, timestamp: Date, user: TatumUser?) {
        self.id = id
        self.ownerUid = ownerUid
        self.studioId = studioId
        self.caption = caption
        self.likes = likes
        self.imageUrl = imageUrl
        self.timestamp = timestamp
        self.user = user
    }
}
