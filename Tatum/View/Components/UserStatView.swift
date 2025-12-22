//
//  UserStatView.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import SwiftUI
import SDWebImageSwiftUI

// İstatistik Bileşeni
struct UserStatView: View {
    let value: Int
    let title: String
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
            Text(title)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.gray)
        }
    }
}
