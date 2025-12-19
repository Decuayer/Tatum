//
//  RegistrationView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var username = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        ZStack {
            Color("BackgroundDark")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("Create Account")
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
                
                // Input Area
                VStack(spacing: 20) {
                    CustomTextField(imageName: "envelope", placeholderText: "Email", text: $email)
                    CustomTextField(imageName: "person", placeholderText: "Full Name", text: $fullname)
                    CustomTextField(imageName: "person.text.rectangle", placeholderText: "Username", text: $username)
                    CustomTextField(imageName: "lock", placeholderText: "Password", isSecureField: true, text: $password)
                }
                .padding(.horizontal, 32)
                
                // Sign Up Button
                Button(action: {
                    viewModel.register(withEmail: email, password: password, fullname: fullname, username: username) { success, error in
                        if success {
                            // Başarılıysa sayfayı kapat (Zaten AuthState değişeceği için ContentView ana sayfaya atacak)
                            mode.wrappedValue.dismiss()
                        } else {
                            print("Register error, \(error ?? "")")
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color("BrandPurple"))
                        .cornerRadius(12)
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Go Back Button
                Button(action: {mode.wrappedValue.dismiss() }) {
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Text("Sign In")
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
    RegistrationView()
}
