//
//  SceneDelegate.swift
//  PetCareApp
//
//  Created by Teona Tsiramua on 03.01.26.
//


import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    let appDIContainer = AppDIContainer()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let appCoordinator = AppCoordinator(window: window, container: appDIContainer)
        self.appCoordinator = appCoordinator
        appCoordinator.start()
    }
}
