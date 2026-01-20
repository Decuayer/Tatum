import SwiftUI
import SDWebImageSwiftUI

struct PostDetailView: View {
    @StateObject var viewModel: PostDetailViewModel
    let user: TatumUser
    @Environment(\.dismiss) var dismiss
    
    @State private var showComments = false
    
    init(post: Post, user: TatumUser) {
        self.user = user
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            customNavBar
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink(destination: TatumProfileView(user: user)) {
                        postHeader
                    }
                    .buttonStyle(.plain)
                    
                    postImage
                    postFooter
                }
            }
        }
        .background(Color("BackgroundDark").ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showComments) {
            CommentsView(post: viewModel.post)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Components
extension PostDetailView {
    
    private var customNavBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            Text("Post")
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(.white)
                .padding(.leading, 8)
            Spacer()
        }
        .padding()
        .background(Color("CardDark"))
    }
    
    private var postHeader: some View {
        HStack {
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
            
            Text(user.username)
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "ellipsis")
                .foregroundColor(.white)
        }
        .padding(12)
        .contentShape(Rectangle())
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
                    if viewModel.isLiked {
                        viewModel.unlikePost()
                    } else {
                        viewModel.likePost()
                    }
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
                
                Button(action: {}) {
                    Image(systemName: "paperplane")
                        .font(.title2)
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.top, 8)
            
            if viewModel.likesCount > 0 {
                Text("\(viewModel.likesCount) likes")
                    .font(.custom("Poppins-SemiBold", size: 14))
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            
            Text("\(Text(user.username).font(.custom("Poppins-SemiBold", size: 14))) \(Text(viewModel.post.caption).font(.custom("Poppins-Regular", size: 14)))")
                .foregroundColor(.white)
                .padding(.top, 4)
            
            Text(viewModel.post.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
                .padding(.bottom, 12)
        }
        .padding(.horizontal, 12)
    }
}
