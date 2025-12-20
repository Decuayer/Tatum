//
//  StudioViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import MapKit
import Combine

class StudioViewModel: ObservableObject {
    @Published var studios: [Studio] = []
    
    // Varsayılan Konum
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    private let service: StudioServiceProtocol
    
    // Dependecy Injection
    
    init(service: StudioServiceProtocol = StudioService()) {
        self.service = service
        fetchStudios()
    }
    
    func fetchStudios() {
        service.fetchStudios { [weak self] studios in
            DispatchQueue.main.async {
                self?.studios = studios
            }
        }
    }
}
