//
//  UserListViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import Combine

enum UserListType {
    case followers
    case following
}

class UserListViewModel: ObservableObject {
    @Published var users: [TatumUser] = []
    
    private let service: ProfileServiceProtocol
    let listType: UserListType
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
    
    func performAction(for user: TatumUser, completion: @escaping (Bool) -> Void) {
        // UI'dan hemen silmek için completion'ı beklemeden success dönebiliriz (Optimistic)
        // Ama veri tutarlılığı için servisi beklemek daha güvenli.
        
        if listType == .followers {
            // Beni takip edeni çıkar
            service.removeFollower(uid: user.id) { [weak self] error in
                if error == nil {
                    self?.removeUserFromList(id: user.id)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            // Takipten çık
            service.unfollow(uid: user.id) { [weak self] error in
                if error == nil {
                    self?.removeUserFromList(id: user.id)
                    completion(true)
                } else {
                    completion(false)
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
