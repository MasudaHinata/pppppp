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
            changeNameTextField.attributedPlaceholder = NSAttributedString(string: "Change Your Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            changeNameTextField.layer.cornerRadius = 24
            changeNameTextField.clipsToBounds = true
            changeNameTextField.layer.cornerCurve = .continuous
        }
    }
    @IBOutlet var changeNameButton: UIButton! {
        didSet {
            changeNameButton.layer.cornerRadius = 24
            changeNameButton.clipsToBounds = true
            changeNameButton.layer.cornerCurve = .continuous
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
        // Do any additional setup after loading the view.
    }
}
