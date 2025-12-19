//
//  OnboardingView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentTab = 0
    
    var body: some View {
        ZStack {
            // Background color
            Color("BackgroundDark")
                .ignoresSafeArea()
            
            VStack {
                // Slider Area
                TabView(selection: $currentTab) {
                    OnboardingPageView(imageName: "BackgroundTestImage", title: "TATUM", description: "Let's discover a new skin adventure.")
                        .tag(0)
                    OnboardingPageView(imageName: "BackgroundTestImage", title: "Can't decide?", description: "Find the best styles for you.")
                        .tag(1)
                                        
                    OnboardingPageView(imageName: "BackgroundTestImage", title: "Let artists find you.", description: "Connect with the best studios.")
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Alt Butonlar (Sadece son slaytta veya her zaman gösterilecekse ona göre ayarlarız)
                // Tasarımda son slaytta butonlar var, şimdilik basit bir geçiş butonu koyuyorum:
                
                if currentTab == 2 {
                    NavigationLink(destination: LoginView().navigationBarHidden(true)) {
                        Text("Get Started")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("BrandPurple"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                } else {
                    // Son sayfa değilse Next butonu
                    Button(action: {
                        withAnimation {
                            currentTab += 1
                        }
                    }) {
                        Text("Next")
                            .font(.custom("Poppins-Bold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("BrandPurple"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

//MARK: - Single Page Design

struct OnboardingPageView: View {
    var imageName: String
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
            
            Text(title)
                .font(.custom("Poppins-Bold", size: 28))
                .foregroundColor(.white)
            
            Text(description)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    OnboardingView()
}
