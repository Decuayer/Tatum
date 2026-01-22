//
//  RootProfileView.swift
//  Tatum
//
//  Created by Demir Cücü on 20.01.2026.
//

import SwiftUI
import SDWebImageSwiftUI


struct RootProfileView : View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var selectedTab = "Portfolio"
    @State private var showSettings = false
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationView {
            Group {
                if authViewModel.isLoading {
                    ZStack {
                        Color("BackgroundDark").ignoresSafeArea()
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    }
                } else if let user = authViewModel.currentUser {
                    ProfileContent(
                        user: user, 
                        selectedTab: $selectedTab, 
                        showSettings: $showSettings, 
                        showEditProfile: $showEditProfile
                    )
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Could not load profile data.")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.gray)
                        
                        if let uid = authViewModel.userSession {
                            Button("Retry Fetch") {
                                authViewModel.isLoading = true
                                authViewModel.fetchUser(uid: uid)
                            }
                            .foregroundColor(Color("BrandPurple"))
                            .padding(.bottom, 10)
                        }
                        
                        Button(action: {
                            authViewModel.signOut()
                        }) {
                            Text("Log Out")
                                .font(.custom("Poppins-SemiBold", size: 16))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("BackgroundDark"))
                }
            }
        }
    }
}
