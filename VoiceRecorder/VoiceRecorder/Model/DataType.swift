//
//  DataType.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/21.
//

import Foundation
import SwiftUI
import CoreMIDI

var toolBarBgColor = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
var iconColor = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
var micColor = Color(#colorLiteral(red: 0.1087540463, green: 0.1835740805, blue: 0.2116059959, alpha: 1))

let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let fileNameFormat:String = "YYYYMMdd-HHmmssSSS"
let titleFormat:String = "YYYY/MM/dd HH:mm EEEE"
let recordingFileExe:String = "wav"
let imageFileExe:String = "jpg"
let currentLocale =  Locale(identifier: "ko-KR")
let noData = "No Data"

func deleteFile(fileName:String) {
	let fileURL = documentPath.appendingPathComponent(fileName)
	if FileManager.default.fileExists(atPath: fileURL.path) {
		do {
			try FileManager.default.removeItem(at: fileURL)
		} catch let error as NSError{
			print(#function, error)
		}
	}
}


enum Tag: Int {

	case travel
	case shopping
	case tracking

	var name: String {
		switch self {
		case .travel :   return "여행"
		case .shopping: return "쇼핑"
		case .tracking: return "트레킹"
		}
	}

	var systemImage: String {
		switch self {
		case .travel :   return "airplane.departure"
		case .shopping: return "cart"
		case .tracking: return "figure.walk"
		}
	}

}

enum ImageViewMode:Int {
	case frame
	case full
}

enum CustomSwipeMode:Int {
	case previous
	case next
	case hold
}


enum ScaleEffectValue:CGFloat {
	case two = 1.2
	case four = 1.4
	case six = 1.6
	case pageViewIcon = 1.8
	case double = 2
	case doubleHalf = 2.5
	case triple = 3

}


enum WriteDataType: String, CaseIterable, Identifiable {
		 case snapshot, record, photo
		 var id: Self { self }

	var name: String {
		switch self {
		case .snapshot :   return "Snapshot"
		case .record: return "Record"
		case .photo: return "Photo"
		}
	}

	var systemImage: String {
		switch self {
		case .snapshot :   return "hand.draw.fill"
		case .record: return "mic.fill"
		case .photo: return "camera.fill"
		}
	}

	var deleteMessage: String {
		switch self {
			case .snapshot :   return "Are you sure you want to clear the snapshot file?"
			case .record: return "Are you sure you want to clear the record file?"
			case .photo: return "Are you sure you want to clear the photo file?"
		}
	}

	var deleteTitle: String {
		switch self {
			case .snapshot :   return "Delete Snapshot"
			case .record: return "Delete Record"
			case .photo: return "Delete Photo"
		}}

	var alertMessage: String {
	switch self {
		case .snapshot :   return "Default Snapshot cannot be deleted"
		case .record: return "Default Record cannot be deleted"
		case .photo: return "Default Photo cannot be deleted"
	}}
}

enum SessionStatus {
	case success(title:String, message: String, buttonTitle: String)
	case notAuthorized(title:String, message: String, buttonTitle: String)
	case configurationFailed(title:String, message: String, buttonTitle: String)
}

struct AlertError {
	var title: String = ""
	var message: String = ""
	var primaryButtonTitle: String = ""
	var secondaryButtonTitle: String? = nil
	var primaryAction: (()->())? = nil
	var secondaryAction: (()->())? = nil
}


enum MapType: String, CaseIterable, Identifiable {
		 case normal, hybrid, terrain
		 var id: Self { self }
}
