//
//  Category.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation

struct Category: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let iconName: String // SF Symbol veya asset ismi
}

let sampleCategories: [Category] = [
    Category(title: "All", iconName: "square.grid.2x2"),
    Category(title: "Blackwork", iconName: "hand.raised"),
    Category(title: "Old School", iconName: "star"),
    Category(title: "Realism", iconName: "eye"),
    Category(title: "Japanese", iconName: "sun.max"),
    Category(title: "Minimal", iconName: "leaf")
]
