//
//  ChangeNameViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/25.
//

import UIKit
import Combine

class ChangeNameViewController: UIViewController {
    var changename = ""
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var changeNameTextField: UITextField! {
        didSet {
            changeNameTextField.layer.cornerRadius = 24
            changeNameTextField.clipsToBounds = true
            changeNameTextField.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var changeNameButtonLayout: UIButton! {
        didSet {
            changeNameButtonLayout.layer.cornerRadius = 24
            changeNameButtonLayout.clipsToBounds = true
            changeNameButtonLayout.layer.cornerCurve = .continuous
            var configuration = UIButton.Configuration.filled()
            configuration.title = "setting your name"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
            configuration.cornerStyle = .capsule
            changeNameButtonLayout.configuration = configuration
        }
    }
    @IBAction func changeName() {
        let task = Task {
            do {
                changename = changeNameTextField.text!
                if changename != "" {
                try await FirebaseClient.shared.putNameFirestore(name: changename)
                    let alert = UIAlertController(title: "完了", message: "名前を設定しました", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.performSegue(withIdentifier: "fromChangeNameToVIew", sender: nil)
                    }
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "エラー", message: "名前を入力してください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    }
                    alert.addAction(ok)
                    present(alert, animated: true, completion: nil)
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changeNameTextField.resignFirstResponder()
        return true
    }
}
