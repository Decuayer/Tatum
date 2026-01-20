//
//  FeedCell.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore

struct FeedCell: View {
    @StateObject var viewModel: PostDetailViewModel
    @State private var user: TatumUser?
    
    init(post: Post) {
        self._viewModel = StateObject(wrappedValue: PostDetailViewModel(post: post))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // MARK: - Header (Profil & İsim)
            HStack {
                if let user = user {
                    WebImage(url: URL(string: user.profileImageUrl ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.username)
                            .font(.custom("Poppins-Bold", size: 14))
                            .foregroundColor(.white)
                        
                        if let studioId = viewModel.post.studioId {
                            Text("Studio Post")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                } else {
                    Circle().frame(width: 36, height: 36).foregroundColor(.gray.opacity(0.3))
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 8)
            .padding(.bottom, 4)
            
            // MARK: - Post Görseli
            Color.clear
                .frame(height: 400)
                .frame(maxWidth: .infinity)
                .overlay(
                    WebImage(url: URL(string: viewModel.post.imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle().foregroundColor(.gray.opacity(0.1))
                    }
                        .indicator(.activity)
                        .clipped()
                )
                .background(Color("CardDark"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            
            
            // MARK: - Aksiyon Butonları
            HStack(spacing: 16) {
                
                Button(action: {
                    viewModel.isLiked ? viewModel.unlikePost() : viewModel.likePost()
                }) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .frame(width: 22, height: 20)
                        .foregroundColor(viewModel.isLiked ? .red : .white)
                }
                
                NavigationLink(destination: CommentsView(post: viewModel.post)) {
                    Image(systemName: "bubble.right")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                
                // 3. GÖNDER (Share/DM) BUTONU
                Button(action: {
                    print("Paylaş/DM gönder")
                }) {
                    Image(systemName: "paperplane")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {
                    print("Postu kaydet")
                }) {
                    Image(systemName: "bookmark")
                        .resizable()
                        .frame(width: 18, height: 22)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 8)
            
            // MARK: - Beğeni Sayısı & Caption
            Text("\(viewModel.likesCount) Likes")
                .font(.custom("Poppins-Bold", size: 14))
                .foregroundColor(.white)
                .padding(.leading, 8)
                .padding(.top, 2)
            
            HStack(alignment: .top) {
                Text(user?.username ?? "")
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.white)
                + Text(" \(viewModel.post.caption)")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)
            .padding(.top, 1)
            
            Text(viewModel.post.timestamp.formatted(date: .abbreviated, time: .omitted))
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.gray)
                .padding(.leading, 8)
                .padding(.top, 2)
        }
        .padding(.bottom, 20)
        .onAppear {
            fetchUser()
        }
    }
    
    func fetchUser() {
        Firestore.firestore().collection("users").document(viewModel.post.ownerUid).getDocument { snapshot, _ in
            guard let data = snapshot?.data() else { return }
            self.user = TatumUser(data: data)
        }
    }
}
