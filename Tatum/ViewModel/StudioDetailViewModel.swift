//
//  StudioDetailViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 23.12.2025.
//

import SwiftUI
import Combine

class StudioDetailViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var artists: [TatumUser] = []
    @Published var isLoading = false
    
    let studio: Studio
    private let service = StudioContentService()
    
    init(studio: Studio) {
        self.studio = studio
        if studio.isClaimed {
            fetchData()
        }
    }
    
    func fetchData() {
        isLoading = true
        let group = DispatchGroup()
        
        group.enter()
        service.fetchStudioPosts(studioId: studio.id) { [weak self] fetchedPosts in
            self?.posts = fetchedPosts
            group.leave()
        }
        
        group.enter()
        service.fetchStudioArtists(studioId: studio.id) { [weak self] fetchedArtists in
            self?.artists = fetchedArtists
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
}
