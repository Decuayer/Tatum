import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

protocol AuthServiceProtocol {
    var userSessionPublisher: CurrentValueSubject<String?, Never> { get }
    func login(withEmail email: String, password: String, completion: @escaping (Bool, String?) -> Void)
    func register(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping (Bool, String?) -> Void)
    func signOut()
    func fetchUser(uid: String, completion: @escaping (TatumUser?) -> Void)
}

class AuthService: AuthServiceProtocol {
    
    let userSessionPublisher = CurrentValueSubject<String?, Never>(nil)
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSessionPublisher.send(user?.uid)
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func login(withEmail email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            completion(true, nil)
        }
    }
    
    func register(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            // DİKKAT: Artık followersCount ve followingCount kaydetmiyoruz!
            let data: [String: Any] = [
                "uid": uid,
                "email": email,
                "username": username,
                "fullName": fullname,
                "role": "member",
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
    
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    // MARK: - FETCH USER (AGGREGATION ILE)
    func fetchUser(uid: String, completion: @escaping (TatumUser?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        // 1. Kullanıcı Dokümanını Çek
        userRef.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                completion(nil)
                return
            }
            
            // Temel verilerle User oluştur (Sayılar henüz 0)
            var user = TatumUser(data: data)
            
            // 2. Sayıları Hesapla (Parallel Execution)
            let group = DispatchGroup()
            
            // A) Followers Sayısı
            group.enter()
            userRef.collection("user-followers").count.getAggregation(source: .server) { snapshot, error in
                if let count = snapshot?.count {
                    user.followersCount = Int(truncating: count)
                }
                group.leave()
            }
            
            // B) Following Sayısı
            group.enter()
            userRef.collection("user-following").count.getAggregation(source: .server) { snapshot, error in
                if let count = snapshot?.count {
                    user.followingCount = Int(truncating: count)
                }
                group.leave()
            }
            
            // Hepsi bitince User'ı döndür
            group.notify(queue: .main) {
                completion(user)
            }
        }
    }
}
