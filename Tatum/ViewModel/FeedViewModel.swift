//
//  FeedViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 24.12.2025.
//

import SwiftUI
import Combine

class FeedViewModel: ObservableObject {
    @Published var feedPosts: [Post] = []
    @Published var suggestedPosts: [Post] = []
    @Published var isLoading = false
    
    private let service = FeedService()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        isLoading = true
        let group = DispatchGroup()
        
        group.enter()
        service.fetchFeedPosts { [weak self] posts in
            self?.feedPosts = posts
            group.leave()
        }
        
        group.enter()
        service.fetchSuggestedPosts { [weak self] posts in

            self?.suggestedPosts = posts
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            self.testPosts()
        }
    }
    
    func testPosts() {
        print("--- TEST SUGGESTED POSTS ---")
        suggestedPosts.forEach { post in
            print("ID: \(post.id) - Caption: \(post.caption) - Owner: \(post.ownerUid)")
        }
    }
}
