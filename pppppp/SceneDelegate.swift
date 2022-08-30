//
//  SceneDelegate.swift
//  pppppp
//
//  Created by 増田ひなた on 2020/12/09.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    private var errorWindow: CoverWindow?
    private var loginWindow: CoverWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        
        errorWindow = CoverWindow(windowScene: scene)
        let vc = UIViewController()
        errorWindow?.rootViewController = vc
        ErrorHelper.shared.viewController = errorWindow?.rootViewController
        errorWindow?.windowLevel = UIWindow.Level.normal + 1
        errorWindow?.isHidden = false
        
        loginWindow = CoverWindow(windowScene: scene)
        let vc2 = UIViewController()
        loginWindow?.rootViewController = vc2
        LoginHelper.shared.viewController = loginWindow?.rootViewController
        loginWindow?.windowLevel = UIWindow.Level.normal + 1
        loginWindow?.isHidden = false
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
       
        var recievedId: String = ""
        if let url = URLContexts.first?.url {
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
            if let queryValue = urlComponents?.queryItems?.first?.value {
                print("クエリ(友達のID)は\(queryValue)")
                recievedId = queryValue
            }
        }
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let resultVC: ProfileViewController = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        resultVC.friendId = recievedId
        self.window?.rootViewController = resultVC
        self.window?.makeKeyAndVisible()
    }
}
