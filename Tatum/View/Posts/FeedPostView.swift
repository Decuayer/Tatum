//
//  FeedPostView.swift
//  Tatum
//
//  Unified post component for feed display
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore

struct FeedPostView: View {
    @StateObject var viewModel: PostViewModel
    @State private var user: TatumUser?
    @State private var showComments = false
    
    init(post: Post) {
        self._viewModel = StateObject(wrappedValue: PostViewModel(post: post))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header - Profile & Username
            postHeader
            
            // Post Image
            postImage
            
            // Action Buttons
            actionButtons
            
            // Likes Count
            if viewModel.likesCount > 0 {
                Text("\(viewModel.likesCount) likes")
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
            }
            
            // Caption
            captionView
            
            // Timestamp
            Text(viewModel.post.timestamp.formatted(date: .abbreviated, time: .omitted))
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.top, 4)
        }
        .padding(.bottom, 20)
        .onAppear {
            fetchUser()
        }
        .sheet(isPresented: $showComments) {
            CommentsView(post: viewModel.post)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Components
extension FeedPostView {
    
    private var postHeader: some View {
        HStack {
            if let user = user {
                // Profile Image
                NavigationLink(destination: TatumProfileView(user: user)) {
                    WebImage(url: URL(string: user.profileImageUrl ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                }
                .buttonStyle(.plain)
                
                // Username & Studio Tag
                NavigationLink(destination: TatumProfileView(user: user)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.username)
                            .font(.custom("Poppins-Bold", size: 14))
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
            
            // More Options Button
            Button(action: {
                // TODO: Show options menu
                print("User more")

            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private var postImage: some View {
        NavigationLink(destination: PostView(post: viewModel.post, user: user ?? createFallbackUser())) {
            Color.clear
                .frame(height: 400)
                .frame(maxWidth: .infinity)
                .overlay (
                    WebImage(url: URL(string: viewModel.post.imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray.opacity(0.1))
                    }
                        .indicator(.activity)
                        .clipped()
                    
                )
                .background(Color("CardDark"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Like Button
            Button(action: {
                viewModel.isLiked ? viewModel.unlikePost() : viewModel.likePost()
            }) {
                Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundColor(viewModel.isLiked ? .red : .white)
                    .scaleEffect(viewModel.isLiked ? 1.1 : 1.0)
                    .animation(.spring(), value: viewModel.isLiked)
            }
            
            // Comment Button
            Button(action: {
                showComments.toggle()
            }) {
                Image(systemName: "bubble.right")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Save Button
            Button(action: {
                // TODO: Implement save functionality
            }) {
                Image(systemName: "bookmark")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }
    
    private var captionView: some View {
        HStack(alignment: .top) {
            if let user = user {
                Text(user.username)
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.white)
                + Text(" \(viewModel.post.caption)")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
    }
    
    // MARK: - Helper Functions
    
    private func fetchUser() {
        Firestore.firestore()
            .collection("users")
            .document(viewModel.post.ownerUid)
            .getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: Error fetching post owner - \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                self.user = TatumUser(data: data)
            }
    }
    
    private func createFallbackUser() -> TatumUser {
        TatumUser(
            id: viewModel.post.ownerUid,
            email: "",
            username: "User",
            fullName: "User",
            profileImageUrl: nil,
            role: "member",
            bio: nil,
            website: nil,
            phoneNumber: nil,
            studioId: nil,
            followersCount: 0,
            followingCount: 0
        )
    }
}
