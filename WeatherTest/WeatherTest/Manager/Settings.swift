//
//  Settings.swift
//  WeatherTest
//
//  Created by Иван Селюк on 11.12.23.
//

import UIKit

final class Setting: NSObject {
    static let shared = Setting()
    let languageCode = ["ru", "en"]

    enum UserDefaultsKeys: String {
        case language
        case requestDate
    }

    var currentLanguage: String {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.language.rawValue) }
        get { return UserDefaults.standard.string(forKey: UserDefaultsKeys.language.rawValue) ?? "en" }
    }

    var requestDate: Date {
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.requestDate.rawValue) }
        get { return UserDefaults.standard.object(forKey: UserDefaultsKeys.requestDate.rawValue) as! Date}
    }
}
