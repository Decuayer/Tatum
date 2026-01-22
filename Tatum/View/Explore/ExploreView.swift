//
//  ExploreView.swift
//  Tatum
//
//  Discovery/Explore page with infinite scroll grid and category filters
//

import SwiftUI
import SDWebImageSwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var showMapView = false
    
    // 3-column grid for compact post display
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header with search and map toggle
                    headerView
                    
                    // Category filter pills
                    categoryFilters
                    
                    // Posts grid
                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 50)
                            .tint(.white)
                    } else if viewModel.filteredPosts.isEmpty {
                        emptyStateView
                    } else {
                        postsGrid
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            if viewModel.posts.isEmpty {
                viewModel.fetchPosts()
            }
        }
    }
}

// MARK: - Components
extension ExploreView {
    
    private var headerView: some View {
        HStack {
            // Search icon
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .font(.title3)
            
            // Search field
            TextField("Search tattoos...", text: $viewModel.searchText)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(.white)
                .autocapitalization(.none)
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            // Map toggle button
            Button(action: {
                showMapView.toggle()
            }) {
                Image(systemName: showMapView ? "squareshape.split.3x3" : "map")
                    .font(.title3)
                    .foregroundColor(Color("BrandPurple"))
                    .padding(8)
                    .background(Color("CardDark"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color("CardDark"))
    }
    
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // "All" category
                CategoryPill(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil
                )
                .onTapGesture {
                    viewModel.selectCategory(nil)
                }
                
                // Tattoo categories
                ForEach(TattooCategory.allCases, id: \.self) { category in
                    CategoryPill(
                        title: category.displayName,
                        isSelected: viewModel.selectedCategory == category
                    )
                    .onTapGesture {
                        viewModel.selectCategory(category)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
    
    private var postsGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(viewModel.filteredPosts) { post in
                    NavigationLink(destination: PostView(post: post)) {
                        PostGridItem(post: post)
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No posts found")
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(.white)
            
            Text("Try adjusting your filters")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
            
            Button(action: {
                viewModel.clearFilters()
            }) {
                Text("Clear Filters")
                    .font(.custom("Poppins-Medium", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color("BrandPurple"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Category Pill Component
struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.custom("Poppins-Medium", size: 14))
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(isSelected ? Color("BrandPurple") : Color("CardDark"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
    }
}

// MARK: - Post Grid Item Component
struct PostGridItem: View {
    let post: Post
    
    var body: some View {
        WebImage(url: URL(string: post.imageUrl)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .foregroundColor(.gray.opacity(0.2))
        }
        .indicator(.activity)
        .frame(width: gridItemWidth, height: gridItemWidth)
        .clipped()
    }
    
    private var gridItemWidth: CGFloat {
        (UIScreen.main.bounds.width - 4) / 3  // 3 columns with 2px spacing
    }
}

#Preview {
    ExploreView()
}
