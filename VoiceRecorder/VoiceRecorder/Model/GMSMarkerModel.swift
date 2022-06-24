//
//  GMSMarkerModel.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/27.
//

import Foundation
import GoogleMaps


class GMSMarkerModel: ObservableObject {

	@Published var currentMarker: GMSMarker?
	@Published var markers: [GMSMarker] = []

}


struct GMSMarkerUserData {
	var id: Double = 0
	var snapshotFileName: String = ""
}
