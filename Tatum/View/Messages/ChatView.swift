import SwiftUI
import SDWebImageSwiftUI
import FirebaseAuth

struct ChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool
    
    init(user: TatumUser) {
        _viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(
                                message: message,
                                isFromCurrentUser: message.isFromCurrentUser(currentUid: Auth.auth().currentUser?.uid ?? "")
                            )
                        }
                    }
                    .padding(.top)
                    .id("Bottom")
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if (viewModel.messages.last?.id) != nil {
                        withAnimation {
                            proxy.scrollTo("Bottom", anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    proxy.scrollTo("Bottom", anchor: .bottom)
                }
            }
            
            inputBar
        }
        .background(Color("CardDark").ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private var headerView: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color("CardDark"))
                    .clipShape(Circle())
            }
            
            if let img = viewModel.toUser.profileImageUrl, !img.isEmpty {
                WebImage(url: URL(string: img))
                    .resizable().scaledToFill()
                    .frame(width: 40, height: 40).clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable().foregroundColor(.gray)
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading) {
                Text(viewModel.toUser.username) // Dinamik İsim
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                Text("Online")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            Spacer()
        }
        .padding()
        .background(Color("BackgroundDark"))
    }
    
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $viewModel.messageText)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.white)
                .padding(12)
                .background(Color("CardDark"))
                .cornerRadius(20)
                .focused($isFocused)
            
            Button(action: {
                if let currentUser = authViewModel.currentUser {
                    viewModel.sendMessage(currentUser: currentUser)
                    isFocused = false
                } else {
                    print("Hata: Current User bulunamadı, mesaj gönderilemiyor.")
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("BrandPurple"))
                    .rotationEffect(.degrees(45))
                    .padding(10)
                    .background(Color("CardDark"))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color("BackgroundDark"))
    }
}
