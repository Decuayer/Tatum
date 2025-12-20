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
    let ownerId: String
    let address: String
    let rating: Double
    let imageUrl: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
