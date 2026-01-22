import Foundation
import Combine

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    
    let toUser: TatumUser
    private let service: ChatServiceProtocol
    
    init(user: TatumUser, service: ChatServiceProtocol = ChatService()) {
        self.toUser = user
        self.service = service
        observeChat()
    }
    
    func observeChat() {
        service.observeMessages(chatPartnerId: toUser.id) { [weak self] messages in
            self?.messages = messages
        }
    }
    
    func sendMessage(currentUser: TatumUser) {
        guard !messageText.isEmpty else { return }
        service.sendMessage(text: messageText, currentUser: currentUser, toUser: toUser)
        messageText = ""
    }
}
