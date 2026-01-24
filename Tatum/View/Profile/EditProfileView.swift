import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    // Form Variables
    @State private var fullname = ""
    @State private var username = ""
    @State private var bio = ""
    @State private var website = ""
    @State private var phone = ""
    
    // Photo Selection
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var croppedImage: UIImage? = nil
    @State private var showImageCropper = false
    @State private var tempImageForCropping: UIImage? = nil
    
    // Validation
    @State private var phoneValidationError: String? = nil
    
    // Loading state
    @State private var isSaving = false
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundDark").ignoresSafeArea()
                VStack(spacing: 0) {
                    customNavBar
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // 1. PROFILE PHOTO CHANGE AREA
                            VStack(spacing: 12) {
                                PhotosPicker(
                                    selection: $selectedItem,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    ZStack(alignment: .bottomTrailing) {
                                        // Show cropped image first, then selected, then current
                                        if let croppedImage = croppedImage {
                                            Image(uiImage: croppedImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        } else if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        } else if let imageUrl = authViewModel.currentUser?.profileImageUrl {
                                            WebImage(url: URL(string: imageUrl))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.gray)
                                                .frame(width: 100, height: 100)
                                        }
                                        
                                        // Edit Icon Badge
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
                            
                            // 2. INPUT FIELDS
                            VStack(spacing: 20) {
                                EditProfileField(title: "Full Name", text: $fullname)
                                EditProfileField(title: "Username", text: $username)
                                EditProfileField(title: "Bio", text: $bio, isMultiLine: true)
                                
                                // Website field - only for Artists
                                if let user = authViewModel.currentUser, user.isArtist {
                                    EditProfileField(title: "Website", text: $website)
                                }
                                
                                EditProfileField(
                                    title: "Phone Number",
                                    text: $phone,
                                    validationError: phoneValidationError
                                )
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                    }
                }
                
                // Success message overlay
                if showSuccessMessage {
                    VStack {
                        Spacer()
                        Text("Profile updated successfully!")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color("BrandPurple"))
                            .cornerRadius(12)
                            .padding(.bottom, 50)
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showImageCropper) {
                if let image = tempImageForCropping {
                    ImageCropperView(
                        image: image,
                        onCrop: { croppedImg in
                            croppedImage = croppedImg
                            showImageCropper = false
                        },
                        onCancel: {
                            showImageCropper = false
                            selectedItem = nil
                            selectedImageData = nil
                            tempImageForCropping = nil
                        }
                    )
                }
            }
            .onAppear {
                loadUserData()
            }
            .onChange(of: selectedItem) { oldValue, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImageData = data
                        tempImageForCropping = uiImage
                        showImageCropper = true
                        

                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 saniye
                            selectedItem = nil
                        }
                    }
                }
            }
            .onChange(of: phone) { oldValue, newValue in
                validatePhoneNumber()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Functions
    
    func loadUserData() {
        if let user = authViewModel.currentUser {
            fullname = user.fullName
            username = user.username
            bio = user.bio ?? ""
            website = user.website ?? ""
            phone = user.phoneNumber ?? ""
        }
    }
    
    func validatePhoneNumber() {
        phoneValidationError = ValidationHelper.validatePhoneNumber(phone)
    }
    
    func saveProfileChanges() {
        // Final validation
        validatePhoneNumber()
        
        if phoneValidationError != nil {
            return
        }
        
        isSaving = true
        
        authViewModel.updateUserProfile(
            fullName: fullname,
            username: username.isEmpty ? nil : username,
            bio: bio.isEmpty ? nil : bio,
            website: website.isEmpty ? nil : website,
            phoneNumber: phone.isEmpty ? nil : phone,
            profileImage: croppedImage
        ) { success, error in
            isSaving = false
            
            if success {
                withAnimation {
                    showSuccessMessage = true
                }
                
                // Auto-dismiss after showing success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } else {
                // Error is already set in authViewModel.errorMessage
                print("DEBUG: Profile update failed - \(error ?? "Unknown error")")
            }
        }
    }
}

// MARK: - Custom Input Component (Reusable)
struct EditProfileField: View {
    let title: String
    @Binding var text: String
    var isMultiLine: Bool = false
    var validationError: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
            
            if isMultiLine {
                TextEditor(text: $text)
                    .frame(height: 100)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("CardDark"))
                    .cornerRadius(12)
                    .scrollContentBackground(.hidden)
            } else {
                TextField("", text: $text)
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("CardDark"))
                    .cornerRadius(12)
            }
            
            // Validation error
            if let error = validationError {
                Text(error)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.red)
                    .padding(.leading, 4)
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
                
                Button(isSaving ? "Saving..." : "Save") {
                    saveProfileChanges()
                }
                .disabled(isSaving || phoneValidationError != nil)
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(
                    (isSaving || phoneValidationError != nil) ? .gray : Color("BrandPurple")
                )
                .padding(12)
                .background(Color("CardDark"))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
