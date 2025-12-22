//
//  StudioService.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import MapKit
import FirebaseFirestore

protocol StudioServiceProtocol {
    func searchStudios(region: MKCoordinateRegion, completion: @escaping ([Studio]) -> Void)
}

class StudioService: StudioServiceProtocol {
    
    func searchStudios(region: MKCoordinateRegion, completion: @escaping ([Studio]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Tattoo"
        request.region = region
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            guard let response = response else {
                print("DEBUG: Arama hatası: \(error?.localizedDescription ?? "Bilinmeyen hata")")
                completion([])
                return
            }
            
            let foundStudios = response.mapItems.map { item -> Studio in
                
                let placemark = item.placemark
                let addressComponents = [
                    placemark.thoroughfare,       // Cadde/Sokak
                    placemark.subThoroughfare,    // Kapı No
                    placemark.locality,           // İlçe
                    placemark.administrativeArea  // İl
                ].compactMap { $0 }
                
                let formattedAddress = addressComponents.isEmpty ? "Adres Bilgisi Yok" : addressComponents.joined(separator: ", ")
                
                return Studio(
                    id: UUID().uuidString,
                    name: item.name ?? "Unknown Studio",
                    address: formattedAddress,
                    ownerId: nil,
                    rating: 0.0,
                    imageUrl: "",
                    latitude: placemark.coordinate.latitude,
                    longitude: placemark.coordinate.longitude,
                    phoneNumber: item.phoneNumber,
                    isClaimed: false
                )
            }
            
            completion(foundStudios)
        }
    }
    
    func claimStudio(studio: Studio, extraData: [String: Any], completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        
        var newStudioData: [String: Any] = [
            "id": studio.id,
            "name": studio.name,
            "address": studio.address,
            "latitude": studio.latitude,
            "longitude": studio.longitude,
            "isClaimed": true,
            "rating": 0.0,
            "imageUrl": "",
            "createdAt": Timestamp()
        ]
        
        newStudioData.merge(extraData) { (_, new) in new }
        
        db.collection("studios").document(studio.id).setData(newStudioData) { error in
            if let error = error {
                print("Error claiming studio: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Studio successfully claimed!")
                completion(true)
            }
        }
    }
    
    func fetchClaimedStudios(completion: @escaping ([Studio]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("studios").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching claimed studios: \(error?.localizedDescription ?? "")")
                completion([])
                return
            }
            
            let studios = documents.compactMap { doc -> Studio? in
                let data = doc.data()
                return Studio(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "Unknown",
                    address: data["address"] as? String ?? "",
                    ownerId: data["ownerId"] as? String,
                    rating: data["rating"] as? Double ?? 0.0,
                    imageUrl: data["imageUrl"] as? String ?? "",
                    latitude: data["latitude"] as? Double ?? 0.0,
                    longitude: data["longitude"] as? Double ?? 0.0,
                    phoneNumber: data["phoneNumber"] as? String,
                    isClaimed: true
                )
            }
            completion(studios)
        }
    }
}
