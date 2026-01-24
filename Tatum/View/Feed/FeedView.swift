//
//  FeedView.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import SwiftUI

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundDark")
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        customNavBar
                            .zIndex(1)
                        
                        Divider()
                            .background(Color.gray.opacity(0.2))
                            .padding(.bottom, 10)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 50)
                                .tint(.white)
                        } else {
                            feedSection
                            
                            if !viewModel.feedPosts.isEmpty {
                                caughtUpView
                            } else if !viewModel.isLoading {
                                emptyFeedView
                            }
                            
                            suggestedSection
                        }
                    }
                }
                .refreshable {
                    viewModel.fetchData()
                }
            }
            .navigationBarHidden(true)
            
        }
        .onAppear {
            if viewModel.feedPosts.isEmpty && viewModel.suggestedPosts.isEmpty {
                viewModel.fetchData()
            }
        }
    }
}

// MARK: - Subviews & Sections
extension FeedView {
    
    private var customNavBar: some View {
        ZStack {
            Text("TATUM")
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(Color("BrandPurple"))
            
            HStack {
                Spacer()
                
                HStack(spacing: 20) {
                    NavigationLink(destination: Text("TODO: Notifications screen will be created.")) {
                        Image(systemName: "heart")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 12)
    }
    
    private var feedSection: some View {
        ForEach(viewModel.feedPosts) { post in
            FeedPostView(post: post)
        }
    }
    
    private var suggestedSection: some View {
        LazyVStack(spacing: 0) {
            // Önerilenler Başlığı
            HStack {
                Text("Suggested Posts")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.white)
                Spacer()
                Text("See All")
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(Color("BrandPurple"))
            }
            .padding(.horizontal)
            .padding(.vertical, 15)
            .background(Color("CardDark").opacity(0.3))
            
            ForEach(viewModel.suggestedPosts) { post in
                FeedPostView(post: post)
            }
        }
    }
    
    private var caughtUpView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(Color("BrandPurple"))
                .padding(.bottom, 5)
            
            Text("You're All Caught Up")
                .font(.custom("Poppins-Bold", size: 20))
                .foregroundColor(.white)
            
            Text("You've seen all new posts from the past 2 days.")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color("BackgroundDark"))
    }
    
    private var emptyFeedView: some View {
        VStack(spacing: 15) {
            Text("Welcome to Tatum!")
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundColor(.white)
            
            Text("Follow artists and studios to see their latest work here.")
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Divider().padding(.vertical)
        }
        .padding(.top, 20)
    }
}

#Preview {
    FeedView()
}
