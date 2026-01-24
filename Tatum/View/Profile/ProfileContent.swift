import SwiftUI
import SDWebImageSwiftUI

struct ProfileContent: View {
    let user: TatumUser
    @StateObject var viewModel: TatumProfileViewModel
    @Binding var selectedTab: String
    @Binding var showSettings: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    
    init(user: TatumUser, selectedTab: Binding<String>, showSettings: Binding<Bool>) {
        self.user = user
        _viewModel = StateObject(wrappedValue: TatumProfileViewModel(user: user))
        _selectedTab = selectedTab
        _showSettings = showSettings
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundDark").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    customNavBar
                    
                    headerView
                        .padding(.top, 20)
                    
                    actionButtons
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    customTabBar
                        .zIndex(1)
                    
                    postsGrid
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
            .refreshable {
                viewModel.loadUserData()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            print("DEBUG: ProfileContent has appeared, data is being refreshed.")
            
            viewModel.loadUserData()
            
            if viewModel.user.isCurrentUser {
                if let uid = authViewModel.currentUser?.id {
                    authViewModel.fetchUser(uid: uid)
                }
            }
        }
    }
}

// MARK: - Components
extension ProfileContent {
    
    private var customNavBar: some View {
        ZStack {
            Text(viewModel.user.username)
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            
            HStack {
                Spacer()
                
                if viewModel.user.isCurrentUser {
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                } else {
                    Button(action: {
                        print("User more")
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(90))
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
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
                        UserStatView(value: viewModel.user.followersCount, title: "Followers")
                    }
                    
                    NavigationLink(destination: UserListView(uid: viewModel.user.id, type: .following, title: "Following")) {
                        UserStatView(value: viewModel.user.followingCount, title: "Following")
                    }
                    
                    if viewModel.user.isArtist {
                        UserStatView(value: viewModel.posts.count, title: "Posts")
                    }
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(viewModel.user.fullName)
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.white)
                    
                    if viewModel.user.isArtist {
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
        .padding(.horizontal)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            if viewModel.user.isCurrentUser {
                NavigationLink(destination: EditProfileView()) {
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
                .buttonStyle(.plain)
            } else {
                Button(action: {
                    viewModel.isFollowed ? viewModel.unfollow() : viewModel.follow()
                }) {
                    Text(viewModel.isFollowed ? "Following" : "Follow")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.isFollowed ? Color("CardDark") : Color("BrandPurple")
                        )
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: viewModel.isFollowed ? 1 : 0)
                        )
                }
                .animation(.easeInOut, value: viewModel.isFollowed)
                
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
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
    
    private var customTabBar: some View {
        HStack {
            if viewModel.user.isArtist {
                tabButton(title: "Portfolio")
            }
            tabButton(title: "Likes")
        }
        .padding(.vertical, 10)
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
    
    private var postsGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ]
        
        let dataSource = (selectedTab == "Portfolio") ? viewModel.posts : viewModel.likedPosts
        
        return LazyVGrid(columns: columns, spacing: 2) {
            if dataSource.isEmpty {
                // Empty state handled by grid being empty
            } else {
                ForEach(dataSource) { post in
                    let postOwner = post.user ?? viewModel.user
                    
                    NavigationLink(destination: PostView(post: post)) {
                        WebImage(url: URL(string: post.imageUrl))
                            .resizable()
                            .indicator(.activity)
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.width / 3) - 2, height: (UIScreen.main.bounds.width / 3) - 2)
                            .clipped()
                            .background(Color("CardDark"))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
