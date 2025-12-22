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
    
    @State private var selectedStudioId: String?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.studios) { studio in
                    MapAnnotation(coordinate: studio.coordinate) {
                        VStack {
                            Image(systemName: studio.isClaimed ? "checkmark.seal.fill" : "mappin.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(studio.isClaimed ? Color("BrandPurple") : Color.gray)
                                .background(Color.white)
                                .clipShape(Circle())
                                .scaleEffect(selectedStudioId == studio.id ? 1.5 : 1.0)
                                .shadow(radius: 3)
                                .onTapGesture {
                                    withAnimation {
                                        selectedStudioId = studio.id
                                    }
                                }
                            
                            if selectedStudioId == studio.id {
                                Text(studio.name)
                                    .font(.caption2)
                                    .bold()
                                    .padding(4)
                                    .background(Color("CardDark"))
                                    .cornerRadius(4)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                .colorScheme(.dark)
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(viewModel.studios) { studio in
                                NavigationLink(destination: StudioDetailView(studio: studio)) {
                                    StudioCard(studio: studio)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color("BrandPurple"), lineWidth: selectedStudioId == studio.id ? 3 : 0)
                                        )
                                }
                                .buttonStyle(.plain)
                                .id(studio.id)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                    .onChange(of: selectedStudioId) { newId in
                        if let id = newId {
                            withAnimation(.spring()) {
                                proxy.scrollTo(id, anchor: .center)
                            }
                        }
                    }
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
            if !studio.imageUrl.isEmpty {
                WebImage(url: URL(string: studio.imageUrl))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(studio.name)
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if studio.isClaimed {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(Color("BrandPurple"))
                    }
                }
                
                Text(studio.address)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
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
