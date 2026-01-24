//
//  OnboardingPageView.swift
//  Tatum
//
//  Created by Demir Cücü on 24.01.2026.
//

import SwiftUI

struct OnboardingPageView: View {
    var imageName: String
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
            
            Text(title)
                .font(.custom("Poppins-Bold", size: 28))
                .foregroundColor(.white)
            
            Text(description)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}
