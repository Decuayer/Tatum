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
    
    // MARK: - Current User
    
    static func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Login
    
    func login(withEmail email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                let friendlyMessage = self.getFriendlyAuthError(error)
                print("DEBUG: Login failed - \(error.localizedDescription)")
                completion(false, friendlyMessage)
                return
            }
            print("DEBUG: Login successful")
            completion(true, nil)
        }
    }
    
    // MARK: - Register
    
    func register(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping (Bool, String?) -> Void) {
        guard !email.isEmpty, !password.isEmpty, !fullname.isEmpty, !username.isEmpty else {
            completion(false, "All fields are required.")
            return
        }
        
        guard password.count >= 6 else {
            completion(false, "Password must be at least 6 characters.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                let friendlyMessage = self.getFriendlyAuthError(error)
                print("DEBUG: Registration failed - \(error.localizedDescription)")
                completion(false, friendlyMessage)
                return
            }
            
            guard let uid = result?.user.uid else {
                print("DEBUG: Registration succeeded but no UID returned")
                completion(false, "Registration failed. Please try again.")
                return
            }
            
            let data: [String: Any] = [
                "uid": uid,
                "email": email,
                "username": username,
                "fullName": fullname,
                "role": "member",
                "createdAt": Timestamp(date: Date()),
                "website": "",
                "phoneNumber": "",
                "bio": "",
                "followersCount": 0,
                "followingCount": 0
            ]
            
            Firestore.firestore().collection("users").document(uid).setData(data) { error in
                if let error = error {
                    print("DEBUG: Failed to create user document - \(error.localizedDescription)")
                    completion(false, "Account created but profile setup failed. Please contact support.")
                    return
                }
                print("DEBUG: User profile created successfully")
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: User signed out successfully")
        } catch {
            print("DEBUG: Sign out failed - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch User
    
    func fetchUser(uid: String, completion: @escaping (TatumUser?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch user - \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("DEBUG: User document does not exist for uid: \(uid)")
                completion(nil)
                return
            }
            
            var user = TatumUser(data: data)
            
            let group = DispatchGroup()
            
            // Fetch followers count
            group.enter()
            userRef.collection("user-followers").count.getAggregation(source: .server) { snapshot, error in
                if let error = error {
                    print("DEBUG: Failed to fetch followers count - \(error.localizedDescription)")
                } else if let count = snapshot?.count {
                    user.followersCount = Int(truncating: count)
                }
                group.leave()
            }
            
            // Fetch following count
            group.enter()
            userRef.collection("user-following").count.getAggregation(source: .server) { snapshot, error in
                if let error = error {
                    print("DEBUG: Failed to fetch following count - \(error.localizedDescription)")
                } else if let count = snapshot?.count {
                    user.followingCount = Int(truncating: count)
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                print("DEBUG: User fetched successfully: \(user.username)")
                completion(user)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Convert Firebase Auth errors to user-friendly messages
    private func getFriendlyAuthError(_ error: NSError) -> String {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return "An unexpected error occurred. Please try again."
        }
        
        switch errorCode {
        case .emailAlreadyInUse:
            return "This email is already registered. Try logging in instead."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password is too weak. Please use a stronger password."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .userNotFound:
            return "No account found with this email."
        case .userDisabled:
            return "This account has been disabled. Please contact support."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Please try again later."
        default:
            return error.localizedDescription
        }
    }
}
