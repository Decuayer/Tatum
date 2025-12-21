//
//  InboxViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import Combine

class InboxViewModel: ObservableObject {
    @Published var recentMessages: [RecentMessage] = []
    private let service: ChatServiceProtocol
    
    init(service: ChatServiceProtocol = ChatService()) {
        self.service = service
        loadRecentMessages()
    }
    
    func loadRecentMessages() {
        service.observeRecentMessages { [weak self] recents in
            self?.recentMessages = recents
        }
    }
}
