//
//  MainTabView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor(named: "BackgroundDark")
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        let selectedColor = UIColor(named: "BrandPurple") ?? UIColor.systemPurple
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            // 1. Anasayfa
            FeedView()
                .tabItem {
                    Image(systemName: "house")
                }
            
            // 2. Keşfet
            ExploreView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }
            
            // 3. Stüdyolar / Harita
            StudioView()
                .tabItem {
                    Image(systemName: "map")
                }
            
            // 4. Mesajlar
            InboxView() // GÜNCELLENDİ
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                }
            
            // 5. Profil
            if let user = authViewModel.currentUser {
                ProfileView(user: user)
                    .tabItem {
                        Image(systemName: "person")
                    }
            } else {
                // Veri yüklenemezse Çıkış Butonu göster
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Could not load profile data.")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        authViewModel.signOut() // Session'ı temizler ve Login'e atar
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
                .tabItem { Image(systemName: "person") }
            }
        }
        .accentColor(Color("BrandPurple"))
    }
}

#Preview {
    MainTabView()
}
