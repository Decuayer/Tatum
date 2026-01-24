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
            ScrollView {
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
                    
                    NavigationLink {
                        // TODO: Forget Password
                        Text("TODO: Forget Password")
                    } label: {
                        HStack {
                            Spacer()
                            Text("Forget Password")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 4)
                    }
                    
                    
                    
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
                    
                    // Divider with "OR" text
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        Text("OR")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                    
                    // Google Sign-In Button
                    Button(action: {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            viewModel.signInWithGoogle(presenting: rootViewController, isRegistration: false)
                        }
                    }) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.black)
                            Text("Continue with Google")
                                .font(.custom("Poppins-Bold", size: 16))
                                .foregroundColor(.black)
                        }
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isAuthenticating)
                    
                    // Apple Sign-In Button (Disabled - Requires Apple Developer Program)
                    // TODO: Enable when Apple Developer Program is active
                    Button(action: {
                        viewModel.signInWithApple(isRegistration: false)
                    }) {
                        HStack {
                            Image(systemName: "applelogo")
                                .foregroundColor(.white)
                            Text("Continue with Apple")
                                .font(.custom("Poppins-Bold", size: 16))
                                .foregroundColor(.white)
                        }
                        .frame(width: 300, height: 50)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    .disabled(true)
                    .opacity(0.5)
                    
                    
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
                .padding(.top, 40)
            }
            
        }
        .animation(.easeInOut, value: viewModel.errorMessage)
        .onAppear {
            viewModel.clearError()
        }
    }
}


