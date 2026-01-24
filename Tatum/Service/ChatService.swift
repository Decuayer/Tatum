//
//  ChatService.swift
//  Tatum
//
//  Created by Demir Cücü on 24.01.2026.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol ChatServiceProtocol {
    func sendMessage(text: String, currentUser: TatumUser, toUser: TatumUser)
    func observeMessages(chatPartnerId: String, completion: @escaping ([Message]) -> Void)
    func observeRecentMessages(completion: @escaping ([RecentMessage]) -> Void)
    
}

class ChatService: ChatServiceProtocol {
    
    func sendMessage(text: String, currentUser: TatumUser, toUser: TatumUser) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let timestamp = Timestamp(date: Date())
        let messageData: [String: Any] = [
            "text": text,
            "fromId": currentUid,
            "toId": toUser.id,
            "timestamp": timestamp
        ]
        let db = Firestore.firestore()
        let batch = db.batch()
        let myMessageRef = db.collection("users").document(currentUid).collection("chats").document(toUser.id).collection("messages").document()
        batch.setData(messageData, forDocument: myMessageRef)
        let recipientMessageRef = db.collection("users").document(toUser.id).collection("chats").document(currentUid).collection("messages").document()
        batch.setData(messageData, forDocument: recipientMessageRef)
        let myRecentRef = db.collection("users").document(currentUid).collection("recent_messages").document(toUser.id)
        let myRecentData: [String: Any] = [
            "text": text,
            "fromId": currentUid,
            "toId": toUser.id,
            "timestamp": timestamp,
            "username": toUser.username,
            "profileImageUrl": toUser.profileImageUrl ?? ""
        ]
        batch.setData(myRecentData, forDocument: myRecentRef)
        let recipientRecentRef = db.collection("users").document(toUser.id).collection("recent_messages").document(currentUid)
        let recipientRecentData: [String: Any] = [
            "text": text,
            "fromId": currentUid,
            "toId": toUser.id,
            "timestamp": timestamp,
            "username": currentUser.username,
            "profileImageUrl": currentUser.profileImageUrl ?? ""
        ]
        batch.setData(recipientRecentData, forDocument: recipientRecentRef)
        batch.commit { error in
            if let error = error {
                print("Mesaj gönderme hatası: \(error.localizedDescription)")
            } else {
                print("Mesaj başarıyla 4 noktaya yazıldı.")
            }
        }
    }
    
    func observeMessages(chatPartnerId: String, completion: @escaping ([Message]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users")
            .document(currentUid)
            .collection("chats")
            .document(chatPartnerId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let _ = snapshot?.documentChanges else { return }
                
                let messages = snapshot?.documents.compactMap({ doc in
                    return Message(documentId: doc.documentID, data: doc.data())
                }) ?? []
                
                completion(messages)
            }
    }
    
    // 3. INBOX DİNLEME (Real-time)
    func observeRecentMessages(completion: @escaping ([RecentMessage]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users")
            .document(currentUid)
            .collection("recent_messages")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                let recents = documents.compactMap { doc in
                    return RecentMessage(documentId: doc.documentID, data: doc.data())
                }
                completion(recents)
            }
    }
}
