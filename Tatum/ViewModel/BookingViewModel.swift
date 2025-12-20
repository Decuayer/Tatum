//
//  BookingViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 20.12.2025.
//

import Foundation
import Combine
import FirebaseCore


class BookingViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedTimeSlot: String?
    @Published var availableSlots: [String] = []
    
    private var bookedAppointments: [Appointment] = []
    
    var nextDays: [Date] {
        let calendar = Calendar.current
        return (0...6).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: Date())
        }
    }
    
    init() {
        generateTimeSlots()
        createMockAppointments()
    }
    
    func generateTimeSlots() {
        let slots = [
            "10:00", "11:00", "12:00", "13:00", "14:00",
            "15:00", "16:00", "17:00", "18:00", "19:00"
        ]
        self.availableSlots = slots
    }
    
    private func createMockAppointments() {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        bookedAppointments = [
            // Bugün saat 14:00 dolu
            Appointment(id: "1", customerId: "user1", artistId: "artist1", studioId: "studio1", date: today, timeSlot: "14:00", status: "confirmed", createdAt: Timestamp(), price: 100),
            // Bugün saat 16:00 dolu
            Appointment(id: "2", customerId: "user2", artistId: "artist1", studioId: "studio1", date: today, timeSlot: "16:00", status: "confirmed", createdAt: Timestamp(), price: 100),
            // Yarın saat 11:00 dolu
            Appointment(id: "3", customerId: "user3", artistId: "artist1", studioId: "studio1", date: tomorrow, timeSlot: "11:00", status: "confirmed", createdAt: Timestamp(), price: 100)
        ]
    }
    
    func isSlotBooked(time: String) -> Bool {
        return bookedAppointments.contains { appointment in
            appointment.date.isSameDay(as: selectedDate) && appointment.timeSlot == time
        }
    }
    
    func selectSlot(_ slot: String) {
        selectedTimeSlot = slot
    }
}
