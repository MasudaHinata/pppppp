//
//  CccccccViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/30.
//

import UIKit
import Combine

class CccccccViewController: UIViewController {
    
    var friendDataList = [FriendListItem]()
    let layout = UICollectionViewFlowLayout()
    var refreshControl = UIRefreshControl()
    var cancellables = Set<AnyCancellable>()

    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            layout.minimumLineSpacing = 22
            collectionView.collectionViewLayout = layout
            collectionView.register(UINib(nibName: "DashBoardFriendDataCell", bundle: nil), forCellWithReuseIdentifier: "DashBoardFriendDataCell")
        }
    }
    
    @IBOutlet var emojiLabel: UILabel!
    @IBOutlet var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.setTitle("Friend", forSegmentAt: 0)
            segmentedControl.setTitle("Me", forSegmentAt: 1)
            segmentedControl.selectedSegmentIndex = 0
        }
    }
    @IBAction func didSelectSegment() {
        //関連付けするactionはValue Changed
//        emojiLabel.text = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        
        
    }
    
    @objc func segmentChanged(_ segment:UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 0:
            print("左を選択した。")
        case 1:
            print("右を選択した。")
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        emojiLabel.text = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        
        
        layout.estimatedItemSize = CGSize(width: self.view.frame.width * 0.9, height: 130)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        let task = Task {
            do {
                try await FirebaseClient.shared.userAuthCheck()
                friendDataList = try await FirebaseClient.shared.getFriendProfileData()
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
extension CccccccViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendDataList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell

        cell.nameLabel.text = friendDataList[indexPath.row].name
        cell.dataLabel.text = String(friendDataList[indexPath.row].point ?? 0)
        cell.iconView.kf.setImage(with: URL(string: friendDataList[indexPath.row].IconImageURL)!)
        return cell
    }
}

