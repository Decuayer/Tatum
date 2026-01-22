import SwiftUI
import PhotosUI // Fotoğraf seçimi için gerekli
import SDWebImageSwiftUI // Mevcut fotoyu göstermek için

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // Form Değişkenleri
    @State private var fullname = ""
    @State private var bio = ""
    @State private var website = ""
    @State private var phone = ""
    
    // Fotoğraf Seçimi İçin
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark").ignoresSafeArea()
                VStack(spacing: 0) {
                    customNavBar

                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // 1. FOTOĞRAF DEĞİŞTİRME ALANI
                            VStack(spacing: 12) {
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    ZStack(alignment: .bottomTrailing) {
                                        // A) Yeni seçilen fotoğraf varsa onu göster
                                        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        }
                                        // B) Yoksa mevcut internetteki fotoyu göster
                                        else if let imageUrl = authViewModel.currentUser?.profileImageUrl {
                                            WebImage(url: URL(string: imageUrl))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        }
                                        // C) O da yoksa boş ikon göster
                                        else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.gray)
                                                .frame(width: 100, height: 100)
                                        }
                                        
                                        // Düzenle İkonu (Rozet)
                                        Image(systemName: "camera.fill")
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color("BrandPurple"))
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color("BackgroundDark"), lineWidth: 2))
                                    }
                                }
                                
                                Text("Change Profile Photo")
                                    .font(.custom("Poppins-Medium", size: 14))
                                    .foregroundColor(Color("BrandPurple"))
                            }
                            .padding(.top, 20)
                            
                            // 2. INPUT ALANLARI
                            VStack(spacing: 20) {
                                EditProfileField(title: "Full Name", text: $fullname)
                                EditProfileField(title: "Bio", text: $bio, isMultiLine: true)
                                EditProfileField(title: "Website", text: $website)
                                EditProfileField(title: "Phone Number", text: $phone)
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                    }
                }
                
                
            }
            .navigationBarHidden(true)
            // Sayfa açıldığında mevcut verileri doldur
            .onAppear {
                loadUserData()
            }
            // Fotoğraf seçilince veriye dönüştür
            .onChange(of: selectedItem) { oldValue, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    // FONKSİYONLAR
    
    func loadUserData() {
        if let user = authViewModel.currentUser {
            fullname = user.fullName
            bio = user.bio ?? ""
            website = user.website ?? ""
            phone = user.phoneNumber ?? ""
        }
    }
    
    func saveProfileChanges() {
        // BURADA:
        // 1. Eğer 'selectedImageData' varsa önce Firebase Storage'a yükle -> URL al.
        // 2. Yeni URL ve Text bilgilerini Firestore'da güncelle.
        
        // Şimdilik sadece Text güncelleme simülasyonu yapıyoruz (UI Testi için):
        if var user = authViewModel.currentUser {
            user.fullName = fullname
            user.bio = bio
            user.website = website
            user.phoneNumber = phone
            
            // ViewModel'deki veriyi güncelle (Anlık görmek için)
            authViewModel.currentUser = user
        }
        
        dismiss()
    }
}

// MARK: - Custom Input Component (Reusable)
struct EditProfileField: View {
    let title: String
    @Binding var text: String
    var isMultiLine: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
            
            if isMultiLine {
                TextEditor(text: $text)
                    .frame(height: 100)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.white) // YAZI RENGİ BEYAZ
                    .padding(10)
                    .background(Color("CardDark"))
                    .cornerRadius(12)
                    .scrollContentBackground(.hidden) // TextEditor gri arka planını kaldırır
            } else {
                TextField("", text: $text)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.white) // YAZI RENGİ BEYAZ
                    .padding()
                    .background(Color("CardDark"))
                    .cornerRadius(12)
            }
        }
    }
}

extension EditProfileView {
    private var customNavBar: some View {
        ZStack {
            Text("Edit Profile")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .font(.custom("Poppins-Bold", size: 16))
                .padding(12)
                .background(Color("CardDark"))
                .cornerRadius(20)
                .foregroundColor(.white)
                
                Spacer()
                
                Button("Save") {
                    saveProfileChanges()
                }
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(Color("BrandPurple"))
                .padding(12)
                .background(Color("CardDark"))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
