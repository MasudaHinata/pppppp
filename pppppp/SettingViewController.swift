//
//  SettingViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/03/09.
//
import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    var auth: Auth!
    let user = Auth.auth().currentUser
    
//    @IBAction func back() {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    //    ログアウトする
    @IBAction func logoutButton() {
            let firebaseAuth = Auth.auth()
        do {
            let alert3 = UIAlertController(title: "注意", message: "ログアウトしますか？", preferredStyle: .alert)
                
                let delete = UIAlertAction(title: "ログアウト", style: .destructive, handler: { (action) -> Void in
                    Auth.auth().currentUser?.delete()
                    print("ログアウトしました")
                    
                    let alert = UIAlertController(title: "ログアウトしました", message: "ありがとうございました",     preferredStyle: .alert)
                    self.performSegue(withIdentifier: "toAccountCreate", sender: nil)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    
                   
                
                })
                
                let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                    print("キャンセル")
                })
                
                alert3.addAction(delete)
                alert3.addAction(cancel)
                
                self.present(alert3, animated: true, completion: nil)
        
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
            
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                showDetailViewController(secondVC, sender: self)
    }
    
    
    

//    アカウントを削除する
    @IBAction func deleteAccount() {
//        Auth.auth().currentUser?.delete {  (error) in

//            if error != nil {
//                print("An error happened.")
//          } else {
//                print("Account deleted.")
//
              let alert = UIAlertController(title: "注意", message: "アカウントを削除しますか？", preferredStyle: .alert)
                  
                  let delete = UIAlertAction(title: "削除", style: .destructive, handler: { (action) -> Void in
                      Auth.auth().currentUser?.delete()
                      print("アカウントを削除しました")
                      
                      let alert2 = UIAlertController(title: "アカウントを削除しました", message: "ありがとうございました",     preferredStyle: .alert)
                      let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                      self.dismiss(animated: true, completion: nil)
                      }
                      alert2.addAction(ok)
                      self.present(alert2, animated: true, completion: nil)
                      
                      self.performSegue(withIdentifier: "toAccountCreate", sender: nil)
                  })
                  
                  let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                      print("キャンセル")
                  })
                  
                  alert.addAction(delete)
                  alert.addAction(cancel)
                  
                  self.present(alert, animated: true, completion: nil)
    }
//        }
//    }
    
    
    
    
//    self.performSegue(withIdentifier: "toBack", sender: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        auth = Auth.auth()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
