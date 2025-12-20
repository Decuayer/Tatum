import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

//MARK: - Protocol
protocol AuthServiceProtocol {
    var userSessionPublisher: CurrentValueSubject<String?, Never> { get }
    
    func login(withEmail email: String, password: String, completion: @escaping (Bool, String?) -> Void)
    func register(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping (Bool, String?) -> Void)
    func signOut()
    func fetchUser(uid: String, completion: @escaping (TatumUser?) -> Void)
}

//MARK: - Class
class AuthService: AuthServiceProtocol {
    
    // User Session Functions
    let userSessionPublisher = CurrentValueSubject<String?, Never>(nil)
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSessionPublisher.send(user?.uid)
        }
    }
    
    // Login function
    func login(withEmail email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            completion(true, nil)
        }
    }
    
    // Register function
    func register(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            // Veritabanına yazılacak ilk veriler
            let data: [String: Any] = [
                "uid": uid,
                "email": email,
                "username": username,
                "fullName": fullname,
                "role": "member",
                "followersCount": 0,
                "followingCount": 0,
                "createdAt": Timestamp(date: Date()),
                "website": "",
                "phoneNumber": "",
                "bio": ""
            ]
            
            Firestore.firestore().collection("users").document(uid).setData(data) { _ in
                completion(true, nil)
            }
        }
    }
    
    // Log Out function
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    // Fetch User Information
    func fetchUser(uid: String, completion: @escaping (TatumUser?) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                completion(nil)
                return
            }
            
            // Veriyi Modele Dönüştürme (Mapping)
            let user = TatumUser(
                id: data["uid"] as? String ?? "",
                email: data["email"] as? String ?? "",
                username: data["username"] as? String ?? "",
                fullName: data["fullName"] as? String ?? "",
                profileImageUrl: data["profileImageUrl"] as? String,
                role: data["role"] as? String ?? "member",
                bio: data["bio"] as? String,
                // YENİ ALANLAR:
                website: data["website"] as? String,
                phoneNumber: data["phoneNumber"] as? String,
                // TAKİPÇİ SAYAÇLARI:
                followersCount: data["followersCount"] as? Int ?? 0,
                followingCount: data["followingCount"] as? Int ?? 0
            )
            completion(user)
        }
    }
}
