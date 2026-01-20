import Foundation
import MapKit
import Combine
import CoreLocation

class StudioViewModel: ObservableObject {
    @Published var studios: [Studio] = []
    
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    private let service: StudioService
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    private var lastSearchLocation: CLLocationCoordinate2D?
    private var claimedStudios: [Studio] = []
    
    init(service: StudioService = StudioService()) {
        self.service = service
        setupBindings()
    }
    
    private func setupBindings() {
        locationManager.$userLocation
            .compactMap { $0 }
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coordinate in
                guard let self = self else { return }
                self.region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                self.checkAndSearch(center: coordinate)
            }
            .store(in: &cancellables)
        
        $region
            .debounce(for: .seconds(0.8), scheduler: DispatchQueue.main)
            .sink { [weak self] newRegion in
                self?.checkAndSearch(center: newRegion.center)
            }
            .store(in: &cancellables)
    }
    
    private func checkAndSearch(center: CLLocationCoordinate2D) {
        if let lastLocation = lastSearchLocation {
            let oldLoc = CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
            let newLoc = CLLocation(latitude: center.latitude, longitude: center.longitude)
            
            let distance = oldLoc.distance(from: newLoc)
            
            if distance < 500 {
                return
            }
        }
        
        lastSearchLocation = center
        loadAllStudios(in: MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }
    
    func loadAllStudios(in region: MKCoordinateRegion) {
        print("DEBUG: API İsteği atılıyor... Merkez: \(region.center.latitude), \(region.center.longitude)")
        
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
