//
//  SummaryViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/30.
//

import UIKit

class SummaryViewController: UIViewController {

    var friendDataList = [FriendListItem]()
    let layout = UICollectionViewFlowLayout()
//    var refreshControl = UIRefreshControl()
//    var cancellables = Set<AnyCancellable>()

    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            layout.minimumLineSpacing = 4.42
            layout.minimumInteritemSpacing = 4.06
            collectionView.collectionViewLayout = layout
            collectionView.register(UINib(nibName: "SummaryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SummaryCollectionViewCell")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.estimatedItemSize = CGSize(width: 17.67, height: 16.24)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.collectionView.reloadData()
    }
}
extension SummaryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 112
//        return friendDataList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCollectionViewCell", for: indexPath)  as! SummaryCollectionViewCell

        cell.backgroundColor = UIColor(hex: "FFFFFF", alpha: 0.46)


//        let point = 0
//        switch point {
//        case 0 :
//            cell.backgroundColor = UIColor(hex: "FFFFFF", alpha: 0.46)
//        case 1...25:
//            cell.backgroundColor = UIColor(hex: "45E1FF", alpha: 0.46)
//        case 20...50:
//            cell.backgroundColor = UIColor(hex: "3D83BC", alpha: 0.46)
//        case 50...75:
//            cell.backgroundColor = UIColor(hex: "008DDC", alpha: 0.46)
//        case 75...100:
//            cell.backgroundColor = UIColor(hex: "1D5CAC", alpha: 0.46)
//        default: break
//        }


        return cell
    }
}

