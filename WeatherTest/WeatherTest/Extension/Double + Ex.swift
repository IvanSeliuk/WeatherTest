//
//  Double + Ex.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import Foundation

extension Double {
    var celsius: Int {
        Int(Double(self) - 273.15)
    }
}
