//
//  ClaimStudioView.swift
//  Tatum
//
//  Created by Demir Cücü on 22.12.2025.
//

import SwiftUI

struct ClaimStudioView: View {
    @StateObject var viewModel: ClaimStudioViewModel
    @Environment(\.dismiss) var dismiss
    
    init(studio: Studio) {
        _viewModel = StateObject(wrappedValue: ClaimStudioViewModel(studio: studio))
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundDark").ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Claim This Studio")
                    .font(.custom("Poppins-Bold", size: 24))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text(viewModel.studio.name)
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundColor(Color("BrandPurple"))
                
                Text("Complete the details below to verify your ownership and unlock studio features.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                
                Divider().background(Color.gray.opacity(0.3))
                
                // Form Fields
                VStack(spacing: 15) {
                    customTextField(title: "Phone Number", placeholder: "+90 555...", text: $viewModel.phoneNumber)
                    customTextField(title: "Website (Optional)", placeholder: "www.mystudio.com", text: $viewModel.website)
                    
                    VStack(alignment: .leading) {
                        Text("Bio / Description")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextEditor(text: $viewModel.bio)
                            .frame(height: 100)
                            .padding(8)
                            .scrollContentBackground(.hidden)
                            .background(Color("CardDark"))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.submitClaim()
                }) {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Verify & Claim")
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .background(Color("BrandPurple"))
                .cornerRadius(12)
                .alert("Success!", isPresented: $viewModel.isSuccess) {
                    Button("OK") { dismiss() }
                } message: {
                    Text("You have successfully claimed this studio. You can now manage it.")
                }
            }
            .padding(20)
        }
    }
    
    private func customTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            TextField(placeholder, text: text)
                .padding()
                .background(Color("CardDark"))
                .cornerRadius(8)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
