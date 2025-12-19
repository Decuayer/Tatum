//
//  ContentViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import FirebaseAuth
import Combine

class ContentViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        // Firebase Auth durumunu dinle (Giriş yaptı mı, Çıkış yaptı mı?)
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.userSession = user
        }
    }
}
