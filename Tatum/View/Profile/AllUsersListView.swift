//
//  AllUsersListView.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

//MARK: - DEVTOOL

import SwiftUI
import SDWebImageSwiftUI

struct AllUsersListView: View {
    @StateObject var viewModel = AllUsersViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("BackgroundDark").ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .colorScheme(.dark)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.users) { user in
                            AdminUserRow(user: user) {
                                // Silme aksiyonu tetiklendiğinde
                                viewModel.deleteUser(user: user)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("All Users Database")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(viewModel.users.count) Users")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        
    }
}

// Özel Admin Satırı (Silme Butonlu)
struct AdminUserRow: View {
    let user: TatumUser
    var onDelete: () -> Void
    
    @State private var showConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: TatumProfileView(user: user)) {
                HStack {
                    if let imageUrl = user.profileImageUrl, !imageUrl.isEmpty {
                        WebImage(url: URL(string: imageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(user.username)
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(.white)
                            if user.isArtist {
                                Image(systemName: "paintbrush.fill")
                                    .font(.caption2)
                                    .foregroundColor(Color("BrandPurple"))
                            }
                        }
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                showConfirmation = true
            }) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
                    .padding(10)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .alert("Delete User?", isPresented: $showConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("This will remove '\(user.username)' from Firestore immediately. Auth deletion requires backend.")
            }
        }
        .padding(12)
        .background(Color("CardDark"))
        .cornerRadius(12)
    }
}
