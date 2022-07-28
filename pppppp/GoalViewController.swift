//
//  GoalViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2021/06/02.
//

import UIKit
import Firebase

class GoalViewController: UIViewController {
    
    @IBOutlet var goalTextField: UITextField!
    @IBOutlet var goButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        design()
    }
    
    func design() {
        goalTextField.layer.cornerRadius = 24
        goButton.layer.cornerRadius = 24
        goalTextField.clipsToBounds = true
        goButton.clipsToBounds = true
    }

    @IBAction func okButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
}
