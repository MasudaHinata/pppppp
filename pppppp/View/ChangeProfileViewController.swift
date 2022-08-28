//
//  ChangeProfileViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/09.
//

import UIKit
import Combine
import FirebaseStorage
import Kingfisher

class ChangeProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FirebaseDeleteAccount {
    
    var cancellables = Set<AnyCancellable>()
    var profileName: String = ""
    var myName: String!
    @IBOutlet var myIconView: UIImageView!
    @IBOutlet var myNameLabel: UILabel!
    
    
    var sceneChangeProfile: sceneChangeProfile!
    @IBAction func back_page1(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.sceneChangeProfile.scene()
        })
    }
    //アルバムを開く処理を呼び出す
    @IBAction func uploadButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.present(picker, animated: true, completion: nil)
    }
    //画像が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        if let selectedImage = info[.originalImage] as? UIImage {
            myIconView.image = selectedImage
        }
        self.dismiss(animated: true)
    }
    //画像選択がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var nameTextField: UITextField! {
        didSet {
            nameTextField.attributedPlaceholder = NSAttributedString(string: "change you name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var change: UIButton! {
        didSet {
            change.layer.cornerRadius = 24
            change.clipsToBounds = true
            change.layer.cornerCurve = .continuous
        }
    }
    
    @IBAction func changeProfile() {
        saveProfile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.deleteAccount = self
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        nameTextField.layer.cornerRadius = 24
        nameTextField.clipsToBounds = true
        nameTextField.layer.cornerCurve = .continuous
        myIconView.layer.cornerRadius = 43
        myIconView.clipsToBounds = true
        myIconView.layer.cornerCurve = .continuous
    }
    override func viewDidAppear(_ animated: Bool) {
        let task = Task {
            do {
                try await myIconView.kf.setImage(with: FirebaseClient.shared.getMyIconData())
                try await myNameLabel.text = FirebaseClient.shared.getMyNameData()
            }
            catch {
                
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    //名前を変更
    func settingChangeName(profileName: String) {
        if profileName == "" {
            print("名前変更なし")
        } else if profileName != "" {
            Task {
                do {
                    try await FirebaseClient.shared.putNameFirestore(name: profileName)
                }
                catch {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    print("ChangeProfile settingChangeName91:", error.localizedDescription)
                }
            }
        }
    }
    //プロフィールを変更
    func saveProfile() {
        if let selectImage = myIconView.image {
            let imageName = "\(Date().timeIntervalSince1970).jpg"
            let reference = Storage.storage().reference().child("posts/\(imageName)")
            if let imageData = selectImage.jpegData(compressionQuality: 0.8) {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                reference.putData(imageData, metadata: metadata, completion:{(metadata, error) in
                    if let _ = metadata {
                        reference.downloadURL{ [self] (url,error) in
                            if let downloadUrl = url {
                                let task = Task {
                                    do {
                                        let downloadUrlStr = downloadUrl.absoluteString
                                        profileName = (self.nameTextField.text!)
                                        try await FirebaseClient.shared.putIconFirestore(imageURL: downloadUrlStr)
                                        self.settingChangeName(profileName: self.profileName)
                        
                                        let alert = UIAlertController(title: "完了", message: "変更しました", preferredStyle: .alert)
                                        let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                                            dismiss(animated: true, completion: {
                                                self.sceneChangeProfile.scene()
                                            })
                                        }
                                        alert.addAction(ok)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    catch {
                                        let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                                        let action = UIAlertAction(title: "OK", style: .default)
                                        alert.addAction(action)
                                        self.present(alert, animated: true)
                                        print("ChangeProfileView 134 error:", error.localizedDescription)
                                    }
                                }
                                self.cancellables.insert(.init { task.cancel() })
                            } else {
                                print("downloadURLの取得が失敗した場合の処理")
                            }
                        }
                    } else {
                        print("storageの保存が失敗")
                    }
                })
            }
        } else {
            print("画像が選択されてない")
            let alert = UIAlertController(title: "エラー", message: "画像を選択してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
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
                        let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(action)
                        self!.present(alert, animated: true)
                        print("Change Logout error", error.localizedDescription)
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
                }
                catch {
                    print("ChangeProfile deleteAccount210:\(String(describing: error.localizedDescription))")
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
    func accountDeleted() {
        let alert = UIAlertController(title: "完了", message: "アカウントを削除しました", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
            self.showDetailViewController(secondVC, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func faildAcccountDelete() {
        let alert = UIAlertController(title: "ログインしなおしてもう一度試してください", message: "データが全て消えている可能性があります", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AccountViewController")
            self.showDetailViewController(secondVC, sender: self)
        }
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    func faildAcccountDeleteData() {
        let alert = UIAlertController(title: "もう一度試してください", message: "データの削除に失敗しました", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}
