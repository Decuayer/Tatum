//
//  Date+Ext.swift
//  Tatum
//
//  Created by Demir Cücü on 20.12.2025.
//

import Foundation

extension Date {
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }
}
