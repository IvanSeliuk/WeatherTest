//
//  Extension.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit

extension UIViewController {

    //MARK: - Location Alert
    func presentSettingsLocationAlert() {
        let alertController = UIAlertController(title: "Your geolocation service is off",
                                                message: "Go to Settings?",
                                                preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}
