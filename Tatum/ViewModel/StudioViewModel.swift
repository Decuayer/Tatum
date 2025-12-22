//
//  StudioViewModel.swift
//  Tatum
//
//  Created by Demir Cücü on 19.12.2025.
//

import Foundation
import MapKit
import Combine
import CoreLocation

class StudioViewModel: ObservableObject {
    @Published var studios: [Studio] = []
    @Published var region: MKCoordinateRegion
    
    private let service: StudioService
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    private var claimedStudios: [Studio] = []
    
    init(service: StudioService = StudioService()) {
        self.service = service
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.$region
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] newRegion in
                self?.region = newRegion
                self?.loadAllStudios(in: newRegion)
            }
            .store(in: &cancellables)
    }
    
    func loadAllStudios(in region: MKCoordinateRegion) {
        service.fetchClaimedStudios { [weak self] claimed in
            guard let self = self else { return }
            self.claimedStudios = claimed
            
            self.service.searchStudios(region: region) { [weak self] mapItems in
                guard let self = self else { return }
                self.mergeAndShow(mapStudios: mapItems)
            }
        }
    }
    
    private func mergeAndShow(mapStudios: [Studio]) {
        var finalStudios = self.claimedStudios
        
        for mapStudio in mapStudios {
            let isDuplicate = self.claimedStudios.contains { claimed in
                let claimedLoc = CLLocation(latitude: claimed.latitude, longitude: claimed.longitude)
                let mapLoc = CLLocation(latitude: mapStudio.latitude, longitude: mapStudio.longitude)
                return claimedLoc.distance(from: mapLoc) < 50
            }
            
            if !isDuplicate {
                finalStudios.append(mapStudio)
            }
        }
        
        DispatchQueue.main.async {
            self.studios = finalStudios
        }
    }
}
