//
//  ChangeProfileViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/09.
//

import UIKit
import Combine
import Firebase
import FirebaseFirestore


class ChangeProfileViewController: UIViewController {
    var cancellables = Set<AnyCancellable>()
    let user = FirebaseClient.shared.user
    var profileName: String = ""
    var myName: String!
    @IBOutlet var myIconView: UIImageView!
    @IBOutlet var myNameLabel: UILabel!
    @IBAction func goSettingButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "SettingIconViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    @IBOutlet var nameTextField: UITextField! {
        didSet {
            nameTextField.attributedPlaceholder = NSAttributedString(string: "change you name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBAction func changeName() {
        profileName = (nameTextField.text!)
        saveProfileName(profileName: profileName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMyData()
        // Do any additional setup after loading the view.
    }
    //自分のアイコンと名前を表示
    func getMyData() {
        let db = Firestore.firestore()
        let user = FirebaseClient.shared.user
        
        let docRef = db.collection("UserData").document(user!.uid).collection("IconData").document("Icon")
        docRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                print("Document data: \(document.data()!["imageURL"]!)")
                let imageUrl:URL = URL(string: document.data()!["imageURL"]! as! String)!
                let imageData:Data = try! Data(contentsOf: imageUrl)
                self?.myIconView.image = UIImage(data: imageData)!
            } else {
                print("自分のアイコンなし")
            }
        }
        let doccRef = db.collection("UserData").document(user!.uid)
        doccRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                print("自分の名前は\(document.data()!["name"]!)")
                self?.myNameLabel.text = document.data()!["name"]! as? String
            } else {
                print("error存在してない")
            }
        }
    }
        
    //名前を変更
    func saveProfileName(profileName: String) {
        let db = Firestore.firestore()
        
        if profileName != "" {
            db.collection("UserData").document(user!.uid).setData(["name": String(profileName)]) { [self] err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("名前をfirestoreに保存しました")
                    
                    let alert = UIAlertController(title: "完了", message: "名前を変更しました", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        getMyData()
                    }
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                }
            }
        } else {
        }
    }
    
    //ログアウトする
    @IBAction func logoutButton() {
        do {
            let alert3 = UIAlertController(title: "注意", message: "ログアウトしますか？", preferredStyle: .alert)
            let delete = UIAlertAction(title: "ログアウト", style: .destructive, handler: { [self] (action) -> Void in
                
                let task = Task { [weak self] in
                    do {
                        try await FirebaseClient.shared.logout()
                        print("ログアウトしました")
                        let alert = UIAlertController(title: "ログアウトしました", message: "ありがとうございました", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                            self?.showDetailViewController(secondVC, sender: self)
                        }
                        alert.addAction(ok)
                        self?.present(alert, animated: true, completion: nil)
                    }
                    catch {
                        //TODO: ERROR Handling
                        print("error")
                    }
                }
                self.cancellables.insert(.init { task.cancel() })
            })
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
                print("キャンセル")
            })
            alert3.addAction(delete)
            alert3.addAction(cancel)
            self.present(alert3, animated: true, completion: nil)
        }
    }
    //アカウントを削除する
    @IBAction func deleteAccount() {
        let alert = UIAlertController(title: "注意", message: "アカウントを削除しますか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { [self] (action) -> Void in
            
            let task = Task { [weak self] in
                do {
                    try await FirebaseClient.shared.accountDelete()
                    try await self?.user?.delete()
                    let alert = UIAlertController(title: "アカウントを削除しました", message: "ありがとうございました", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        print("アカウントを削除しました")
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                        self?.showDetailViewController(secondVC, sender: self)
                    }
                    alert.addAction(ok)
                    self?.present(alert, animated: true, completion: nil)
                }
                catch {
                    print("アカウントを削除できませんでした/エラー:\(String(describing: error))")
                    let alert = UIAlertController(title: "エラー", message: "ログインし直してもう一度お試しください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
                        self?.showDetailViewController(secondVC, sender: self)
                    }
                    alert.addAction(ok)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            cancellables.insert(.init { task.cancel() })
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
            print("キャンセル")
        })
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
