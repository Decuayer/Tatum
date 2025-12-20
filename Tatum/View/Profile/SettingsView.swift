import SwiftUI

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
                        Button(action: {
                            // Test verisi oluştur
                            TestDataManager.shared.createTestUsers { message, addedFollowers, addedFollowing in
                                print(message) // Konsola bilgi bas
                                
                                // ANLIK GÜNCELLEME SİHRİ BURADA:
                                // Eğer veritabanına yeni bir şey eklendiyse, AuthViewModel'deki currentUser'ı güncelle.
                                if addedFollowers > 0 || addedFollowing > 0 {
                                    if var user = authViewModel.currentUser {
                                        user.followersCount += addedFollowers
                                        user.followingCount += addedFollowing
                                        authViewModel.currentUser = user // Bu tetikleme View'ı yeniler
                                    }
                                }
                            }
                        }) {
                            SettingsRow(icon: "hammer.fill", title: "Add Test Data (Auto Update)", color: .yellow)
                                .cornerRadius(16)

                        }
                        
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
