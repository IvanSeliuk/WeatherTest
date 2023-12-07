//
//  Weather.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import Foundation

// MARK: - Weather
struct Weather: Codable {
    let list: [List]
    let city: City
}

// MARK: - City
struct City: Codable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
}

// MARK: - Coord
struct Coord: Codable {
    let lat, lon: Double
}

// MARK: - List
struct List: Codable {
    let dt: Int
    let main: Main
    let weather: [WeatherElement]
    let clouds: Clouds
    let visibility: Int

    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, visibility
        case dtTxt = "dt_txt"
    }
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, seaLevel, grndLevel, humidity: Int
    let tempKf: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}



// MARK: - WeatherElement
struct WeatherElement: Codable {
    let main, description, icon: String
}

