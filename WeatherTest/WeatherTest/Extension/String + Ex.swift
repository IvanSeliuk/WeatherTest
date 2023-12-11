//
//  String + Ex.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import Foundation

extension String {

    func firstWordCapitalized() -> String {
        guard !isEmpty else { return self }
        let firstIndex = self.index(startIndex, offsetBy: 1)
        let firstLetterCapitalized = self[..<firstIndex].uppercased()
        let remainingLetters = self[firstIndex...]
        return firstLetterCapitalized + remainingLetters
    }
}

extension String {
    
    var localized: String {
        guard let url = Bundle.main.url(forResource: Setting.shared.currentLanguage, withExtension: "lproj"),
              let bundle = Bundle(url: url) else { return self }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}
