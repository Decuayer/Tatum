//
//  Studio.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import CoreLocation

struct Studio: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let address: String
    var ownerId: String?  // User who claimed/owns this studio
    var rating: Double
    var imageUrl: String  // Primary/cover image
    let latitude: Double
    let longitude: Double
    var phoneNumber: String?
    var isClaimed: Bool
    
    // Carousel/Gallery support
    var galleryImages: [String]?  // Array of image URLs for studio carousel
    
    // Employee/Artist management
    var employeeIds: [String]?    // Array of artist UIDs affiliated with this studio
    
    // Additional business info
    var bio: String?              // Studio description
    var website: String?          // Studio website
    var instagramHandle: String?  // Instagram username
    var email: String?            // Contact email
    
    // Business hours (optional, can be expanded to structured data later)
    var businessHours: String?    // e.g., "Mon-Fri: 10AM-8PM"
    
    // Specialties/Services
    var specialties: [String]?    // Array of TattooCategory raw values
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Gallery Helpers
extension Studio {
    /// All images including cover + gallery
    var allImages: [String] {
        var images = [imageUrl]
        if let gallery = galleryImages {
            images.append(contentsOf: gallery)
        }
        return images
    }
    
    /// Whether studio has a gallery carousel
    var hasGallery: Bool {
        (galleryImages?.count ?? 0) > 0
    }
    
    /// Total image count
    var imageCount: Int {
        allImages.count
    }
}

// MARK: - Employee Helpers
extension Studio {
    /// Whether studio has affiliated artists
    var hasEmployees: Bool {
        (employeeIds?.count ?? 0) > 0
    }
    
    /// Number of affiliated artists
    var employeeCount: Int {
        employeeIds?.count ?? 0
    }
}

// MARK: - Specialties Helpers
extension Studio {
    /// Type-safe category accessors
    var studioSpecialties: [TattooCategory] {
        (specialties ?? []).compactMap { TattooCategory(rawValue: $0) }
    }
}
