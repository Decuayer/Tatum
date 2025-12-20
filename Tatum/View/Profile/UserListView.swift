import SwiftUI
import SDWebImageSwiftUI

struct UserListView: View {
    @StateObject var viewModel: UserListViewModel
    @EnvironmentObject var authViewModel: AuthViewModel // Profil sayılarını güncellemek için
    @Environment(\.dismiss) var dismiss
    let title: String
    
    init(uid: String, type: UserListType, title: String) {
        _viewModel = StateObject(wrappedValue: UserListViewModel(uid: uid, type: type))
        self.title = title
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark").ignoresSafeArea()
                
                if viewModel.users.isEmpty {
                    // Boş liste uyarısı
                    Text("No users found.")
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.users) { user in
                                // Tıklayınca Profile Git
                                NavigationLink(destination: UserProfileView(user: user)) {
                                    UserRow(
                                        user: user,
                                        listType: viewModel.listType,
                                        onAction: {
                                            // Butona basılınca çalışacak kod
                                            handleAction(for: user)
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    // BUTON AKSİYONU VE PROFİL GÜNCELLEME
    func handleAction(for user: TatumUser) {
        viewModel.performAction(for: user) { success in
            if success {
                // İşlem başarılıysa AuthViewModel'deki sayıları güncelle (Canlılık hissi için)
                if var currentUser = authViewModel.currentUser {
                    if viewModel.listType == .followers {
                        currentUser.followersCount -= 1
                    } else {
                        currentUser.followingCount -= 1
                    }
                    // AuthViewModel'i güncelle ki Profil sayfası yenilensin
                    authViewModel.currentUser = currentUser
                }
            }
        }
    }
}

// MARK: - Akıllı Liste Satırı
struct UserRow: View {
    let user: TatumUser
    let listType: UserListType
    var onAction: () -> Void // Butona basıldığını yukarı bildirmek için
    
    var body: some View {
        HStack(spacing: 12) {
            // Profil Fotosu
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
            
            // İsimler
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
            
            // AKILLI BUTON
            Button(action: {
                onAction() // UserListView içindeki fonksiyonu tetikler
            }) {
                Text(listType == .followers ? "Remove" : "Unfollow")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color("CardDark"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(Color("CardDark").opacity(0.5))
        .cornerRadius(12)
    }
}
