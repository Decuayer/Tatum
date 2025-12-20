//
//  ContentView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct ContentView: View {
    // ViewModel'i buraya bağlıyoruz
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                // Eğer kullanıcı oturumu varsa anasayfaya git
                MainTabView()
            } else {
                // Yoksa karşılama ekranına git
                NavigationView {
                    OnboardingView()
                }
            }
        }
    }
}



#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
