//
//  WeatherModel.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/17.
//

import Foundation
import CoreData
import CoreLocation

class WeatherModel: ObservableObject {


	@Published var weatherData: WeatherData = WeatherData.makeDefaultValue()

	var locationCtl = LocationController()
	let openWeatherService = NetService()


	func setListWeather(context: NSManagedObjectContext) {
		if let location = locationCtl.cLLocationManager.location {
			let openWeatherURL =
			 "\(OpenWeatherSDKConstants.url)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(OpenWeatherSDKConstants.appid)&units=\(OpenWeatherSDKConstants.units)"

			openWeatherService.requestCurrentWeather(url: openWeatherURL) { result in
				truncateEntity(context: context,  entityName: Entity_Current_Weather.entity().name!)
				result.toEntity_Current_Weather(context: context)
				commitTrans(context: context)
				self.weatherData = result
			}
		}
	}


	func setMemoWeather(context: NSManagedObjectContext, writetime: Double, completion: @escaping ((WeatherData) -> (Void))) {
		if let location = locationCtl.cLLocationManager.location {
			let openWeatherURL =
			"\(OpenWeatherSDKConstants.url)?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(OpenWeatherSDKConstants.appid)&units=\(OpenWeatherSDKConstants.units)"
			openWeatherService.requestCurrentWeather(url: openWeatherURL) { result in
				result.toEntity_Memo_Weather(context: context, writeTime: writetime)
				commitTrans(context: context)
				self.weatherData = result
				completion(result)
			}
		}
	}
	
}


