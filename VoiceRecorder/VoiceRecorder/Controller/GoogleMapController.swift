//
//  GoogleMapController.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/25.
//


import Foundation
import SwiftUI

import GoogleMaps


class GoogleMapController: UIViewController {

	let map =  GMSMapView(frame: .zero)
	var isAnimating: Bool = false

	override func loadView() {
		super.loadView()
		map.isMyLocationEnabled = true
		self.view = map
	}


}

struct GoogleMapControllerBridge : UIViewControllerRepresentable {

	@Binding var markers: [GMSMarker]
	@Binding var selectedMarker: GMSMarker?
	@Binding var isDidTap:Bool
	var zoomLevel:Float

//	var onAnimationEnded: () -> ()
//	var mapViewWillMove: (Bool) -> ()

	func makeUIViewController(context: Context) -> GoogleMapController {

	  let uiViewController = GoogleMapController()
		uiViewController.map.delegate = context.coordinator
	  return uiViewController

	}

	func updateUIViewController(_ uiViewController: GoogleMapController, context: Context) {

	  markers.forEach { $0.map = uiViewController.map }
	  selectedMarker?.map = uiViewController.map

	  animateToSelectedMarker(viewController: uiViewController)
	}


	private func animateToSelectedMarker(viewController: GoogleMapController) {

		guard let selectedMarker = selectedMarker else { return }

		let map = viewController.map

		if map.selectedMarker != selectedMarker {
			map.selectedMarker = selectedMarker
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
				map.animate(toZoom: kGMSMinZoomLevel)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					map.animate(with: GMSCameraUpdate.setTarget(selectedMarker.position))
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
						map.animate(toZoom: self.zoomLevel)
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
						// Invoke onAnimationEnded() once the animation sequence completes
					//	onAnimationEnded()
						})
					})
				}
			}
		}
	}


	final class MapViewCoordinator: NSObject, GMSMapViewDelegate {

		var mapViewControllerBridge: GoogleMapControllerBridge

		init(_ mapViewControllerBridge: GoogleMapControllerBridge) {
			self.mapViewControllerBridge = mapViewControllerBridge
		}

		func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
		//  self.mapViewControllerBridge.mapViewWillMove(gesture)
		}

		func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
			self.mapViewControllerBridge.isDidTap = false
		}

		func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
		//	print("You tapped at \(marker.position.latitude), \(marker.position.longitude)")

			self.mapViewControllerBridge.selectedMarker = marker

			self.mapViewControllerBridge.isDidTap = true
			return false
		}


	}

	func makeCoordinator() -> MapViewCoordinator {
	  return MapViewCoordinator(self)
	}

}
