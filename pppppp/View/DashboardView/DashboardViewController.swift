//
//  DashboardViewController.swift
//  pppppp
//
//  Created by hinata on 2022/08/29.
//

import UIKit
import Combine

class DashboardViewController: UIViewController {
    var ActivityIndicator: UIActivityIndicatorView!
    var friendDataList = [UserData]()
    let layout = UICollectionViewFlowLayout()
    var refreshCtl = UIRefreshControl()
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
    func refresh() {
        let task = Task { [weak self] in
            do {
                guard let self = self else { return }
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                self.collectionView.reloadData()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alert.addAction(action)
                self!.present(alert, animated: true)
                print("ViewContro refresh error",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
        refreshCtl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout.estimatedItemSize = CGSize(width: self.view.frame.width * 0.9, height: 130)
    
        refreshCtl.tintColor = .white
        collectionView.refreshControl = refreshCtl
        refreshCtl.addAction(.init { _ in self.refresh() }, for: .valueChanged)
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        ActivityIndicator.center = self.view.center
        ActivityIndicator.style = .large
        ActivityIndicator.hidesWhenStopped = true
        self.view.addSubview(ActivityIndicator)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let task = Task {
            do {
                ActivityIndicator.startAnimating()
                try await FirebaseClient.shared.userAuthCheck()
                friendDataList = try await FirebaseClient.shared.getProfileData(includeMe: true)
                self.collectionView.reloadData()
                ActivityIndicator.stopAnimating()
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

extension DashboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell
        
        cell.nameLabel.text = friendDataList[indexPath.row].name
        cell.dataLabel.text = String(friendDataList[indexPath.row].point ?? 0)
        cell.iconView.kf.setImage(with: URL(string: friendDataList[indexPath.row].iconImageURL)!)
        return cell
    }
}

