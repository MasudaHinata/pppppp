//
//  GoalViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2021/06/02.
//

import UIKit

class GoalViewController: UIViewController {
    
    @IBOutlet var goalButton: UIButton!
    @IBOutlet var goalTextField: UITextField!
    let saveData: UserDefaults = Foundation.UserDefaults.standard

   override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveData.set(goalTextField.text, forKey: "key")
    }

    @IBAction func okButtonPressed() {
        performSegue(withIdentifier: "toTimeline", sender: nil)
    }
}
