//
//  ChatViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var messageText: String = "" // Input alanındaki yazı
    
    private let service: ChatServiceProtocol
    
    init(service: ChatServiceProtocol = ChatService()) {
        self.service = service
        fetchMessages()
    }
    
    func fetchMessages() {
        service.fetchMessages { [weak self] messages in
            self?.messages = messages
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        // UI'da hemen göstermek için geçici ekleme (Optimistic Update)
        let newMessage = Message(
            id: UUID().uuidString,
            fromId: "currentUser",
            toId: "otherUser",
            text: messageText,
            timestamp: Date() 
        )
        messages.append(newMessage)
        
        // Servise Gönder
        service.sendMessage(text: messageText)
        
        // Input'u temizle
        messageText = ""
    }
}
