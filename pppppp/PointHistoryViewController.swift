//
//  PointHistoryViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/30.
//

import UIKit
import Combine

class PointHistoryViewController: UIViewController {
    var pointDataList = [MyPointData]()
    let layout = UICollectionViewFlowLayout()
    //    var refreshControl = UIRefreshControl()
        var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            layout.minimumLineSpacing = 22
            collectionView.collectionViewLayout = layout
            collectionView.register(UINib(nibName: "PointHistoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PointHistoryCollectionViewCell")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.estimatedItemSize = CGSize(width: self.view.frame.width * 0.9, height: 130)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let task = Task {
            do {
                try await FirebaseClient.shared.userAuthCheck()
                pointDataList = try await FirebaseClient.shared.getMyPointData()
                try await FirebaseClient.shared.firebasePutData(point: 30)
                self.collectionView.reloadData()
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
}

extension PointHistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pointDataList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PointHistoryCollectionViewCell", for: indexPath)  as! PointHistoryCollectionViewCell

        cell.pointLabel.text =  String(pointDataList[indexPath.row].point ?? 0)
        cell.dateLabel.text = pointDataList[indexPath.row].id
        return cell
    }
}

