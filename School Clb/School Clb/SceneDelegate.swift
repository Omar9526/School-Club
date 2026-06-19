//
//  SceneDelegate.swift
//  School Clb
//
//  Created by Omar Ku on 20/5/26.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Настройка SwiftUI root view
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Создаем ContentView как root view
        let contentView = ContentView()
        
        // Создаем UIHostingController для SwiftUI
        let hostingController = UIHostingController(rootView: contentView)
        
        // Создаем и настраиваем window
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = hostingController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Можно удалить
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Можно удалить
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Можно удалить
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Можно удалить
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Можно удалить
    }
}

