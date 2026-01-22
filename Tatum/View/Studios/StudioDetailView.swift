//
//  StudioDetailView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct StudioDetailView: View {
    @StateObject var viewModel: StudioDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: String = "Portfolio"
    @State private var showBookingSheet = false
    @State private var showClaimSheet = false
    
    @Namespace private var animation
    
    init(studio: Studio) {
        _viewModel = StateObject(wrappedValue: StudioDetailViewModel(studio: studio))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("BackgroundDark")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    infoSection
                    
                    if viewModel.studio.isClaimed {
                        customTabBar.zIndex(1)
                        
                        if viewModel.isLoading {
                            ProgressView().padding(.top, 50)
                        } else {
                            if selectedTab == "Portfolio" {
                                portfolioGrid
                            } else if selectedTab == "Artists" {
                                artistList
                            } else {
                                reviewsSection
                            }
                        }
                    } else {
                        unclaimedStateView
                    }
                }
                .padding(.bottom, 120)
            }
            .ignoresSafeArea(edges: .top)
            
            if viewModel.studio.isClaimed {
                bookNowButton
            } else {
                claimButton
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showBookingSheet) {
            BookingView(studio: viewModel.studio)
                .presentationDetents([.fraction(0.7), .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showClaimSheet) {
            ClaimStudioView(studio: viewModel.studio)
        }
    }
}


//MARK: - Extensions

extension StudioDetailView {
    private var headerSection: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geometry in
                WebImage(url: URL(string: viewModel.studio.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle().foregroundColor(.gray.opacity(0.3))
                }
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .frame(width: geometry.size.width, height: 300)
                .clipped()
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [.clear, Color("BackgroundDark")]), startPoint: .center, endPoint: .bottom)
                )
            }
            .frame(height: 350)
            
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(.top, 60)
            .padding(.leading, 20)
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.studio.name)
                .font(.custom("Poppins-Bold", size: 28))
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Color("BrandPurple"))
                Text(viewModel.studio.address)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color("BrandYellow"))
                Text(String(format: "%.1f (120 Reviews)", viewModel.studio.rating))
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Open Now")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    private var customTabBar: some View {
        HStack {
            ForEach(["Portfolio", "Artists", "Reviews"], id: \.self) { tab in
                VStack {
                    Text(tab)
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(selectedTab == tab ? .white : .gray)
                    
                    if selectedTab == tab {
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(Color("BrandPurple"))
                            .matchedGeometryEffect(id: "tab", in: animation)
                    } else {
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(.clear)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.bottom, 10)
    }
    
    private var portfolioGrid: some View {
        VStack {
            if viewModel.posts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "camera")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No posts yet.")
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
                    ForEach(viewModel.posts) { post in
                        let postOwner = viewModel.artists.first(where: { $0.id == post.ownerUid })
                        ?? TatumUser(
                            id: viewModel.studio.ownerId ?? UUID().uuidString,
                            email: "",
                            username: viewModel.studio.name,
                            fullName: viewModel.studio.name,
                            profileImageUrl: viewModel.studio.imageUrl,
                            role: "studio",
                            bio: "Studio Official Account",
                            website: "",
                            phoneNumber: viewModel.studio.phoneNumber,
                            studioId: viewModel.studio.id,
                            followersCount: 0,
                            followingCount: 0
                        )
                        
                        NavigationLink(destination: PostView(post: post)) { 
                            WebImage(url: URL(string: post.imageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                                .background(Color("CardDark"))
                        }
                    }
                }
            }
        }
    }
    
    private var artistList: some View {
        VStack(spacing: 16) {
            if viewModel.artists.isEmpty {
                Text("No artists registered yet.")
                    .foregroundColor(.gray)
                    .padding(.top, 40)
            }
            
            ForEach(viewModel.artists) { artist in
                HStack {
                    WebImage(url: URL(string: artist.profileImageUrl ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(artist.username) // Veya fullName
                            .font(.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(.white)
                        Text(artist.bio ?? "Tattoo Artist")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button("Profile") { }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("CardDark"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                .background(Color("CardDark").opacity(0.5))
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private var reviewsSection: some View {
        Text("Reviews functionality will be implemented here.")
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private var bookNowButton: some View {
        Button(action: {
            showBookingSheet.toggle()
        }) {
            Text("Book Appointment")
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("BrandPurple"))
                .cornerRadius(16)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
        .background(
            LinearGradient(colors: [Color("BackgroundDark").opacity(0), Color("BackgroundDark")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        )
        
    }
    
    private var unclaimedStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.2.crop.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding(.top, 40)
            
            Text("This studio is unclaimed")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            
            Text("If you are the owner of \(viewModel.studio.name), you can claim this page to manage photos, artists, and appointments.")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer().frame(height: 50)
        }
    }
    
    private var claimButton: some View {
        Button(action: {
            showClaimSheet.toggle()
        }) {
            Text("Claim This Business")
                .font(.custom("Poppins-Bold", size: 18))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color("BrandPurple"))
                .cornerRadius(16)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
        .background(Color("BackgroundDark"))
    }
    
}

