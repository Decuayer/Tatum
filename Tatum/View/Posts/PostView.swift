import SwiftUI
import SDWebImageSwiftUI

struct PostView: View {
    @StateObject var viewModel: PostViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showComments = false
    @State private var selectedUser: TatumUser?
    
    init(post: Post) {
        _viewModel = StateObject(wrappedValue: PostViewModel(post: post))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            customNavBar
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    postHeader
                    
                    postImage
                    postFooter
                }
            }
            .refreshable {
                viewModel.refresh()
            }
        }
        .background(Color("BackgroundDark").ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showComments) {
            CommentsView(post: viewModel.post, selectedUser: $selectedUser)
                .environmentObject(authViewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .background(
            NavigationLink(
                destination: selectedUser.map { TatumProfileView(user: $0) },
                isActive: Binding(
                    get: { selectedUser != nil },
                    set: { if !$0 { selectedUser = nil } }
                )
            ) {
                EmptyView()
            }
        )
    }
}

// MARK: - Components
extension PostView {
    
    private var customNavBar: some View {
        VStack(spacing: 0) {
            ZStack {    
                Text("Post")
                    .font(.custom("Poppins-Bold", size: 20))
                    .foregroundColor(.white)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color("CardDark"))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color.white.opacity(0.2))
        }
    }
    
    private var postHeader: some View {
        HStack {
            if let user = viewModel.postOwner {
                NavigationLink(destination: TatumProfileView(user: user)) {
                    HStack(spacing: 12) {
                        if let imgUrl = user.profileImageUrl, !imgUrl.isEmpty {
                            WebImage(url: URL(string: imgUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 40, height: 40)
                        }
                        
                       
                    }
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: TatumProfileView(user: user)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.username)
                            .font(.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(.white)
                        
                        if viewModel.post.hasStudioTag {
                            Text("Studio Post")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .buttonStyle(.plain)
            } else {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray.opacity(0.3))
            }
            
            
            Spacer()
            
            Button(action: {
                // TODO: Show Post options menu
                print("TODO: Show Post Options Menu")
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white)
                    .padding(8)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
    
    private var postImage: some View {
        WebImage(url: URL(string: viewModel.post.imageUrl))
            .resizable()
            .indicator(.activity)
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .background(Color("CardDark"))
    }
    
    private var postFooter: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.isLiked ? viewModel.unlikePost() : viewModel.likePost()
                }) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundColor(viewModel.isLiked ? .red : .white)
                        .scaleEffect(viewModel.isLiked ? 1.1 : 1.0)
                        .animation(.spring(), value: viewModel.isLiked)
                }
                
                Button(action: {
                    showComments.toggle()
                }) {
                    Image(systemName: "bubble.right")
                        .font(.title2)
                }
                
                Spacer()
                
                Button(action: {
                    // TODO: Implement save/unsave
                    print("TODO: Save/Unsave Post")
                }) {
                    Image(systemName: "bookmark")
                        .font(.title2)
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding(.top, 8)
            
            if viewModel.likesCount > 0 {
                Text("\(viewModel.likesCount) likes")
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
            }
            
            HStack(alignment: .top) {
                if let user = viewModel.postOwner {
                    Text(user.username)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.white)
                    +
                    Text(" \(viewModel.post.caption)")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            Text(viewModel.post.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }
    
}
