//
//  LoginView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color("BackgroundDark")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo or Title
                Text("TATUM")
                    .font(.custom("Poppins-Bold", size: 40))
                    .foregroundColor(Color("BrandPurple"))
                    .padding(.bottom, 50)
                
                // Input Area
                VStack(spacing: 20) {
                    CustomTextField(imageName: "envelope", placeholderText: "Email", text: $email)
                    CustomTextField(imageName: "lock", placeholderText: "Password", isSecureField: true, text: $password)
                }
                .padding(.horizontal, 30)
                
                // Forget Password (Şimdilik İşlevsiz)
                HStack {
                    Spacer()
                    Button("Forget Password") {
                        // TODO
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, 32)
                .padding(.top, 4)
                
                // Login Button
                Button(action: {
                    viewModel.login(withEmail: email, password: password) { success, error in
                        if let error = error {
                            print("Error: \(error)") // İlerde kulanıcıya alert göstereceğiz
                        }
                    }
                }) {
                    Text("Sign In")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("BrandPurple"))
                        .cornerRadius(12)
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Register Instructions
                NavigationLink {
                    RegistrationView()
                        .navigationBarHidden(true)
                } label: {
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Text("Sign Up")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("BrandPurple"))
                    }
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    LoginView()
}
