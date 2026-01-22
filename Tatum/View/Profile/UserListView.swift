import SwiftUI
import SDWebImageSwiftUI

struct UserListView: View {
    @StateObject var viewModel: UserListViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    let title: String
    
    @State private var selectedUser: TatumUser?
    
    init(uid: String, type: UserListType, title: String) {
        _viewModel = StateObject(wrappedValue: UserListViewModel(uid: uid, type: type))
        self.title = title
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundDark").ignoresSafeArea()
            VStack(spacing: 0) {
                customNavBar

                
                if viewModel.users.isEmpty {
                    Spacer()
                    Text("No users found.")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.users) { user in
                                UserRow(
                                    user: user,
                                    isFollowing: viewModel.isFollowing(userId: user.id),
                                    isLoading: viewModel.isLoading(userId: user.id),
                                    isCurrentUser: user.id == authViewModel.currentUser?.id,
                                    onFollowToggle: {
                                        viewModel.toggleFollow(for: user)
                                    },
                                    onTap: {
                                        selectedUser = user
                                    }
                                )
                            }
                            
                            // Hidden NavigationLink that activates programmatically
                            NavigationLink(
                                destination: Group {
                                    if let user = selectedUser {
                                        TatumProfileView(user: user)
                                    }
                                },
                                isActive: Binding(
                                    get: { selectedUser != nil },
                                    set: { if !$0 { selectedUser = nil } }
                                )
                            ) {
                                EmptyView()
                            }
                        }
                        .padding()
                    }
                }
            }
            
            
        }
        .navigationBarHidden(true)
        
    }
}

struct UserRow: View {
    let user: TatumUser
    let isFollowing: Bool
    let isLoading: Bool
    let isCurrentUser: Bool
    var onFollowToggle: () -> Void
    var onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageUrl = user.profileImageUrl {
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.white)
                
                Text(user.fullName)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Don't show follow button for current user
            if !isCurrentUser {
                Button(action: {
                    onFollowToggle()
                }) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    } else {
                        Text(isFollowing ? "Unfollow" : "Follow")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isFollowing ? Color("CardDark") : Color("BrandPurple"))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: isFollowing ? 1 : 0)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color("CardDark").opacity(0.5))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}


extension UserListView {
    private var customNavBar: some View {
        ZStack {
            Text(title)
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color("CardDark"))
                        .clipShape(Circle())
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        
        
    }
}
