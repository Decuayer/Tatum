import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    let id: String 
    let username: String
    let profileImageUrl: String?
    let uid: String
    let timestamp: Date
    let postOwnerUid: String
    let commentText: String
    
    init(documentId: String, data: [String: Any]) {
        self.id = documentId
        self.username = data["username"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String
        self.uid = data["uid"] as? String ?? ""
        self.postOwnerUid = data["postOwnerUid"] as? String ?? ""
        self.commentText = data["commentText"] as? String ?? ""
        self.timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
    }
    
    func timestampString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: timestamp)
    }
}
