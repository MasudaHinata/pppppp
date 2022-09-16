//
//  InitialScreenViewController.swift
//  pppppp
//
//  Created by hinata on 2022/09/16.
//

import UIKit

class InitialScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "initialScreen")

        // Do any additional setup after loading the view.
    }
}
