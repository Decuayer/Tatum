//
//  AuthViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine


class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: TatumUser?
    
    init() {
        self.userSession = Auth.auth().currentUser
        fetchUser()
    }
    
    //MARK: - Login Function
    func login(withEmail email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            self.userSession = result?.user
            self.fetchUser()
            completion(true, nil)
        }
    }
    
    //MARK: - Register Function
    func register(withEmail email: String, password: String, fullname: String, username: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            // Firestore save user data
            let data: [String: Any] = [
                "uid": uid,
                "email": email,
                "username": username,
                "fullname": fullname,
                "role": "member", // Varsayılan olarak üye
                "followersCount": 0,
                "followingCount": 0,
                "createdAt": Timestamp(date: Date())
            ]
            
            Firestore.firestore().collection("users").document(uid).setData(data) { _ in
                self.userSession = result?.user
                self.fetchUser()
                completion(true, nil)
            }
        }
    }
    
    
    //MARK: - Extracting User Information
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("User data could not be retrieved, \(error.localizedDescription)")
                return
            }
            
            // Buraya basit bir manuel mapping yapıyoruz (TatumUser struct'ına uygun)
            guard let data = snapshot?.data() else { return }
            self.currentUser = TatumUser(
                id: data["uid"] as? String ?? "",
                email: data["email"] as? String ?? "",
                username: data["username"] as? String ?? "",
                fullName: data["fullName"] as? String ?? "",
                profileImageUrl: data["profileImageUrl"] as? String,
                role: data["role"] as? String ?? "member",
                bio: data["bio"] as? String,
                followersCount: data["followersCount"] as? Int ?? 0,
                followingCount: data["followingCount"] as? Int ?? 0
            )
        }
    }
    
    
    //MARK: - Sign Out Function
    func signOut() {
            try? Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        }
}
