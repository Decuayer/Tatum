//
//  Message.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation


struct Message: Identifiable, Codable, Hashable {
    let id: String
    let fromId: String // Gönderen
    let toId: String   // Alıcı
    let text: String
    let timestamp: Date
    
    // Mesajın şu anki kullanıcıdan olup olmadığını kontrol eden yardımcı
    func isFromCurrentUser(currentUid: String) -> Bool {
        return fromId == currentUid
    }
}
