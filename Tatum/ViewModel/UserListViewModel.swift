//
//  UserListViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import Combine

// Listenin ne türde olduğunu belirten enum
enum UserListType {
    case followers
    case following
}

class UserListViewModel: ObservableObject {
    @Published var users: [TatumUser] = []
    
    private let service: ProfileServiceProtocol
    let listType: UserListType // Dışarıdan okunabilsin diye private kaldırdık
    private let uid: String
    
    init(uid: String, type: UserListType, service: ProfileServiceProtocol = ProfileService()) {
        self.uid = uid
        self.listType = type
        self.service = service
        fetchUsers()
    }
    
    func fetchUsers() {
        switch listType {
        case .followers:
            service.fetchFollowers(uid: uid) { [weak self] users in
                self?.users = users
            }
        case .following:
            service.fetchFollowing(uid: uid) { [weak self] users in
                self?.users = users
            }
        }
    }
    
    // LİSTEDEN ÇIKARMA İŞLEMİ
    func performAction(for user: TatumUser, completion: @escaping (Bool) -> Void) {
        if listType == .followers {
            // Beni takip edeni çıkar
            service.removeFollower(uid: user.id) { [weak self] error in
                if error == nil {
                    self?.removeUserFromList(id: user.id)
                    completion(true) // Başarılı
                }
            }
        } else {
            // Takipten çık
            service.unfollow(uid: user.id) { [weak self] error in
                if error == nil {
                    self?.removeUserFromList(id: user.id)
                    completion(true) // Başarılı
                }
            }
        }
    }
    
    private func removeUserFromList(id: String) {
        DispatchQueue.main.async {
            self.users.removeAll { $0.id == id }
        }
    }
}
