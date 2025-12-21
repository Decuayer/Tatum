//
//  AllUsersViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import Foundation
import Combine

class AllUsersViewModel: ObservableObject {
    @Published var users: [TatumUser] = []
    @Published var isLoading = false
    
    private let service: ProfileService // ServiceProtocol kullanmak daha doğru ama hızlı olması için direkt sınıfı aldım
    
    init() {
        self.service = ProfileService()
        fetchAllUsers()
    }
    
    func fetchAllUsers() {
        isLoading = true
        service.fetchAllUsers { [weak self] users in
            DispatchQueue.main.async {
                self?.users = users
                self?.isLoading = false
            }
        }
    }
    
    func deleteUser(user: TatumUser) {
        service.deleteUserFromFirestore(uid: user.id) { [weak self] error in
            if let error = error {
                print("Silme hatası: \(error.localizedDescription)")
            } else {
                // Başarılıysa listeden anında sil (UI Güncellemesi)
                DispatchQueue.main.async {
                    self?.users.removeAll { $0.id == user.id }
                }
            }
        }
    }
}
