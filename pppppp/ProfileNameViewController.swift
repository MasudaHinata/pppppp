//
//  ProfileNameViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/19.
//

import UIKit
import Firebase

class ProfileNameViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var nameTextField: UITextField!
    @IBAction func nameButton() {
        
        profileName = nameTextField.text!
        saveProfileName(profileName: profileName)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ProfileImageViewController")
        self.showDetailViewController(secondVC, sender: self)
        
    }
    
    var profileName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField?.delegate = self
    }
    
    func saveProfileName(profileName: String) {
        //        firebaseに名前を保存
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("UserData")
                .document(currentUser.uid)
                .collection("profileData")
                .document("nameData") // サブコレクションであるprefecturesがない場合、自動でリストが生成される。
                .setData([
                    "name": String(profileName)
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }
        }
    }
    
    
    
    
    
    
}
