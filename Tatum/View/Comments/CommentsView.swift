import SwiftUI
import SDWebImageSwiftUI

struct CommentsView: View {
    @StateObject var viewModel: CommentsViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var commentText = ""
    @Environment(\.dismiss) var dismiss
    
    init(post: Post) {
        _viewModel = StateObject(wrappedValue: CommentsViewModel(post: post))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 8) {
                    Capsule()
                        .frame(width: 40, height: 4)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.top, 8)
                    
                    Text("Comments")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                }
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.comments) { comment in
                            CommentRow(comment: comment, authViewModel: authViewModel)
                        }
                    }
                    .padding()
                }
                
                if viewModel.comments.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No comments yet. Be the first!")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                Divider().background(Color.gray.opacity(0.3))
                
                // Comment Input Area
                HStack(spacing: 12) {
                    TextField("Add a comment...", text: $commentText)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color("CardDark"))
                        .cornerRadius(20)
                    
                    Button(action: {
                        if !commentText.isEmpty {
                            viewModel.uploadComment(commentText: commentText)
                            commentText = ""
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }) {
                        Text("Post")
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(commentText.isEmpty ? .gray : Color("BrandPurple"))
                    }
                    .disabled(commentText.isEmpty)
                }
                .padding()
                .background(Color("BackgroundDark"))
            }
            .background(Color("BackgroundDark").ignoresSafeArea())
        }
    }
}

// Single Comment Row Design
struct CommentRow: View {
    let comment: Comment
    @ObservedObject var authViewModel: AuthViewModel
    
    var isCurrentUser: Bool {
        authViewModel.currentUser?.id == comment.uid
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile Image - NavigationLink wrapper only if not current user
            if isCurrentUser {
                profileImage
            } else {
                NavigationLink(destination: getUserProfileView()) {
                    profileImage
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .bottom, spacing: 6) {
                    Text(comment.username)
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.white)
                    
                    Text(comment.timestampString())
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Text(comment.commentText)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
    private var profileImage: some View {
        Group {
            if let imageUrl = comment.profileImageUrl, !imageUrl.isEmpty {
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 36, height: 36)
            }
        }
    }
    
    @ViewBuilder
    private func getUserProfileView() -> some View {
        // Fetch the user from Firebase for the profile view
        // We need to create a TatumUser from the comment's owner data
        let user = TatumUser(
            id: comment.uid,
            email: "",  // Not available from comment
            username: comment.username,
            fullName: comment.username,  // Use username as fallback
            profileImageUrl: comment.profileImageUrl,
            role: "member",  // Default role
            bio: nil,
            website: nil,
            phoneNumber: nil,
            studioId: nil,
            followersCount: 0,  // Will be loaded by ProfileViewModel
            followingCount: 0   // Will be loaded by ProfileViewModel
        )
        
        TatumProfileView(user: user)
            .environmentObject(authViewModel)
    }
}
