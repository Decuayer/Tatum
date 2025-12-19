//
//  ProfileView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color("BackgroundDark")
                .ignoresSafeArea()
            
            VStack {
                // Üst Başlık
                Text("Profile")
                    .font(.custom("Poppins-Bold", size: 24))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Spacer()
                
                // Geçici Kullanıcı Bilgisi (Kim girdi görelim)
                
                if let user = viewModel.currentUser {
                    Text(user.username)
                        .font(.custom("Poppins-Bold", size: 20))
                        .foregroundColor(.white)
                                    
                    Text(user.email)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                
                
                // Log Out Button
                Button(action: {
                    viewModel.signOut()
                }) {
                    Text("Log Out")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    ProfileView()
}
