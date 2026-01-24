//
//  EmailRegistrationView.swift
//  Tatum
//
//  Created by Antigravity on 24.01.2026.
//

import SwiftUI

struct EmailRegistrationView: View {
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
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Text("Create Account")
                            .font(.custom("Poppins-Bold", size: 30))
                            .foregroundColor(.white)
                        
                        HStack {
                            Button(action: { mode.wrappedValue.dismiss() }) {
                                Image(systemName: "arrow.left")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color("CardDark"))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)

                    
                    VStack(spacing: 20) {
                        CustomTextField(imageName: "envelope", placeholderText: "Email", text: $email)
                        CustomTextField(imageName: "person", placeholderText: "Full Name", text: $fullname)
                        CustomTextField(imageName: "person.text.rectangle", placeholderText: "Username", text: $username)
                        CustomTextField(imageName: "lock", placeholderText: "Password", isSecureField: true, text: $password)
                    }
                    .padding(.horizontal, 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password requirements:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("• At least 6 characters")
                            .font(.caption2)
                            .foregroundColor(.gray)
                        Text("• At least one uppercase letter, one lowercase letter, and one symbol.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.top, 4)
                    
                    Button(action: {
                        viewModel.register(withEmail: email, password: password, fullname: fullname, username: username) { success, error in
                            if success {
                                mode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        if viewModel.isAuthenticating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 300, height: 50)
                                .background(Color("BrandPurple").opacity(0.7))
                                .cornerRadius(12)
                        } else {
                            Text("Sign Up")
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
                .padding(.top, 40)
            }
            
        }
        .animation(.easeInOut, value: viewModel.errorMessage)
        .onAppear {
            viewModel.clearError()
        }
        .navigationBarHidden(true)
    }
}

