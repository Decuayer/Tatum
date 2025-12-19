//
//  MainTabView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct MainTabView: View {
    // Seçili tab'ın rengini mor yapmak için init ayarı
    init() {
        UITabBar.appearance().backgroundColor = UIColor(named: "BackgroundDark")
        UITabBar.appearance().barTintColor = UIColor(named: "BackgroundDark")
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
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
            Text("Harita Sayfası")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("BackgroundDark"))
                .tabItem {
                    Image(systemName: "map")
                }
            
            // 4. Mesajlar
            Text("Mesajlar")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("BackgroundDark"))
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                }
            
            // 5. Profil
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                }
        }
        .accentColor(Color("BrandPurple")) // Seçili ikon rengi
    }
}

#Preview {
    MainTabView()
}
