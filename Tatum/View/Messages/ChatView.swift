//
//  ChatView.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import SwiftUI

struct ChatView: View {
    
    @StateObject var viewModel = ChatViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Klavyeyi yönetmek için
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. HEADER (Kişi Bilgisi)
            headerView
            
            // 2. MESAJ LİSTESİ
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(
                                message: message,
                                isFromCurrentUser: message.fromId == "currentUser"
                            )
                        }
                    }
                    .padding(.top)
                }
                // Mesaj eklenince en alta kaydır
                .onChange(of: viewModel.messages.count) { oldValue, newValue in
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            // 3. INPUT ALANI
            inputBar
        }
        .background(Color("BackgroundDark").ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

extension ChatView {
    
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .padding(8)
            }
            
            Image("welcome_img_1") // Profil fotosu
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text("Factor Tattoo")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                Text("Online")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Image(systemName: "phone.fill")
                .foregroundColor(.gray)
                .padding(.trailing, 10)
        }
        .padding()
        .background(Color("CardDark"))
    }
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $viewModel.messageText)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.white)
                .padding(12)
                .background(Color("CardDark"))
                .cornerRadius(20)
                .focused($isFocused)
            
            Button(action: {
                viewModel.sendMessage()
                isFocused = false // Klavye kapansın istersen
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("BrandPurple"))
                    .rotationEffect(.degrees(45))
                    .padding(10)
                    .background(Color("CardDark"))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color("BackgroundDark"))
    }
}
