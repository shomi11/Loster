//
//  SceneDelegate.swift
//  Loster
//
//  Created by Malovic, Milos on 4/21/20.
//  Copyright © 2020 Malovic, Milos. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let board = UIStoryboard(name: "Main", bundle: nil)
    let shortcutFromCameraIdentifier = Bundle.main.bundleIdentifier! + ".runFromCamera"
    let shortcutItem = UIApplicationShortcutItem(type: "devmm11070.com.Loster.runFromCamera",
                                                       localizedTitle: "Add new",
                                                       localizedSubtitle: "direct from camera",
                                                       icon: UIApplicationShortcutIcon(type: .add),
                                                       userInfo: nil)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let valueForPermissions: Bool? = UserDefaults.standard.bool(forKey: "permissions")
        // if user give all permissions we need

        if let value = valueForPermissions {
            if value == true {
                guard let mainVC = board.instantiateViewController(identifier: "LostStuffTableController") as? LostStuffTableController else {fatalError("does not contain view controller")}
                let navController = UINavigationController(rootViewController: mainVC)
                window?.makeKeyAndVisible()
                window?.rootViewController = navController
            }
        }
        
        // if perform quick action
        if let _ = connectionOptions.shortcutItem {
            guard let vc = board.instantiateViewController(identifier: "LostStuffTableController") as? LostStuffTableController else { return }
            let navController = UINavigationController(rootViewController: vc)
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
            vc.cameraBtnPressed()
        }
        
        //  guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == shortcutFromCameraIdentifier {
            guard let vc = board.instantiateViewController(identifier: "LostStuffTableController") as? LostStuffTableController else { return }
            let navController = UINavigationController(rootViewController: vc)
            window?.rootViewController = navController
            window?.makeKeyAndVisible()
            vc.cameraBtnPressed()
            completionHandler(true)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
  
    }

    func sceneWillResignActive(_ scene: UIScene) {

        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

