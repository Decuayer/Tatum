import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // 1. Ana Arka Plan
                Color("BackgroundDark").ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // --- BÖLÜM 1: HESAP ---
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Account")
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            VStack(spacing: 1) {
                                NavigationLink(destination: Text("Interests & Tags")) {
                                    SettingsRow(icon: "tag.fill", title: "Interests & Tags", color: .blue)
                                }
                                
                                NavigationLink(destination: Text("Notifications")) {
                                    SettingsRow(icon: "bell.fill", title: "Notifications", color: .orange)
                                }
                            }
                            .background(Color("CardDark"))
                            .cornerRadius(16)
                        }
                        
                        // --- BÖLÜM 2: GENEL ---
                        VStack(alignment: .leading, spacing: 12) {
                            Text("General")
                                .font(.custom("Poppins-SemiBold", size: 14))
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            VStack(spacing: 1) {
                                // Sadece üye ise bu satır görünsün
                                if authViewModel.currentUser?.role != "artist" {
                                    NavigationLink(destination: Text("Artist Application")) {
                                        SettingsRow(icon: "paintbrush.pointed.fill", title: "Become an Artist", color: Color("BrandPurple"), showBadge: true)
                                    }
                                }
                                
                                NavigationLink(destination: Text("Help & Support")) {
                                    SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .green)
                                }
                            }
                            .background(Color("CardDark"))
                            .cornerRadius(16)
                        }
                        
                        Spacer().frame(height: 20)
                                                
                        // --- DEVELOPER AREA (TEST İÇİN) ---

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Developer Zone")
                                .font(.custom("Poppins-SemiBold", size: 12))
                                .foregroundColor(.gray)
                                .padding(.leading, 4)
                            
                            // 1. BUTON: Test Verisi Ekle
                            Button(action: {
                                TestDataManager.shared.createTestUsers { message, addedFollowers, addedFollowing in
                                    print(message)
                                    if addedFollowers > 0 || addedFollowing > 0 {
                                        if var user = authViewModel.currentUser {
                                            user.followersCount += addedFollowers
                                            user.followingCount += addedFollowing
                                            authViewModel.currentUser = user
                                        }
                                    }
                                }
                            }) {
                                SettingsRow(icon: "hammer.fill", title: "Add Test Data (Seed)", color: .yellow)
                            }
                            
                            // 2. BUTON: Kullanıcı Veritabanı (User Database)
                            Button(action: {
                                // Sheet'i açmak için State değişkeni lazım ama
                                // SettingsView içinde NavigationLink ile gitmek daha temiz olabilir.
                                // Ya da basitçe 'showDatabase' diye bir @State ekleyip sheet açabiliriz.
                            }) {
                                // Not: Button içinde NavigationLink çalışmaz, doğrudan NavigationLink koyuyoruz:
                                NavigationLink(destination: AllUsersListView()) {
                                    SettingsRow(icon: "server.rack", title: "User Database Manager", color: .purple)
                                }
                            }
                            
                            // 3. BUTON: POST UPLOAD TOOL ---
                            DevPostUploaderRow()
                        }
                        .padding(.bottom, 20)
                        
                        Spacer().frame(height: 20)
                        
                        // --- BÖLÜM 3: ÇIKIŞ YAP (Buton) ---
                        Button(action: {
                            authViewModel.signOut()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                                    .font(.custom("Poppins-SemiBold", size: 16))
                            }
                            .foregroundColor(.white) // Kırmızı yerine beyaz yazı
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8)) // Arka plan kırmızı
                            .cornerRadius(16)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Custom Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    var showBadge: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // İkon Kutusu
            ZStack {
                Circle()
                    .fill(color.opacity(0.2)) // İkon renginin şeffaf hali
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color) // İkonun kendisi parlak
            }
            
            // Başlık
            Text(title)
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            // Rozet (Apply Butonu gibi)
            if showBadge {
                Text("Apply")
                    .font(.custom("Poppins-Bold", size: 10))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color("BrandPurple"))
                    .cornerRadius(8)
            }
            
            // Sağ Ok
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding()
        // Satırın tamamına basılabilmesi için arka plan veriyoruz (ama şeffaf)
        .background(Color("CardDark"))
    }
}

struct DevPostUploaderRow: View {
    @StateObject var viewModel = DevPostViewModel()
    
    var body: some View {
        VStack(spacing: 10) {
            // Seçici ve Yükle Butonu Yan Yana
            HStack {
                // 1. Resim Seçici
                PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                    HStack {
                        ZStack {
                            Circle().fill(Color.pink.opacity(0.2)).frame(width: 36, height: 36)
                            Image(systemName: "photo.fill.on.rectangle.fill").font(.system(size: 16)).foregroundColor(.pink)
                        }
                        Text(viewModel.selectedImage == nil ? "Select Photo" : "Photo Selected")
                            .font(.custom("Poppins-Medium", size: 16))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                // Seçilen Resmin Önizlemesi (Varsa)
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
                }
                
                // Yükle Butonu (Ok işareti yerine)
                if viewModel.selectedImage != nil {
                    Button(action: {
                        viewModel.uploadDevPost()
                    }) {
                        if viewModel.isUploading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Upload")
                                .font(.caption).bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color("BrandPurple"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                } else {
                    Image(systemName: "chevron.right").foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding()
            .background(Color("CardDark"))
            .cornerRadius(16)
            
            // Durum Mesajı (Başarılı/Hata)
            if !viewModel.uploadStatusMessage.isEmpty {
                Text(viewModel.uploadStatusMessage)
                    .font(.caption)
                    .foregroundColor(viewModel.uploadStatusMessage.contains("Başarılı") ? .green : .red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
            }
        }
    }
}
