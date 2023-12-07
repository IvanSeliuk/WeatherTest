//
//  StackView + Ex.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit

extension UIStackView {

    convenience init(arrangedSubviews: [UIView],
                     axis: NSLayoutConstraint.Axis,
                     spacing: CGFloat,
                     distribution: UIStackView.Distribution) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
