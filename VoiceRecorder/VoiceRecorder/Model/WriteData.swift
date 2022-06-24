//
//  WriteData.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/04/25.
//

import Foundation
import CoreData
import CoreLocation
import UIKit
import SwiftUI



class TextFieldData:ObservableObject {
	@Published var data:String = ""

	init(data:String = ""){
		self.data = data
	}
}

class WriteData:ObservableObject {

	@Published var id:Double = 0
	@Published var snapshots:[ImageView] = []
	@Published var photos:[ImageView] = []
	@Published var records:[RecordView] = []
	@Published var recordTexts:[TextFieldData] = []
	@Published var tags:[TagItem] = []
	@Published var prefrences:[MemoPrefrences] = []
	@Published var isSecret:Bool = false
	@Published var isPin:Bool = false
	@Published var latitude:Double = 0
	@Published var longitude:Double = 0
	@Published var altitude:Double = 0
	@Published var weatherDesc:String = ""

	var memoFilesInfo:[MemoFileInfo] = []


	init(id:Double) {
		self.id = id
	}
	

	func setPrefrences() {
		prefrences.forEach { item in
			switch item.prefrence {
				case .secret: self.isSecret = item.isSelected
				case .pin: self.isPin = item.isSelected
			}
		}
	}


	func setCurrentLocation(location: CLLocation) {
		self.latitude = location.coordinate.latitude
		self.longitude = location.coordinate.longitude
		self.altitude = location.altitude
	}


	func clear() {

		isSecret = false
		isPin = false

		if !snapshots.isEmpty {
			snapshots.removeAll()
		}
		if !photos.isEmpty {
			photos.removeAll()
		}
		if !records.isEmpty {
			records.removeAll()
		}
		if !tags.isEmpty {
			tags.removeAll()
		}
		if !prefrences.isEmpty {
			prefrences.removeAll()
		}
	}

	func makeWeatherDesc(weatherInfo:WeatherData)  {
		self.weatherDesc =
		"\(weatherInfo.weather.first!.main):\(weatherInfo.weather.first!.description)" +
		"  \(weatherInfo.name) / \(weatherInfo.sys.country)"
	}

	private func makeTitle() -> String {
		//"2022/5/4 10:27 수"
		return Date(timeIntervalSince1970: self.id).toString(dateFormat: titleFormat)
	}

	private func makeSnippet() -> String {
		// "Climbing, Tracking"
		var  snippet = ""
		self.tags.forEach { item in
			if item.isSelected {
				snippet +=  " \(item.tag.name)"
			}
		}
		return snippet
	}


	func saveImageToFile() {

		for index in 0..<self.snapshots.count {
			let url = documentPath.appendingPathComponent("\(Date().toString(dateFormat: fileNameFormat))_\(index).\(imageFileExe)" )
			imageToFile (image:snapshots[index].image!, url:url)
			memoFilesInfo.append( MemoFileInfo(type: WriteDataType.snapshot , fileURL: url))
		}

		for index in 0..<self.photos.count {
			let url = documentPath.appendingPathComponent("\(Date().toString(dateFormat: fileNameFormat))_\(index).\(imageFileExe)" )
			imageToFile (image:photos[index].image!, url:url)
			memoFilesInfo.append( MemoFileInfo(type: WriteDataType.photo ,  fileURL: url))
		}

		for index in 0..<self.records.count {
			memoFilesInfo.append(
				MemoFileInfo(type:WriteDataType.record, fileURL:records[index].fileURL, text:recordTexts[index].data)
			)
		}
	}


	private func imageToFile (image:UIImage, url:URL) {
		guard let data: Data = image.jpegData(compressionQuality: 1) else { return }

		do {
			try data.write(to: url)
		} catch {
			fatalError("Unresolved error \(error)")
		}
	}

	private func setMemo(context: NSManagedObjectContext) {
		let entity = Entity_Memo(context: context)

		entity.writetime =  self.id
		entity.altitude = self.altitude
		entity.latitude = self.latitude
		entity.longitude = self.longitude
		entity.isPin = self.isPin
		entity.isSecret = self.isSecret
		entity.snapshotCnt = Int16( self.snapshots.count )
		entity.recordCnt = Int16( self.records.count )
		entity.photoCnt = Int16 ( self.photos.count )
		entity.snapshotFileName = self.memoFilesInfo.first(where: { memoInfo in
			memoInfo.type == WriteDataType.snapshot
		})?.fileURL.lastPathComponent
		entity.desc = self.weatherDesc
		entity.title = makeTitle()
		entity.snippets = makeSnippet()
		commitTrans(context: context)
	}

	private func setMemoTag(context: NSManagedObjectContext) {
		let entity = Entity_Memo_Tag(context: context)
		entity.writetime = self.id
		tags.forEach { item in
			let value:Bool = item.isSelected
			switch item.tag {
				case .shopping : entity.shopping = value
				case .tracking : entity.tracking = value
				case .travel : entity.travel = value
			}
		}
		commitTrans(context: context)
	}



	private func setMemoFile(context: NSManagedObjectContext) {

		for index in 0..<self.memoFilesInfo.count {
			let entity = Entity_Memo_File(context: context)
			entity.writetime = self.id
			entity.fileName = memoFilesInfo[index].fileURL.lastPathComponent
			entity.type = memoFilesInfo[index].type.rawValue
			entity.text = memoFilesInfo[index].text
			commitTrans(context: context)
		}

	}



	func toEntity_Memo(context: NSManagedObjectContext) {

		setMemo(context: context)
		setMemoTag(context: context)
		setMemoFile(context: context)

	}

}



