//
//  Extension.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit

extension UIViewController {

    //MARK: - Network Alert
    func invalidDataAlert() {
        let alertController = UIAlertController(title: "Server Error",
                                                message: "The data received from the server was invalid. Please contact support.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func invalidResponseAlert() {
        let alertController = UIAlertController(title: "Server Error",
                                                message: "Invalid response from the server. Please try again later or contact support.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func invalidURLAlert() {
        let alertController = UIAlertController(title: "Server Error",
                                                message: "There was an issue connecting to the server. If this persists, please contact support.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func unableToCompleteAlert() {
        let alertController = UIAlertController(title: "Server Error",
                                                message: "Unable to complete your request at this time. Please check your internet connection.",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

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
