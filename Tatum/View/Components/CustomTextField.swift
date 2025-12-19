//
//  CustomTextField.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct CustomTextField: View {
    let imageName: String
    let placeholderText: String
    var isSecureField: Bool = false
    @Binding var text: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color("BrandPurple"))
                if isSecureField {
                    SecureField(placeholderText, text: $text)
                        .foregroundColor(.white)
                } else {
                    TextField(placeholderText, text: $text)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                }
            }
            
            Divider()
                .background(Color("BrandPurple"))
        }
        .padding(.vertical, 8)
    }
}
