//
//  LocationController.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/27.
//

import Foundation
import CoreLocation


class LocationController: NSObject, CLLocationManagerDelegate {

	var cLLocationManager = CLLocationManager()

	override init() {
		super.init()
		self.cLLocationManager.delegate = self
		self.cLLocationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.cLLocationManager.requestWhenInUseAuthorization()
	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
			case .notDetermined:
				self.cLLocationManager.requestWhenInUseAuthorization()
			case .restricted, .denied:
				return
			case .authorizedAlways, .authorizedWhenInUse:
				self.cLLocationManager.startUpdatingLocation()
			@unknown default:
				self.cLLocationManager.requestWhenInUseAuthorization()
		}
	//	print(#function, status.name)
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(#function, error.localizedDescription)
	}

}
