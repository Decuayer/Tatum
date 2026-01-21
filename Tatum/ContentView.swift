//
//  ContentView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct ContentView: View {
    // Bind ViewModel here
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                // If user session exists, go to main
                MainTabView()
            } else {
                // Otherwise go to onboarding
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
