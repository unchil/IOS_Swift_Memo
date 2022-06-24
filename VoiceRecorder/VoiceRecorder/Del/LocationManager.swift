//
//  LocationManager.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/25.
//


import Foundation
import CoreLocation
import GoogleMaps

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

	let locationManager:CLLocationManager

	//var completionHandler: ((CLLocationCoordinate2D) -> (Void))?
	var completionHandler: ((CLLocation) -> (Void))?
	@Published var authorizationStatus: CLAuthorizationStatus?

	@Published var lastLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)

	@Published var currentMarker: GMSMarker?

	@Published var markers: [GMSMarker] = []

	override init() {
	
		locationManager = CLLocationManager()

		super.init()
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()

	}


	var statusString: String {
		guard let status = authorizationStatus else {
			return "unknown"
		}
		switch status {
		case .notDetermined: return "notDetermined"
		case .authorizedWhenInUse: return "authorizedWhenInUse"
		case .authorizedAlways: return "authorizedAlways"
		case .restricted: return "restricted"
		case .denied: return "denied"
		default: return "unknown"
		}
	}

//	func updateCurrentLocation(completion: @escaping ((CLLocationCoordinate2D) -> (Void))) {
	func updateCurrentLocation(completion: @escaping ((CLLocation) -> (Void))) {
		self.locationManager.startUpdatingLocation()
		self.completionHandler = completion
	}


	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		authorizationStatus = status
		if ( status == .authorizedAlways || status == .authorizedWhenInUse ) {
			locationManager.startUpdatingLocation()
		}
		print(#function, statusString)
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		manager.stopUpdatingLocation()
		guard let location = locations.last else { return }
		self.lastLocation = location

		currentMarker = GMSMarker(position:CLLocationCoordinate2D(latitude: location.coordinate.latitude ,longitude: location.coordinate.longitude ))
		markers.append(currentMarker!)

		if let completion = self.completionHandler {
			completion(location)
		}
		print(#function, location)
	}

}




