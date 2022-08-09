//
//  SettingIconViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/08/09.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class SettingIconViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 86
        imageView.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func imagePutFirebase() {
        if let selectImage = imageView.image {
            let imageName = "\(Date().timeIntervalSince1970).jpg"
            let reference = Storage.storage().reference().child("posts/\(imageName)")
            if let imageData = selectImage.jpegData(compressionQuality: 0.8) {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                reference.putData(imageData, metadata: metadata, completion:{(metadata, error) in
                    if let _ = metadata {
                        reference.downloadURL{(url,error) in
                            if let downloadUrl = url {
                                let downloadUrlStr = downloadUrl.absoluteString
                                
                                var user = FirebaseClient.shared.user
                                let db = FirebaseClient.shared.db
                                db.collection("UserData").document(user!.uid).collection("IconData").document("Icon").setData([
                                    "imageURL": downloadUrlStr
                                ]){ error in
                                    if let error = error {
                                        print("firestoreへ保存が失敗")
                                        
                                    } else if error == nil {
                                        print("画像をfirestoreへ保存成功")
                                        let alert = UIAlertController(title: "完了", message: "アイコンを変更しました", preferredStyle: .alert)
                                        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                        alert.addAction(ok)
                                        self.present(alert, animated: true, completion: nil)
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
            imageView.image = selectedImage  //imageViewにカメラロールから選んだ画像を表示する
        }
        self.dismiss(animated: true)  //画像をImageViewに表示したらアルバムを閉じる
    }
    //画像選択がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
