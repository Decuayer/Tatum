import SwiftUI
import SDWebImageSwiftUI

struct InboxView: View {
    @StateObject var viewModel = InboxViewModel()
    @State private var showChat = false
    @State private var selectedUser: TatumUser? // Navigasyon için
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark").ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text("Messages")
                        .font(.custom("Poppins-Bold", size: 28))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    if viewModel.recentMessages.isEmpty {
                        Text("No messages yet.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 1) {
                                ForEach(viewModel.recentMessages) { recent in
                                   
                                    let targetUser = TatumUser(
                                        id: recent.id,
                                        email: "",
                                        username: recent.username,
                                        fullName: recent.username,
                                        profileImageUrl: recent.profileImageUrl,
                                        role: "member",
                                        bio: nil,
                                        website: nil,
                                        phoneNumber: nil,
                                        studioId: nil,
                                        followersCount: 0,
                                        followingCount: 0
                                    )
                                    
                                    NavigationLink(destination: ChatView(user: targetUser)) {
                                        InboxRow(recent: recent)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// SATIR TASARIMI
struct InboxRow: View {
    let recent: RecentMessage
    
    var body: some View {
        HStack(spacing: 16) {
            // Profil Fotosu
            if let imgUrl = recent.profileImageUrl, !imgUrl.isEmpty {
                WebImage(url: URL(string: imgUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 56, height: 56)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recent.username)
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(.white)
                    Spacer()
                    // Zaman Formatı
                    Text(recent.timestamp.formatted(.dateTime.hour().minute()))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(recent.text)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color("BackgroundDark"))
    }
}
