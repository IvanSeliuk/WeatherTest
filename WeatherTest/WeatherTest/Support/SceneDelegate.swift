//
//  SceneDelegate.swift
//  WeatherTest
//
//  Created by Иван Селюк on 7.12.23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: LoadingViewController())
        window?.makeKeyAndVisible()
    }
}

