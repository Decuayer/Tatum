//
//  ExploreView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    
    // Grid Düzeni: 2 Sütunlu esnek yapı
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 1. Arama Çubuğu
                    CustomSearchBar(text: $searchText)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    
                    // 2. Kategoriler (Yatay Kaydırma)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(sampleCategories) { category in
                                CategoryPill(
                                    title: category.title,
                                    isSelected: selectedCategory == category.title
                                )
                                .onTapGesture {
                                    withAnimation {
                                        selectedCategory = category.title
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                    }
                    
                    // 3. Grid Stracture
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            // Şimdilik 20 tane rastgele görsel koyuyoruz
                            ForEach(0..<20, id: \.self) { index in
                                NavigationLink(destination: Text("Detail View for Image \(index)")) {
                                    ExploreGridItem(imageName: "TestTattoo")
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true) // Üstteki standart navigation bar'ı gizliyoruz
        }
    }
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.custom("Poppins-Medium", size: 14))
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                isSelected ? Color("BrandPurple") : Color("CardDark")
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
    }
}

struct ExploreGridItem: View {
    let imageName: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Dövme Fotoğrafı
            Image(imageName) // Şimdilik Assets'ten, sonra URL'den gelecek
                .resizable()
                .scaledToFill()
                .frame(height: 200) // Yükseklik sabit veya dinamik olabilir
                .clipped()
                .cornerRadius(12)
            
            // Üzerindeki hafif karartma (yazı okunsun diye)
            LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .center, endPoint: .bottom)
                .cornerRadius(12)
            
            // Sanatçı ismi vs. (Opsiyonel)
            Text("Artist Name")
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.white)
                .padding(8)
        }
    }
}

#Preview {
    ExploreView()
}
