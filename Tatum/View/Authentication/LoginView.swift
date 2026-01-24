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
                Text("TATUM")
                    .font(.custom("Poppins-Bold", size: 40))
                    .foregroundColor(Color("BrandPurple"))
                    .padding(.bottom, 50)
                
                
                
                VStack(spacing: 20) {
                    CustomTextField(imageName: "envelope", placeholderText: "Email", text: $email)
                    CustomTextField(imageName: "lock", placeholderText: "Password", isSecureField: true, text: $password)
                }
                .padding(.horizontal, 30)
                
                HStack {
                    Spacer()
                    Button("Forget Password") {
                        // TODO : Forget Password
                        print("TODO: Forget Password")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, 32)
                .padding(.top, 4)
                
                Button(action: {
                    viewModel.login(withEmail: email, password: password) { success, error in
                    }
                }) {
                    if viewModel.isAuthenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: 300, height: 50)
                            .background(Color("BrandPurple").opacity(0.7))
                            .cornerRadius(12)
                    } else {
                        Text("Sign In")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color("BrandPurple"))
                            .cornerRadius(12)
                    }
                }
                .disabled(viewModel.isAuthenticating)
                .padding(.top, 24)
                
                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            viewModel.clearError()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Spacer()
                
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
        .animation(.easeInOut, value: viewModel.errorMessage)
        .onAppear {
            viewModel.clearError()
        }
    }
}


