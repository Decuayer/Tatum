//
//  FeedView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 30) {
                        // Şimdilik 10 tane sahte post gösterelim
                        ForEach(0..<10) { _ in
                            FeedCall()
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("TATUM")
                        .font(.custom("Poppins-Bold", size: 24))
                        .foregroundColor(Color("BrandPurple"))
                }
            }
        }
    }
}

#Preview {
    FeedView()
}
