//
//  AuthViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import Combine
import UIKit


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
    
    //MARK: - Google Sign-In Function
    func signInWithGoogle(presenting: UIViewController, isRegistration: Bool = false) {
        isAuthenticating = true
        errorMessage = nil
        
        service.signInWithGoogle(presenting: presenting, isRegistration: isRegistration) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthenticating = false
                if let error = error {
                    self?.errorMessage = error
                } else if success {
                    print("DEBUG: (AuthViewModel) Google Sign-In successful")
                }
            }
        }
    }
    
    func signInWithApple(isRegistration: Bool = false) {
        isAuthenticating = true
        errorMessage = nil
        
        service.signInWithApple(isRegistration: isRegistration) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthenticating = false
                if let error = error {
                    self?.errorMessage = error
                } else if success {
                    print("DEBUG: (AuthViewModel) Apple Sign-In successful")
                }
            }
        }
    }
    
    
    //MARK: - Update User Profile
    func updateUserProfile(
        fullName: String,
        username: String?,
        bio: String?,
        website: String?,
        phoneNumber: String?,
        profileImage: UIImage?,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard let uid = userSession else {
            completion(false, "No authenticated user found.")
            return
        }
        
        isAuthenticating = true
        errorMessage = nil
        
        let profileService = ProfileService()
        
        // Step 1: Upload image if provided
        if let image = profileImage {
            profileService.uploadProfileImage(image: image, uid: uid) { [weak self] imageUrl, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.isAuthenticating = false
                        self?.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                        completion(false, self?.errorMessage)
                    }
                    return
                }
                
                // Step 2: Update profile with image URL
                self?.updateProfileData(
                    uid: uid,
                    fullName: fullName,
                    username: username,
                    bio: bio,
                    website: website,
                    phoneNumber: phoneNumber,
                    profileImageUrl: imageUrl,
                    profileService: profileService,
                    completion: completion
                )
            }
        } else {
            // No image to upload, just update profile data
            updateProfileData(
                uid: uid,
                fullName: fullName,
                username: username,
                bio: bio,
                website: website,
                phoneNumber: phoneNumber,
                profileImageUrl: nil,
                profileService: profileService,
                completion: completion
            )
        }
    }
    
    private func updateProfileData(
        uid: String,
        fullName: String,
        username: String?,
        bio: String?,
        website: String?,
        phoneNumber: String?,
        profileImageUrl: String?,
        profileService: ProfileService,
        completion: @escaping (Bool, String?) -> Void
    ) {
        var updateData: [String: Any] = [
            "fullName": fullName
        ]
        
        if let username = username {
            updateData["username"] = username
        }
        
        if let bio = bio {
            updateData["bio"] = bio
        }
        
        if let website = website {
            updateData["website"] = website
        }
        
        if let phoneNumber = phoneNumber {
            updateData["phoneNumber"] = phoneNumber
        }
        
        if let imageUrl = profileImageUrl {
            updateData["profileImageUrl"] = imageUrl
        }
        
        profileService.updateUserProfile(uid: uid, data: updateData) { [weak self] error in
            DispatchQueue.main.async {
                self?.isAuthenticating = false
                
                if let error = error {
                    self?.errorMessage = "Failed to update profile: \(error.localizedDescription)"
                    completion(false, self?.errorMessage)
                } else {
                    // Refresh current user data
                    self?.fetchUser(uid: uid)
                    completion(true, nil)
                }
            }
        }
    }
    
    //MARK: - Clear Error
    func clearError() {
        errorMessage = nil
    }
}

