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
    @Published var followStates: [String: Bool] = [:]  // userId: isFollowing
    @Published var loadingStates: [String: Bool] = [:]  // userId: isLoading
    
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
                self?.checkFollowStatesForAllUsers(users)
            }
        case .following:
            service.fetchFollowing(uid: uid) { [weak self] users in
                self?.users = users
                self?.checkFollowStatesForAllUsers(users)
            }
        }
    }
    
    
    private func checkFollowStatesForAllUsers(_ users: [TatumUser]) {
        // Her kullanıcı için aktif kullanıcının (current user) o kişiyi takip edip etmediğini kontrol et
        for user in users {
            loadingStates[user.id] = false
            
            // checkIfUserIsFollowed: Aktif kullanıcı bu user'ı takip ediyor mu?
            service.checkIfUserIsFollowed(uid: user.id) { [weak self] isFollowed in
                DispatchQueue.main.async {
                    self?.followStates[user.id] = isFollowed
                }
            }
        }
    }
    
    func toggleFollow(for user: TatumUser) {
        loadingStates[user.id] = true
        
        let isCurrentlyFollowing = followStates[user.id] ?? false
        
        if isCurrentlyFollowing {
            // Unfollow
            service.unfollow(uid: user.id) { [weak self] error in
                DispatchQueue.main.async {
                    self?.loadingStates[user.id] = false
                    if error == nil {
                        self?.followStates[user.id] = false
                    }
                }
            }
        } else {
            // Follow
            service.follow(uid: user.id) { [weak self] error in
                DispatchQueue.main.async {
                    self?.loadingStates[user.id] = false
                    if error == nil {
                        self?.followStates[user.id] = true
                    }
                }
            }
        }
    }
    
    func isFollowing(userId: String) -> Bool {
        return followStates[userId] ?? false
    }
    
    func isLoading(userId: String) -> Bool {
        return loadingStates[userId] ?? false
    }
}
