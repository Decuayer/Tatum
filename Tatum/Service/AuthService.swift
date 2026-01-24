//
//  AuthService.swift
//  Tatum
//
//  Created by Demir Cücü on 24.01.2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import GoogleSignIn
import AuthenticationServices
import FirebaseCore

protocol AuthServiceProtocol {
    var userSessionPublisher: CurrentValueSubject<String?, Never> { get }
    func login(withEmail email: String, password: String, completion: @escaping (Bool, String?) -> Void)
    func register(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping (Bool, String?) -> Void)
    func signInWithGoogle(presenting: UIViewController, isRegistration: Bool, completion: @escaping (Bool, String?) -> Void)
    func signInWithApple(isRegistration: Bool, completion: @escaping (Bool, String?) -> Void)
    func checkEmailProvider(email: String, completion: @escaping (Result<[String], Error>) -> Void)
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
                "authProviders": ["password"],
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
    
    // MARK: - Google Sign-In
    
    func signInWithGoogle(presenting: UIViewController, isRegistration: Bool, completion: @escaping (Bool, String?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false, "Firebase configuration error.")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { [weak self] result, error in
            if let error = error {
                print("DEBUG: (AuthService) Google Sign-In failed - \(error.localizedDescription)")
                completion(false, "Google Sign-In failed. Please try again.")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString,
                  let userEmail = user.profile?.email else {
                completion(false, "Failed to get user information from Google.")
                return
            }
            
            // Check existing account and providers
            self?.checkEmailProvider(email: userEmail) { providerResult in
                switch providerResult {
                case .success(let providers):
                    if isRegistration {
                        // REGISTRATION MODE: Account should NOT exist
                        if !providers.isEmpty {
                            completion(false, "Account already exists. Please sign in instead.")
                            return
                        }
                        // Proceed with Google registration
                        self?.completeGoogleAuth(idToken: idToken, accessToken: user.accessToken.tokenString, email: userEmail, fullName: user.profile?.name, isRegistration: true, completion: completion)
                    } else {
                        // LOGIN MODE: Account MUST exist and be linked with Google
                        if providers.isEmpty {
                            completion(false, "No account found. Please sign up first.")
                            return
                        }
                        if !providers.contains("google.com") {
                            completion(false, "This email is registered with password. Please sign in with your password.")
                            return
                        }
                        // Proceed with Google login
                        self?.completeGoogleAuth(idToken: idToken, accessToken: user.accessToken.tokenString, email: userEmail, fullName: user.profile?.name, isRegistration: false, completion: completion)
                    }
                case .failure(let error):
                    print("DEBUG: (AuthService) (signInWithGoogle) Failed to check email provider - \(error.localizedDescription)")
                    completion(false, "Error checking account. Please try again.")
                }
            }
        }
    }
    
    private func completeGoogleAuth(idToken: String, accessToken: String, email: String?, fullName: String?, isRegistration: Bool, completion: @escaping (Bool, String?) -> Void) {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            if let error = error {
                print("DEBUG: (AuthService) Firebase Google Sign-In failed - \(error.localizedDescription)")
                completion(false, "Authentication failed. Please try again.")
                return
            }
            
            guard let uid = authResult?.user.uid else {
                completion(false, "Failed to get user ID.")
                return
            }
            
            if isRegistration {
                // Create new user with Google provider
                self?.createUserWithProvider(uid: uid, email: email, fullName: fullName, provider: "google.com", completion: completion)
            } else {
                // Existing user, just complete login
                print("DEBUG: (AuthService) Email:\(email ?? "unknown") - Google login successful")
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Check Email Provider
    
    func checkEmailProvider(email: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("DEBUG: (AuthService) (Complete GoogleAuth) Failed to check email provider - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let doc = snapshot?.documents.first,
                   let providers = doc.data()["authProviders"] as? [String] {
                    print("DEBUG: (AuthService) Email:\(email) has providers: \(providers)")
                    completion(.success(providers))
                } else {
                    // No user found with this email
                    completion(.success([]))
                }
            }
    }
    
    // MARK: - Apple Sign-In
    
    func signInWithApple(isRegistration: Bool, completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                let coordinator = AppleSignInCoordinator()
                let (credential, email, fullName) = try await coordinator.signIn()
                
                // Get email - Apple might not provide email on subsequent logins
                guard let userEmail = email else {
                    // For login mode, we can still proceed (email stored in Firestore)
                    // For registration mode, we need email
                    if isRegistration {
                        DispatchQueue.main.async {
                            completion(false, "Unable to get email from Apple. Please try again.")
                        }
                        return
                    }
                    // For login, proceed without email check
                    await self.completeAppleAuth(credential: credential, email: nil, fullName: fullName, isRegistration: false, completion: completion)
                    return
                }
                
                // Check existing account and providers
                self.checkEmailProvider(email: userEmail) { [weak self] providerResult in
                    Task {
                        switch providerResult {
                        case .success(let providers):
                            if isRegistration {
                                // REGISTRATION MODE: Account should NOT exist
                                if !providers.isEmpty {
                                    DispatchQueue.main.async {
                                        completion(false, "Account already exists. Please sign in instead.")
                                    }
                                    return
                                }
                                // Proceed with Apple registration
                                await self?.completeAppleAuth(credential: credential, email: userEmail, fullName: fullName, isRegistration: true, completion: completion)
                            } else {
                                // LOGIN MODE: Account MUST exist and be linked with Apple
                                if providers.isEmpty {
                                    DispatchQueue.main.async {
                                        completion(false, "No account found. Please sign up first.")
                                    }
                                    return
                                }
                                if !providers.contains("apple.com") {
                                    DispatchQueue.main.async {
                                        completion(false, "This email is registered with password. Please sign in with your password.")
                                    }
                                    return
                                }
                                // Proceed with Apple login
                                await self?.completeAppleAuth(credential: credential, email: userEmail, fullName: fullName, isRegistration: false, completion: completion)
                            }
                        case .failure(let error):
                            print("DEBUG: (AuthService) (signInWithApple) Failed to check email provider - \(error.localizedDescription)")
                            DispatchQueue.main.async {
                                completion(false, "Error checking account. Please try again.")
                            }
                        }
                    }
                }
            } catch {
                print("DEBUG: (AuthService) Apple Sign-In failed - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false, "Apple Sign-In failed. Please try again.")
                }
            }
        }
    }
    
    private func completeAppleAuth(credential: AuthCredential, email: String?, fullName: String?, isRegistration: Bool, completion: @escaping (Bool, String?) -> Void) async {
        do {
            let authResult = try await Auth.auth().signIn(with: credential)
            let uid = authResult.user.uid
            
            if isRegistration {
                // Create new user with Apple provider
                let userEmail = email ?? authResult.user.email
                self.createUserWithProvider(uid: uid, email: userEmail, fullName: fullName, provider: "apple.com", completion: completion)
            } else {
                // Existing user, just complete login
                print("DEBUG: (AuthService) Email:\(email ?? authResult.user.email ?? "unknown") - Apple login successful")
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }
        } catch {
            print("DEBUG: (AuthService) Firebase Apple Sign-In failed - \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(false, "Authentication failed. Please try again.")
            }
        }
    }
    
    // MARK: - Helper: Create User with Provider
    
    private func createUserWithProvider(uid: String, email: String?, fullName: String?, provider: String, completion: @escaping (Bool, String?) -> Void) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        let username = generateUsername(from: email)
        let displayName = fullName ?? email?.components(separatedBy: "@").first ?? "User"
        
        let data: [String: Any] = [
            "uid": uid,
            "email": email ?? "",
            "username": username,
            "fullName": displayName,
            "role": "member",
            "authProviders": [provider],
            "createdAt": Timestamp(date: Date()),
            "website": "",
            "phoneNumber": "",
            "bio": "",
            "followersCount": 0,
            "followingCount": 0
        ]
        
        userRef.setData(data) { error in
            if let error = error {
                print("DEBUG: (AuthService) Failed to create user document - \(error.localizedDescription)")
                completion(false, "Account created but profile setup failed. Please contact support.")
                return
            }
            print("DEBUG: (AuthService) New user created with \(provider): \(username)")
            completion(true, nil)
        }
    }
    
    // MARK: - Helper: Generate Username
    
    private func generateUsername(from email: String?) -> String {
        guard let email = email else {
            return "user_\(Int.random(in: 1000...9999))"
        }
        
        let baseUsername = email.components(separatedBy: "@").first ?? "user"
        let cleanUsername = baseUsername.lowercased().replacingOccurrences(of: "[^a-z0-9_]", with: "_", options: .regularExpression)
        
        // Add random suffix to ensure uniqueness
        let randomSuffix = Int.random(in: 1000...9999)
        return "\(cleanUsername)_\(randomSuffix)"
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
