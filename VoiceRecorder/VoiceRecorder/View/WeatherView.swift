//
//  WeatherView.swift
//  VoiceRecorder
//
//  Created by 여운칠 on 2022/05/06.
//

import SwiftUI
import CoreLocation

struct WeatherView: View {

	@StateObject var model: WeatherModel

    var body: some View {

		VStack {
				Text(model.weatherData.dt.formatCollectTime() + " " +
					 model.weatherData.name + "/" +
					 model.weatherData.sys.country)
				.font(.system(size: 16, weight: .bold, design: .default))

				Text( "\(model.weatherData.weather[0].main) : \(model.weatherData.weather[0].description)")
				.font(.headline)

				HStack {
					Spacer()
					model.weatherData.weather[0].icon.getIconImage()
					Spacer()

					VStack(alignment: .leading){
						Label("sunrise   " +  model.weatherData.sys.sunrise.formatHHmm(), systemImage: "sunrise")
						Label("sunset    " +  model.weatherData.sys.sunset.formatHHmm(), systemImage: "sunset")
						Label("   temp       " + String(model.weatherData.main.temp) + " ºC", systemImage: "thermometer")
						Label("  min          " + String(model.weatherData.main.temp_min) + " ºC", systemImage: "thermometer.snowflake")
						Label("  max         " + String(model.weatherData.main.temp_max) + " ºC", systemImage: "thermometer.sun")
						Label("   pressure " + String(model.weatherData.main.pressure) + " hPa", systemImage: "tropicalstorm") // bolt.horizontal.icloud
						Label(" humidity  " + String(model.weatherData.main.humidity) + " %" , systemImage: "humidity")
						Label(" wind         " + String(model.weatherData.wind.speed) + " m/s", systemImage: "wind")
						Label(" deg           " + String(model.weatherData.wind.deg) + " º", systemImage: "flag")
						Label("visibility   " + String(model.weatherData.visibility / 1000) + " Km", systemImage: "eye")
					}
					.font(.system(size: 12, weight: .light, design: .rounded))

					Spacer()
				}
			}
    }
}


struct WeatherView_Previews: PreviewProvider {

    static var previews: some View {
        WeatherView(model: WeatherModel())
    }
}
