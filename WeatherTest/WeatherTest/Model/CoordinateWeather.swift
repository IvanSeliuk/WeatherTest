//
//  CoordinateWeatherWeather.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import Foundation

// MARK: - Weather
struct CoordinateWeather: Codable, Weather {
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
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather
        case dtTxt = "dt_txt"
    }
}

// MARK: - Main
struct Main: Codable {
    let temp: Double
}

// MARK: - WeatherElement
struct WeatherElement: Codable {
    let main, description, icon: String
}

