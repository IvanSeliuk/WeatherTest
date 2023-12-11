//
//  SearchWeather.swift
//  WeatherTest
//
//  Created by Иван Селюк on 11.12.23.
//

import Foundation


// MARK: - Weather
struct SearchWeather: Decodable, Weather {
    let weather: [SearchWeatherElement]
    let main: SearchMain
    let dt: Int
    let name: String
}

// MARK: - Main
struct SearchMain: Decodable {
    let temp: Double
}

// MARK: - WeatherElement
struct SearchWeatherElement: Decodable {
    let id: Int
    let main, description, icon: String
}

