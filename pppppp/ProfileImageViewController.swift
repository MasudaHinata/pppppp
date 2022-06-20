//
//  ProfileImageViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/19.
//

import UIKit

class ProfileImageViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBAction func nextButton() {
        
        hantei()
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let secondVC = storyboard.instantiateViewController(identifier: "GoalViewController")
//        self.showDetailViewController(secondVC, sender: self)
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
        
        design()
    }
    
    // 画像が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage  //imageViewにカメラロールから選んだ画像を表示する
        }
        self.dismiss(animated: true)  //画像をImageViewに表示したらアルバムを閉じる
    }
    
    // 画像選択がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func design() {
        imageView.layer.cornerRadius = 86
        imageView.clipsToBounds = true
        
    }
    
    func hantei() {
        if imageView == nil {
//            ここ動いてない
            print("画像が選択されてない")
            let alert = UIAlertController(title: "パスワードが一致しません", message: "パスワードを確認してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            
        }else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "GoalViewController")
            self.showDetailViewController(secondVC, sender: self)
        }
        
    }
    
}
