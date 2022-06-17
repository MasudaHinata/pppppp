import UIKit
import Firebase      

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        return true
    }
    
    
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        if let query = url.query {
//
////            self.window = UIWindow(frame: UIScreen.main.bounds)
////            let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "profile") as? ProfileViewController
////            vc?.recievedID = query
////            self.window?.rootViewController = vc
////            self.window?.makeKeyAndVisible()
////
//
//
////            print("呼ばれたよ")
////            self.window?.rootViewController = ProfileViewController()
//        }
//        return true
//    }
//
    
//    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//
//
//           //遷移させたいViewControllerが格納されているStoryBoardファイルを指定
//        let MainStoryboard: UIStoryboard = UIStoryboard(name: "profile", bundle: nil)
//        let resultVC: ProfileViewController = MainStoryboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
//        self.window?.rootViewController = resultVC
//
//        self.window?.makeKeyAndVisible()
//        return true
//    }

    
}

