//
//  ClaimStudioModel.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import Foundation
import FirebaseAuth
import Combine

class ClaimStudioViewModel: ObservableObject {
    @Published var bio: String = ""
    @Published var website: String = ""
    @Published var phoneNumber: String = ""
    @Published var isLoading = false
    @Published var isSuccess = false
    
    private let service: StudioService
    let studio: Studio
    
    init(studio: Studio, service: StudioService = StudioService()) {
        self.studio = studio
        self.service = service
        self.phoneNumber = studio.phoneNumber ?? ""
    }
    
    func submitClaim() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        let extraData: [String: Any] = [
            "ownerId": currentUid,
            "bio": bio,
            "website": website,
            "phoneNumber": phoneNumber,
            "role": "studio"
        ]
        
        service.claimStudio(studio: studio, extraData: extraData) { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isSuccess = success
            }
        }
    }
}
