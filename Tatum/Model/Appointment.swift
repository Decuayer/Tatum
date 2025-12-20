//
//  Appointment.swift
//  Tatum
//
//  Created by Demir Cücü on 20.12.2025.
//

import FirebaseFirestore

struct Appointment: Identifiable, Codable {
    let id: String
    let customerId: String
    let artistId: String?
    let studioId: String
    let date: Date
    let timeSlot: String
    let status: String
    let createdAt: Timestamp
    let price: Double
}
