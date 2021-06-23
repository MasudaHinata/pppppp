//
//  data.swift
//  pppppp
//
//  Created by Masakaz Ozaki on 2021/06/23.
//

import UIKit

class DataViewController: UIViewController {

    @IBOutlet var label: UILabel!
    let saveData: UserDefaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        label.text = saveData.string(forKey: "key")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
