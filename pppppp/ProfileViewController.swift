//
//  ProfileViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/15.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBAction func backButton(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
//    var recievedID: String?
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("query : \(url.query!)")
        
    }
    
    
  
}
