//
//  ChatService.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import FirebaseFirestore

protocol ChatServiceProtocol {
    func fetchMessages(completion: @escaping ([Message]) -> Void)
    func sendMessage(text: String)
}

class ChatService: ChatServiceProtocol {
    func fetchMessages(completion: @escaping ([Message]) -> Void) {
        // MOCK DATA: Sanki veritabanından gelmiş gibi
        let mockMessages = [
            Message(id: "1", fromId: "otherUser", toId: "currentUser", text: "Merhaba, dövme randevusu için yazmıştım.", timestamp: Date()),
            Message(id: "2", fromId: "currentUser", toId: "otherUser", text: "Selamlar! Tabii ki, nasıl yardımcı olabilirim?", timestamp: Date()),
            Message(id: "3", fromId: "otherUser", toId: "currentUser", text: "Koluma geometrik bir tasarım düşünüyorum.", timestamp: Date()),
            Message(id: "4", fromId: "currentUser", toId: "otherUser", text: "Harika fikir. Örnek bir görselin var mı?", timestamp: Date())
        ]
        completion(mockMessages)
    }
    
    func sendMessage(text: String) {
        // İleride burası Firestore'a yazacak
        print("Message sent to Firestore: \(text)")
    }
}
