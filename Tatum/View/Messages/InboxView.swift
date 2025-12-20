//
//  InboxView.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import SwiftUI

struct InboxView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark").ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text("Messages")
                        .font(.custom("Poppins-Bold", size: 28))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(0..<5) { _ in
                                NavigationLink(destination: ChatView()) {
                                    InboxRow() // Aşağıda tanımlı
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct InboxRow: View {
    var body: some View {
        HStack(spacing: 16) {
            Image("decu")
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Factor Tattoo")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                    Spacer()
                    Text("14:30")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text("Harika fikir. Örnek bir görselin var mı?")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color("BackgroundDark")) // Tıklama efekti için arka plan
    }
}
