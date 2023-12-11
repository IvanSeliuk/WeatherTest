//
//  UpdateDate.swift
//  WeatherTest
//
//  Created by Иван Селюк on 11.12.23.
//

import Foundation

enum UpdateDate {
    case lessThanMinute
    case fromMinuteToHour
    case fromHourTo23Hours
    case moreThanDay

    init(timeDifference: Int) {
            switch timeDifference {
            case ..<1:
                self = .lessThanMinute
            case 1..<60:
                self = .fromMinuteToHour
            case 60..<1440:
                self = .fromHourTo23Hours
            default:
                self = .moreThanDay
            }
        }
}
