//
//  AuthViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import Combine


class AuthViewModel: ObservableObject {
    @Published var userSession: String?
    @Published var currentUser: TatumUser?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var isAuthenticating = false
    
    private let service: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(service: AuthServiceProtocol = AuthService()) {
        self.service = service
        self.setupSubscribers()
    }
    
    //MARK: - Service Listener
    private func setupSubscribers() {
        service.userSessionPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] uid in
                self?.userSession = uid
                
                print("DEBUG: User Session Changed -> \(String(describing: uid))")
                
                if let uid = uid {
                    self?.isLoading = true
                    self?.fetchUser(uid: uid)
                } else {
                    self?.currentUser = nil
                    self?.isLoading = false
                    
                    print("DEBUG: No session, isLoading is set to false.")
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Login Function
    func login(withEmail email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        errorMessage = nil
        isAuthenticating = true
        
        service.login(withEmail: email, password: password) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthenticating = false
                
                if let error = error {
                    self?.errorMessage = error
                }
                
                completion(success, error)
            }
        }
    }
    
    //MARK: - Register Function
    func register(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping (Bool, String?) -> Void) {
        errorMessage = nil
        isAuthenticating = true
        
        service.register(withEmail: email, password: password, fullname: fullname, username: username) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthenticating = false
                
                if let error = error {
                    self?.errorMessage = error
                }
                
                completion(success, error)
            }
        }
    }
    
    //MARK: - Extracting User Information
    func fetchUser(uid: String) {
        print("DEBUG: (AuthViewModel) UserID:\(uid) Fetch User Started.")
        service.fetchUser(uid: uid) { [weak self] user in
            self?.currentUser = user
            self?.isLoading = false
            
            if let user = user {
                print("DEBUG: (AuthViewModel) UserID:\(uid) User Uploaded: \(user.username)")
            } else {
                print("DEBUG: (AuthViewModel) UserID:\(uid) User returned NIL.")
            }
        }
    }
    
    //MARK: - Sign Out Function
    func signOut() {
        service.signOut()
        self.currentUser = nil
        self.isLoading = false
    }
    
    //MARK: - TESTING NOT SURE
    func updateFollowingCount(increment: Bool) {
        guard var user = currentUser else { return }
        if increment {
            user.followingCount += 1
        } else {
            user.followingCount = max(0, user.followingCount - 1)
        }
        self.currentUser = user
    }
    
    //MARK: - Clear Error
    func clearError() {
        errorMessage = nil
    }
}
