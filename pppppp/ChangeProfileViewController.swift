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

class ChangeProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    var cancellables = Set<AnyCancellable>()
    let user = FirebaseClient.shared.user
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
            myIconView.image = selectedImage  //imageViewにカメラロールから選んだ画像を表示する
        }
        self.dismiss(animated: true)  //画像をImageViewに表示したらアルバムを閉じる
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
        profileName = (nameTextField.text!)
        saveProfile(profileName: profileName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        nameTextField.layer.cornerRadius = 24
        nameTextField.clipsToBounds = true
        nameTextField.layer.cornerCurve = .continuous
        myIconView.layer.cornerRadius = 43
        myIconView.clipsToBounds = true
        myIconView.layer.cornerCurve = .continuous
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        let task = Task {
            do {
                let userID = FirebaseClient.shared.userID
                try await myIconView.kf.setImage(with: FirebaseClient.shared.getMyData(user: userID!))
                try await myNameLabel.text = FirebaseClient.shared.getMyNameData(user: userID!)
            }
            catch {
                
            }
        }
    }
    //名前を変更
    func saveProfile(profileName: String) {
        var user = FirebaseClient.shared.user
        let db = FirebaseClient.shared.db
        
        if let selectImage = myIconView.image {
            let imageName = "\(Date().timeIntervalSince1970).jpg"
            let reference = Storage.storage().reference().child("posts/\(imageName)")
            if let imageData = selectImage.jpegData(compressionQuality: 0.8) {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                reference.putData(imageData, metadata: metadata, completion:{(metadata, error) in
                    if let _ = metadata {
                        reference.downloadURL{(url,error) in
                            if let downloadUrl = url {
                                let task = Task {
                                    do {
                                        let downloadUrlStr = downloadUrl.absoluteString
                                        try await FirebaseClient.shared.putIconFirestore(image: downloadUrlStr)
                                        try await FirebaseClient.shared.putNameFirestore(name: profileName)
                                        let alert = UIAlertController(title: "完了", message: "変更しました", preferredStyle: .alert)
                                        let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                                            let task = Task {
                                                do {
                                                    let userID = FirebaseClient.shared.userID
                                                    try await self.myIconView.kf.setImage(with: FirebaseClient.shared.getMyData(user: userID!))
                                                    try await self.myNameLabel.text = FirebaseClient.shared.getMyNameData(user: userID!)
                                                }
                                                catch {
                                                    print("error")
                                                }
                                            }
                                        }
                                        alert.addAction(ok)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    catch {
                                        print("error")
                                    }
                                }
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
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}
