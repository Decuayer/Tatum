//
//  StudioService.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import Combine

//MARK: - Protocol
protocol StudioServiceProtocol {
    func fetchStudios(completion: @escaping ([Studio]) -> Void)
}

//MARK: - Class
class StudioService: StudioServiceProtocol {
    
    func fetchStudios(completion: @escaping ([Studio]) -> Void) {
        // Şimdilik test için sahte veri
        // Buraya Firestore kodu gelecek.
        let mockStudios = [
            Studio(id: "1", name: "Factor Tattoo", ownerId: "uid1", address: "Kadikoy, Istanbul", rating: 9.0, imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQ2Ytiu-OZ0GwMFSTkeQYn1bSO2V-fpmNAwQ&s", latitude: 40.9829, longitude: 29.0282),
            Studio(id: "2", name: "Cleopatra Ink", ownerId: "uid2", address: "Besiktas, Istanbul", rating: 9.4, imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQ2Ytiu-OZ0GwMFSTkeQYn1bSO2V-fpmNAwQ&s", latitude: 41.0422, longitude: 29.0060),
            Studio(id: "3", name: "Iron & Ink", ownerId: "uid3", address: "Sisli, Istanbul", rating: 8.8, imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQ2Ytiu-OZ0GwMFSTkeQYn1bSO2V-fpmNAwQ&s", latitude: 41.0600, longitude: 28.9870)
        ]
        
        completion(mockStudios)
    }
}
