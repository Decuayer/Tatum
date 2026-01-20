//
//  FeedCall.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct FeedCall: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image("decu")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                
                Text("Demir Cücü") // Placeholder
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 8)
            .padding(.bottom, 4)
            
            Image("TestTattoo1")
                .resizable()
                .scaledToFill()
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .clipped()
            
            HStack {
                Button(action: {}) {
                    Image(systemName: "heart")
                        .resizable()
                        .frame(width: 22, height: 20)
                        .foregroundColor(.white)
                }
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                Button(action: {}) {
                    Image(systemName: "paperplane")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.top, 4)
            .padding(.leading, 8)
            
            Text("23 Likes")
                .font(.custom("Poppins-Bold", size: 14))
                .foregroundColor(.white)
                .padding(.leading, 8)
                .padding(.top, 2)
            
            HStack {
                Text("polenaktar")
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.white) +
                Text(" Amazing new ink design based on geometry.")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)
            .padding(.top, 1)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    FeedCall()
}
