//
//  ModelData.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/06.
//

import CoreData
import Foundation
import CoreLocation

final class ModelData: ObservableObject {

	@Published var currentWeather: WeatherData!

	

	init(openWeatherURL: String){
		self.currentWeather = load(openWeatherURL,  false)
	}

}


func load<T: Decodable>(_ filename: String,_ local: Bool) -> T {

	let data: Data

	guard let file = local ? Bundle.main.url(forResource: filename, withExtension: nil) :  URL(string:filename)
	else {
		fatalError("Couldn't find \(filename) in main bundle.")
	}

	do {
		data = try Data(contentsOf: file)
	} catch {
		fatalError("Couldn't load \(filename) in main bundle:\n\(error)")
	}

	do{
		let decoder = JSONDecoder()
		return try decoder.decode(T.self, from: data)
	} catch {
		fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
	}

}
