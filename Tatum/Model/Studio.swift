//
//  Studio.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import CoreLocation

struct Studio: Identifiable, Codable {
    let id: String
    let name: String
    let address: String
    var ownerId: String? 
    var rating: Double
    var imageUrl: String
    let latitude: Double
    let longitude: Double
    var phoneNumber: String?
    var isClaimed: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
