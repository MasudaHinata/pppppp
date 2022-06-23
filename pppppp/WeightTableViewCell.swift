//
//  WeightTableViewCell.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/06/23.
//

import UIKit

class WeightTableViewCell: UITableViewCell ,UITableViewDataSource {
    @IBOutlet var table: UITableView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        table.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weigthcell = tableView.dequeueReusableCell(withIdentifier: "WeightCell")
        
        print("cell選ばれてが選ばれて体重が表示されてる")
        weigthcell?.textLabel?.text = "体重うううう"
        
        return weigthcell!
    }

}
