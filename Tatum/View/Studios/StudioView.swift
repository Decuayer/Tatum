//
//  StudioView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct StudioView: View {
    @StateObject var viewModel = StudioViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Arka Plan Harita
                Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.studios) { studio in
                    MapAnnotation(coordinate: studio.coordinate) {
                        // Pin Design
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color("BrandPurple"))
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                .ignoresSafeArea()
                .colorScheme(.dark)
                
                // Stüdyo Kartları (Carousel)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.studios) { studio in
                            NavigationLink(destination: StudioDetailView(studio: studio)) {
                                StudioCard(studio: studio)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .background(Color.clear)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

//MARK: - Card Struct
struct StudioCard: View {
    let studio: Studio
    
    var body: some View {
        HStack(spacing: 12) {
            WebImage(url: URL(string: studio.imageUrl))
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(studio.name)
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundColor(.white)
                
                Text(studio.address)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color("BrandYellow"))
                        .font(.caption)
                    
                    Text(String(format: "%.1f", studio.rating))
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(4)
                }
            }
            Spacer()
        }
        .padding(10)
        .frame(width: 280)
        .background(Color("CardDark"))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
    }
}

#Preview {
    StudioView()
}
