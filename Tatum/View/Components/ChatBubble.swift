//
//  ChatBubble.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import SwiftUI

struct ChatBubble: View {
    let message: Message
    let isFromCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isFromCurrentUser { Spacer() }
            
            Text(message.text)
                .font(.custom("Poppins-Regular", size: 15))
                .foregroundColor(.white)
                .padding(12)
                .background(isFromCurrentUser ? Color("BrandPurple") : Color("CardDark"))
                .clipShape(ChatBubbleShape(isFromCurrentUser: isFromCurrentUser))
                .containerRelativeFrame(.horizontal, count: 4, span: 3, spacing: 0, alignment: isFromCurrentUser ? .trailing : .leading)
            if !isFromCurrentUser { Spacer() }
        }
        .padding(.horizontal, 8)
    }
}

struct ChatBubbleShape: Shape {
    let isFromCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isFromCurrentUser ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
}
