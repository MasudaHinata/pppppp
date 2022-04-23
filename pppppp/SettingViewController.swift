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
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
//    アカウントを削除する
    @IBAction func deleteAccount() {
        Auth.auth().currentUser?.delete {  (error) in

            if error != nil {
                print("An error happened.")
          } else {
                print("Account deleted.")
//              let alert = UIAlertController(title: "アカウントを削除しました", message: "アカウントを削除しました", preferredStyle: .alert)
//              alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//              self.present(alert, animated: true, completion: nil)
//
//              self.performSegue(withIdentifier: "toBack", sender: nil)
              
              let alert = UIAlertController(title: "注意", message: "アカウントを削除しますか？", preferredStyle: .alert)
                  
                  let delete = UIAlertAction(title: "削除", style: .default, handler: { (action) -> Void in
                      print("アカウントを削除しました")
                  })
                  
                  let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                      print("キャンセル")
                  })
                  
                  alert.addAction(delete)
                  alert.addAction(cancel)
                  
                  self.present(alert, animated: true, completion: nil)
              
          }
        }
    }
    
    
    
    
//    let alert = UIAlertController(title: "タイトル", message: "メッセージ", preferredStyle: .alert)
//    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
//        self.dismiss(animated: true, completion: nil)
//    }
//    //ここから追加
//    let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (acrion) in
//        self.dismiss(animated: true, completion: nil)
//    }
//    alert.addAction(cancel)
//    //ここまで追加
//    alert.addAction(ok)
//    present(alert, animated: true, completion: nil)
    

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
