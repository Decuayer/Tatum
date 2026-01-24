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
        // Email validasyonu
        if let emailError = ValidationHelper.validateEmail(email) {
            completion(false, emailError)
            return
        }
        
        if password.isEmpty {
            completion(false, "Password cannot be empty.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                let friendlyMessage = self.getFriendlyAuthError(error)
                print("DEBUG: (AuthService) Email:\(email) Login failed - \(error.localizedDescription)")
                completion(false, friendlyMessage)
                return
            }
            print("DEBUG: (AuthService) Email:\(email) - Login successful")
            completion(true, nil)
        }
    }
    
    // MARK: - Register
    
    func register(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping (Bool, String?) -> Void) {
        guard !email.isEmpty, !password.isEmpty, !fullname.isEmpty, !username.isEmpty else {
            completion(false, "All fields must be filled in.")
            return
        }
        
        if let emailError = ValidationHelper.validateEmail(email) {
            completion(false, emailError)
            return
        }
        
        if let passwordError = ValidationHelper.validatePassword(password) {
            completion(false, passwordError)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                let friendlyMessage = self.getFriendlyAuthError(error)
                print("DEBUG: (AuthService) Registration failed - \(error.localizedDescription)")
                completion(false, friendlyMessage)
                return
            }
            
            guard let uid = result?.user.uid else {
                print("DEBUG: (AuthService) Registration succeeded but no UID returned")
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
                    print("DEBUG: (AuthService) Failed to create user document - \(error.localizedDescription)")
                    completion(false, "Account created but profile setup failed. Please contact support.")
                    return
                }
                print("DEBUG: (AuthService) User profile created successfully")
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: (AuthService) Email:\(Auth.auth().currentUser?.email ?? "Anonymous") - User signed out successfully")
        } catch {
            print("DEBUG: (AuthService) Email:\(Auth.auth().currentUser?.email ?? "Anonymous") - Sign out failed - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch User
    
    func fetchUser(uid: String, completion: @escaping (TatumUser?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: (AuthService) Failed to fetch user - \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = snapshot?.data() else {
                print("DEBUG: (AuthService) User document does not exist for uid: \(uid)")
                completion(nil)
                return
            }
            
            var user = TatumUser(data: data)
            
            let group = DispatchGroup()
            
            group.enter()
            userRef.collection("user-followers").count.getAggregation(source: .server) { snapshot, error in
                if let error = error {
                    print("DEBUG: (AuthService) Failed to fetch followers count - \(error.localizedDescription)")
                } else if let count = snapshot?.count {
                    user.followersCount = Int(truncating: count)
                }
                group.leave()
            }
            
            group.enter()
            userRef.collection("user-following").count.getAggregation(source: .server) { snapshot, error in
                if let error = error {
                    print("DEBUG: (AuthService) Failed to fetch following count - \(error.localizedDescription)")
                } else if let count = snapshot?.count {
                    user.followingCount = Int(truncating: count)
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                print("DEBUG: (AuthService) User fetched successfully: \(user.username)")
                completion(user)
            }
        }
    }
    
    // MARK: - Helper Methods
    
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
        case .invalidCredential:
            return "Email or password incorrect. Please try again."
        default:
            return error.localizedDescription
        }
    }
}
