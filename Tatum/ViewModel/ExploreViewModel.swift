//
//  ExploreViewModel.swift
//  Tatum
//
//  ViewModel for Discovery/Explore page with category filtering
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class ExploreViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var filteredPosts: [Post] = []
    @Published var isLoading = false
    @Published var selectedCategory: TattooCategory? = nil
    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchDebounce()
        setupCategoryFilter()
    }
    
    /// Fetch all public posts for discovery
    func fetchPosts() {
        isLoading = true
        
        Firestore.firestore()
            .collection("posts")
            .whereField("isPrivate", isEqualTo: false)  // Only public posts
            .order(by: "timestamp", descending: true)
            .limit(to: 50)  // Initial load limit
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("DEBUG: Error fetching explore posts - \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }
                
                self.posts = documents.compactMap { try? $0.data(as: Post.self) }
                self.applyFilters()
                self.isLoading = false
            }
    }
    
    /// Apply category and search filters
    private func applyFilters() {
        var filtered = posts
        
        // Category filter
        if let category = selectedCategory {
            filtered = filtered.filter { post in
                post.tattooCategories.contains(category)
            }
        }
        
        // Search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { post in
                post.caption.lowercased().contains(searchText.lowercased())
            }
        }
        
        filteredPosts = filtered
    }
    
    /// Setup debounced search
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    /// Setup category filter observer
    private func setupCategoryFilter() {
        $selectedCategory
            .sink { [weak self] _ in
                self?.applyFilters()
            }
            .store(in: &cancellables)
    }
    
    /// Select a category filter
    func selectCategory(_ category: TattooCategory?) {
        selectedCategory = category
    }
    
    /// Clear all filters
    func clearFilters() {
        selectedCategory = nil
        searchText = ""
    }
}
