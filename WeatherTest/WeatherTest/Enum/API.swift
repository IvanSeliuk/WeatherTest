//
//  API.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import Foundation

enum API: String {
    case APIKey = "9872cf2db2b7f253bfd07c00eb5c255d"

    case host = "https://api.openweathermap.org/"
    
    case city = "data/2.5/weather?q=%@&cnt=3&appid=%@"

    case coordinate = "data/2.5/forecast?lat=%.3f&lon=%.3f&cnt=7&appid=%@"

    case icon = "https://openweathermap.org/img/wn/%@@2x.png"


    func getCity(by name: String) -> URL? {
        let completedString = String(format: API.city.rawValue, name, API.APIKey.rawValue)
        return URL(string: API.host.rawValue + completedString)
    }

    func getIconUrl(by icon: String) -> URL? {
        let completedString = String(format: API.icon.rawValue, icon)
        return URL(string: completedString)
    }

    func getCoordinate(lat: Double, lon: Double) -> URL? {
        let completedString = String(format: API.coordinate.rawValue, lat, lon, API.APIKey.rawValue)
        return URL(string: API.host.rawValue + completedString)
    }
}
