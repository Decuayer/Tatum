import SwiftUI
import SDWebImageSwiftUI

struct CommentsView: View {
    @StateObject var viewModel: CommentsViewModel
    @State private var commentText = ""
    @Environment(\.dismiss) var dismiss
    
    init(post: Post) {
        _viewModel = StateObject(wrappedValue: CommentsViewModel(post: post))
    }
    
    var body: some View {
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
                        CommentRow(comment: comment)
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
            
            // Yorum Yazma Alanı (Input)
            HStack(spacing: 12) {
                // Kendi profil foton (Opsiyonel, şimdilik statik veya boş bırakılabilir)
                // Daha ileri seviyede buraya currentUser fotosu konulur.
                
                TextField("Add a comment...", text: $commentText)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color("CardDark"))
                    .cornerRadius(20)
                
                Button(action: {
                    if !commentText.isEmpty {
                        viewModel.uploadComment(commentText: commentText)
                        commentText = "" // Temizle
                        // Klavye kapatma kodu eklenebilir
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

// Tek Satır Yorum Tasarımı
struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
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
}
