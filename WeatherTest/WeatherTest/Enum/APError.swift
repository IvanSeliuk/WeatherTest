//
//  APError.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import Foundation

enum APError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case unableToComplete
}
