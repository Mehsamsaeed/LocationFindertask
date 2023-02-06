//
//  LocationManger.swift
//  LocationManger
//
//  Created by Mehsam Saeed on 04/02/2023.
//

import Combine
import CoreLocation


class LocationManger: NSObject, CLLocationManagerDelegate, ObservableObject {

    var locationCoordinates = PassthroughSubject<CLLocation, Error>()
    var userPermissionStatus = PassthroughSubject<CLAuthorizationStatus, Never>()

    private override init() {
        super.init()
    }
    static let shared = LocationManger()
    var location:CLLocation?{
        locationManager.location
    }

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
                return manager
    }()

    func requestLocationUpdates() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            
        default:
            break
        }
        userPermissionStatus.send(locationManager.authorizationStatus)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            
        default:
            manager.stopUpdatingLocation()
            userPermissionStatus.send(manager.authorizationStatus)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationCoordinates.send(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCoordinates.send(completion: .failure(error))
    }
}
