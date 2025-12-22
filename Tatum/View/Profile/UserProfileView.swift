//
//  UserProfileView.swift
//  Tatum
//
//  Created by Demir Cücü on 21.12.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserProfileView: View {
    @StateObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab = "Portfolio"
    
    init(user: TatumUser) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(user: user))
        _selectedTab = State(initialValue: user.role == "artist" ? "Portfolio" : "Likes")
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundDark").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // 1. Üst Bar (Geri Butonu)
                    navBar
                    
                    // 2. Profil Başlığı
                    headerView
                    
                    // 3. Aksiyon Butonları (Follow / Message)
                    actionButtons
                    
                    // 4. Sekmeler (Rol Bazlı)
                    customTabBar
                    
                    // 5. İçerik Grid
                    postsGrid
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            print("🔄 UserProfileView göründü, veriler yenileniyor...")
            
            viewModel.fetchUserPosts()
            viewModel.fetchLikedPosts()
            
            viewModel.refreshUserStats()
        }
    }
}

// MARK: - Components
extension UserProfileView {
    
    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("CardDark"))
                    .clipShape(Circle())
            }
            Spacer()
            
            // Sağ üstte "..." (Report/Block) menüsü olabilir
            Image(systemName: "ellipsis")
                .foregroundColor(.white)
                .rotationEffect(.degrees(90))
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // Header (Foto + Stats + Info)
    private var headerView: some View {
        VStack(spacing: 16) {
            
            HStack(spacing: 24) {
                if let imageUrl = viewModel.user.profileImageUrl, !imageUrl.isEmpty {
                    WebImage(url: URL(string: imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("BrandPurple"), lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 80, height: 80)
                }
                
                HStack(spacing: 24) {
                    NavigationLink(destination: UserListView(uid: viewModel.user.id, type: .followers, title: "Followers")) {
                        UserStatView(value: viewModel.followersCount, title: "Followers")
                    }
                    
                    // Following
                    NavigationLink(destination: UserListView(uid: viewModel.user.id, type: .following, title: "Following")) {
                        UserStatView(value: viewModel.followingCount, title: "Following")
                    }
                    
                    // Posts
                    if viewModel.user.role == "artist" {
                        UserStatView(value: viewModel.posts.count, title: "Posts")
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(viewModel.user.fullName)
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.white)
                    
                    if viewModel.user.role == "artist" {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color("BrandPurple"))
                            .font(.caption)
                    }
                }
                
                if let bio = viewModel.user.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
                
                // Web Sitesi
                if let website = viewModel.user.website, !website.isEmpty {
                    Link(destination: URL(string: website.hasPrefix("http") ? website : "https://\(website)") ?? URL(string: "https://google.com")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                            Text(website)
                        }
                        .font(.caption)
                        .foregroundColor(Color("BrandPurple"))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
    
    // FOLLOW & MESSAGE BUTONLARI (En Kritik Kısım)
    private var actionButtons: some View {
        HStack(spacing: 12) {
            
            // 1. TAKİP BUTONU
            Button(action: {
                if viewModel.isFollowed {
                    viewModel.unfollow()
                } else {
                    viewModel.follow()
                }
            }) {
                Text(viewModel.isFollowed ? "Following" : "Follow")
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        // Takip ediliyorsa Gri, Edilmiyorsa Mor
                        viewModel.isFollowed ? Color("CardDark") : Color("BrandPurple")
                    )
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: viewModel.isFollowed ? 1 : 0)
                    )
            }
            .animation(.easeInOut, value: viewModel.isFollowed) // Renk değişimi yumuşak olsun
            
            // 2. MESAJ BUTONU
            NavigationLink(destination: ChatView(user: viewModel.user)) {
                Text("Message")
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color("CardDark"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
    }
    
    private var customTabBar: some View {
        HStack {
            if viewModel.user.role == "artist" {
                tabButton(title: "Portfolio")
            }
            tabButton(title: "Likes") // Başkasının beğendiklerini görmek opsiyonel olabilir
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    private func tabButton(title: String) -> some View {
        VStack {
            Text(title)
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(selectedTab == title ? .white : .gray)
            
            if selectedTab == title {
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color("BrandPurple"))
            } else {
                Rectangle().frame(height: 2).foregroundColor(.clear)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation { selectedTab = title }
        }
    }
    
    // Grid (Şimdilik Mock Data veya ViewModel'deki postlar)
    private var postsGrid: some View {
        // Grid ayarları (Boşluklar ve Sütunlar)
        let columns = [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ]
        
        return LazyVGrid(columns: columns, spacing: 2) {
            
            if viewModel.posts.isEmpty && selectedTab == "Portfolio" {
                VStack {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No posts yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            }
            
            ForEach(viewModel.posts) { post in
                
                NavigationLink(destination: PostDetailView(post: post, user: viewModel.user)) {
                    
                    WebImage(url: URL(string: post.imageUrl))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                        .background(Color("CardDark"))
                    
                }
                .buttonStyle(.plain)
            }
        }
    }
}
