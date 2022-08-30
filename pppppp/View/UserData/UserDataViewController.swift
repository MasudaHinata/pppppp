//
//  UserDataViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/30.
//

import UIKit
import Combine

class UserDataViewController: UIViewController {

//    var friendDataList = [UserData]()
    let layout = UICollectionViewFlowLayout()
    var cancellables = Set<AnyCancellable>()
    var userDataItem: UserData?
    var pointDataList = [PointData]()
    
    @IBOutlet var namelabel: UILabel!
    @IBOutlet var iconView: UIImageView! {
        didSet {
            iconView.layer.cornerRadius = 24
            iconView.layer.cornerCurve = .continuous
        }
    }
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
        let task = Task {
            do {
//                pointDataList = try await FirebaseClient.shared.getPointData(id: (userDataItem?.id)!)
//                print(pointDataList)
//                self.collectionView.reloadData()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.viewDidLoad()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                print("CollectionViewContro ViewDid error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.collectionView.reloadData()
        iconView.kf.setImage(with: URL(string: userDataItem!.iconImageURL))
        namelabel.text = userDataItem?.name
    }
}
extension UserDataViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 112
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SummaryCollectionViewCell", for: indexPath)  as! SummaryCollectionViewCell

        cell.backgroundColor = UIColor(hex: "FFFFFF", alpha: CGFloat(indexPath.row) / 112)
        print(indexPath.row)
//
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

