//
//  Message.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable, Hashable {
    let id: String?
    let fromId: String
    let toId: String
    let text: String
    let timestamp: Date
    
    init(documentId: String, data: [String: Any]) {
        self.id = documentId
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
    }
    
    func isFromCurrentUser(currentUid: String) -> Bool {
        return fromId == currentUid
    }
}

struct RecentMessage: Identifiable {
    let id: String
    let text: String
    let fromId: String
    let toId: String
    let timestamp: Date
    
    let username: String
    let profileImageUrl: String?
    
    init(documentId: String, data: [String: Any]) {
        self.id = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
        self.username = data["username"] as? String ?? "User"
        self.profileImageUrl = data["profileImageUrl"] as? String
    }
}
