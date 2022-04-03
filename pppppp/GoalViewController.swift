//
//  GoalViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2021/06/02.
//

import UIKit

class GoalViewController: UIViewController {
    
    @IBOutlet var goalTextField: UITextField!
    @IBOutlet var goButton: UIButton!
    
    let saveData: UserDefaults = Foundation.UserDefaults.standard

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


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveData.set(goalTextField.text, forKey: "key")
    }

    @IBAction func okButtonPressed() {
        performSegue(withIdentifier: "toTimeline", sender: nil)
    }
}
