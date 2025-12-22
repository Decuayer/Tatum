import SwiftUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var viewModel: ProfileViewModel
        
    @State private var selectedTab = "Likes"
    @State private var showSettings = false
    @State private var showEditProfile = false
    
    init(user: TatumUser) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
        _selectedTab = State(initialValue: user.role == "artist" ? "Portfolio" : "Likes")

    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // 1. Profil Başlığı (Foto + İsim + İstatistik)
                        headerView
                        
                        // 2. Butonlar (Edit Profile)
                        actionButtons
                        
                        // 3. Sekmeler (Kullanıcı rolüne göre değişir)
                        customTabBar
                        
                        // 4. Grid (İçerik)
                        postsGrid
                        
                        Spacer()
                    }
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            // AYARLAR MENÜSÜ (Sheet olarak açılır)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            // PROFİL DÜZENLEME (Sheet)
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .onAppear {
                print("🔄 ProfileView göründü, veriler yenileniyor...")
                
                viewModel.fetchUserPosts()
                viewModel.fetchLikedPosts()
                
                if let uid = authViewModel.currentUser?.id {
                    authViewModel.fetchUser(uid: uid)
                }
            }
        }
    }
}

// MARK: - Components
extension ProfileView {
    
    // Header
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Text(authViewModel.currentUser?.username ?? "Profile")
                    .font(.custom("Poppins-Bold", size: 20))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Profil Fotosu ve Stats
            HStack(spacing: 24) {
                if let imageUrl = authViewModel.currentUser?.profileImageUrl, !imageUrl.isEmpty {
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
                    // Followers
                    NavigationLink(destination: UserListView(uid: authViewModel.currentUser?.id ?? "", type: .followers, title: "Followers").navigationBarHidden(true)) {
                        UserStatView(value: authViewModel.currentUser?.followersCount ?? 0, title: "Followers")
                    }
                    
                    NavigationLink(destination: UserListView(uid: authViewModel.currentUser?.id ?? "", type: .following, title: "Following").navigationBarHidden(true)) {
                        UserStatView(value: authViewModel.currentUser?.followingCount ?? 0, title: "Following")
                    }
                    
                    if authViewModel.currentUser?.role == "artist" {
                        UserStatView(value: viewModel.userPosts.count, title: "Posts")
                    }
                }
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
                if let bio = authViewModel.currentUser?.bio, !bio.isEmpty {
                    Text(bio)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(3)
                }
                
                if let website = authViewModel.currentUser?.website, !website.isEmpty {
                    Link(destination: URL(string: website.hasPrefix("http") ? website : "https://\(website)") ?? URL(string: "https://google.com")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "link")
                            Text(website)
                        }
                        .font(.caption)
                        .foregroundColor(Color("BrandPurple"))
                    }
                }
                
                if let phone = authViewModel.currentUser?.phoneNumber, !phone.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "phone.fill")
                        Text(phone)
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
    
    // Action Buttons
    private var actionButtons: some View {
        Button(action: { showEditProfile.toggle() }) {
            Text("Edit Profile")
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color("CardDark"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding()
    }
    
    // Custom Tab Bar
    private var customTabBar: some View {
        HStack {
            if authViewModel.currentUser?.role == "artist" {
                tabButton(title: "Portfolio")
            }
            
            tabButton(title: "Likes")
        }
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Color("BackgroundDark"))
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
    
    // Grid Content
    private var postsGrid: some View {
        
        let columns = [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ]
        return LazyVGrid(columns: columns, spacing: 2) {
            
            let posts = (selectedTab == "Portfolio") ? viewModel.userPosts : viewModel.likedPosts
            
            if posts.isEmpty && selectedTab == "Portfolio" {
                VStack {
                    Image(systemName: selectedTab == "Portfolio" ? "camera" : "heart.slash")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text(selectedTab == "Portfolio" ? "No posts yet" : "No likes yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            }
            
            ForEach(posts) { post in
                let postOwner = post.user ?? viewModel.user
                NavigationLink(destination: PostDetailView(post: post, user: postOwner)) {
                    
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

