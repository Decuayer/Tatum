//
//  StudioDetailView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct StudioDetailView: View {
    let studio: Studio
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: String = "Portfolio" // Sayfa içi sekme durumu
    @State private var showBookingSheet = false // EKLENDİ
    
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("BackgroundDark")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Üst Alan (Resim ve Geri Butonu)
                    headerSection
                    
                    // Stüdyo Bilgileri
                    infoSection
                    
                    // Özel Sekme Değiştirici (Portfolio - Artists - Reviews)
                    customTabBar
                        .zIndex(1)
                    
                    // Seçili Sekmeye Göre İçerik
                    if selectedTab == "Portfolio" {
                        portfolioGrid
                    } else if selectedTab == "Artists" {
                        artistList
                    } else {
                        reviewsSection
                    }
                }
                .padding(.bottom, 120)
            }
            .ignoresSafeArea(edges: .top)
            
            bookNowButton
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showBookingSheet) {
                    BookingView(studio: studio)
                        .presentationDetents([.fraction(0.7), .large])
                        .presentationDragIndicator(.visible)
                }
    }
}

extension StudioDetailView {
    // Header Section
    private var headerSection: some View {
        ZStack(alignment: .topLeading) {
            // SDWebImage Kullanımı
            GeometryReader { geometry in
                WebImage(url: URL(string: studio.imageUrl)) { image in
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
            
            // Go Back Button
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
    
    // Info Section
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(studio.name)
                .font(.custom("Poppins-Bold", size: 28))
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Color("BrandPurple"))
                Text(studio.address)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color("BrandYellow"))
                Text(String(format: "%.1f (120 Reviews)", studio.rating))
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
    
    // Custom Tab Bar
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
    
    // Portfolio Contents (Grid)
    private var portfolioGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 2) {
            ForEach(0..<12) { index in
                Image("TestTattoo\((index % 3) + 1)") // Test Resimleri
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
            }
        }
    }
    
    // Artists Content (List)
    private var artistList: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { _ in
                HStack {
                    Image("decu")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("Artist Name")
                            .font(.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(.white)
                        Text("Traditional Specialist")
                            .font(.custom("Poppins-Regular", size: 12))
                            .foregroundColor(.gray)
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
    
    // Comments Section
    private var reviewsSection: some View {
        Text("Reviews functionality will be implemented here.")
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    // Book Now Button
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

}

