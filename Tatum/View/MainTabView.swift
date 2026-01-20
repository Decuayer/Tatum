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
    
    func deneme(String: String) {
        print(String)
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
            InboxView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                }
            
            // 5. Profil
            RootProfileView()
                .tabItem {
                    Image(systemName: "person")
                }
        }
        .accentColor(Color("BrandPurple"))
    }
}

#Preview {
    MainTabView()
}
