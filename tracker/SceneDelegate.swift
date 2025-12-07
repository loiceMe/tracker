//
//  SceneDelegate.swift
//  tracker
//
//  Created by   Дмитрий Кривенко on 05.09.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        if OnboardingView.hasSeenOnboarding() {
            window?.rootViewController = TabBar()
        } else {
            window?.rootViewController = OnboardingView()
        }
        window?.makeKeyAndVisible()
    }
}

