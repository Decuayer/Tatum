//
//  StoryView.swift
//  Tatum
//
//  Created by Demir Cücü on 24.12.2025.
//

import SwiftUI

struct StoryView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                VStack {
                    ZStack(alignment: .bottomTrailing) {
                        Image("decu")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                        
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(.blue)
                            .background(Color.white.clipShape(Circle()))
                            .offset(x: 5, y: 5)
                    }
                    
                    Text("Your Story")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.white)
                }
                
                ForEach(0..<6) { _ in
                    VStack {
                        Image("TestTattoo\((Int.random(in: 1...3)))")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(colors: [.yellow, .orange, .red, .purple], startPoint: .bottomLeading, endPoint: .topTrailing),
                                        lineWidth: 3
                                    )
                                    .padding(-3)
                            )
                        
                        Text("User Name")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
}
