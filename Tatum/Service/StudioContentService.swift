//
//  StudioContentService.swift
//  Tatum
//
//  Created by Demir Cücü on 23.12.2025.
//

import FirebaseFirestore

class StudioContentService: @unchecked Sendable {
    
    func fetchStudioPosts(studioId: String, completion: @escaping ([Post]) -> Void) {
        Firestore.firestore().collection("posts")
            .whereField("studioId", isEqualTo: studioId)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    completion([])
                    return
                }

                let posts = documents.compactMap { try? $0.data(as: Post.self) }
                completion(posts)
            }
    }
    
    func fetchStudioArtists(studioId: String, completion: @escaping ([TatumUser]) -> Void) {
        Firestore.firestore().collection("users")
            .whereField("studioId", isEqualTo: studioId)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    completion([])
                    return
                }
                
                let artists = documents.compactMap { try? $0.data(as: TatumUser.self) }
                completion(artists)
            }
    }
}
