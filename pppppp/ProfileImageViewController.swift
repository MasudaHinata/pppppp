//
//  ProfileImageViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/19.
//

import UIKit
import FirebaseStorage
import Firebase
import FirebaseFirestore

class ProfileImageViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBAction func nextButton() {
        //        hantei()
        ImageputFirestore()
        
    }
    @IBAction func uploadButton(_ sender: Any) {
        let picker = UIImagePickerController() //アルバムを開く処理を呼び出す
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.present(picker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        design()
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
    
    //    func design() {
    //        imageView.layer.cornerRadius = 86
    //        imageView.clipsToBounds = true
    //    }
    
//        func hantei() {
//            if imageView == nil {
//                //ここ動いてない
//                print("画像が選択されてない")
//                let alert = UIAlertController(title: "エラー", message: "画像を選択してください", preferredStyle: .alert)
//                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
//                    self.dismiss(animated: true, completion: nil)
//                }
//                alert.addAction(ok)
//                present(alert, animated: true, completion: nil)
//            } else {
//                print("ok")
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let secondVC = storyboard.instantiateViewController(identifier: "ViewController")
//                    self.showDetailViewController(secondVC, sender: self)
//            }
//        }
    
    func ImageputFirestore() {
        if let selectImage = imageView.image {
            // 今日日付をintに変換して被らない名前にする
            let imageName = "\(Date().timeIntervalSince1970).jpg"
            // 今回はpostsというフォルダーの中に画像を保存する
            let reference = Storage.storage().reference().child("posts/\(imageName)")
            // 画像データがそのままだとサイズが大きかったりするので、サイズを調整
            if let imageData = selectImage.jpegData(compressionQuality: 0.8) {
                // メタデータを設定
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                // ①ここでstorageへの保存を行う
                reference.putData(imageData, metadata: metadata, completion:{(metadata, error) in
                    if let _ = metadata {
                        // ②storageへの保存が成功した場合はdownloadURLの取得を行う
                        reference.downloadURL{(url,error) in
                            if let downloadUrl = url {
                                // downloadURLの取得が成功した場合
                                // String型へ変換を行う
                                let downloadUrlStr = downloadUrl.absoluteString
                                // ③firestoreへ保存を行う
                                let user = FirebaseClient.shared.user
                                let db = FirebaseClient.shared.db
                                db.collection("UserData").document(user!.uid).collection("IconData").document("Icon").setData([
                                    "imageURL": downloadUrlStr
                                ]){ error in
                                    if let error = error {
                                        print("firestoreへ保存が失敗")
                                        
                                    } else {
                                        print("firestoreへ保存成功")
                                        self.performSegue(withIdentifier: "tooViewController", sender: nil)
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
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
}
