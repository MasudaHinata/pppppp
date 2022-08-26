//
//  FriendListViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/05/18.
//

import UIKit
import Combine
import Kingfisher

protocol sceneChangeProfile {
    func scene()
}

@MainActor
final class FriendListViewController: UIViewController, FirebaseClientDelegate, sceneChangeProfile, FireStoreCheckName {
    func notChangeName() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ChangeNameViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    func scene() {
        viewDidLoad()
    }
    func friendDeleted() {
        let alert = UIAlertController(title: "友達の削除", message: "友達を削除しました。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func to_page2(_ sender: Any) {
        let page2 = self.storyboard?.instantiateViewController(withIdentifier: "ChangeProfileViewController") as! ChangeProfileViewController
        page2.sceneChangeProfile = self
        self.present(page2,animated: true,completion: nil)
    }
    
    var completionHandlers = [() -> Void]()
    var friendDataList = [FriendListItem]()
    var cancellables = Set<AnyCancellable>()
    var refreshCtl = UIRefreshControl()
    @IBOutlet var myIconView: UIImageView!
    @IBOutlet var myNameLabel: UILabel!
    @IBOutlet var friendcollectionView: UICollectionView! {
        didSet {
            FirebaseClient.shared.delegate = self
            friendcollectionView.delegate = self
            friendcollectionView.dataSource = self
            friendcollectionView.register(UINib(nibName: "FriendDataCell", bundle: nil), forCellWithReuseIdentifier: "frienddatacell")
        }
    }
    @IBOutlet var profileBackgroundView: UIView! {
        didSet {
            profileBackgroundView.layer.cornerRadius = 40
            profileBackgroundView.layer.masksToBounds = true
            profileBackgroundView.layer.cornerCurve = .continuous
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseClient.shared.notChangeDelegate = self
        
        refreshCtl.tintColor = .white
        friendcollectionView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(FriendListViewController.refresh(sender:)), for: .valueChanged)
        
        myIconView.layer.cornerRadius = 32
        myIconView.clipsToBounds = true
        myIconView.layer.cornerCurve = .continuous
        friendDataList.removeAll()
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await FirebaseClient.shared.userAuthCheck()
                try await FirebaseClient.shared.emailVerifyRequiredCheck()
                
                try await myIconView.kf.setImage(with: FirebaseClient.shared.getMyIconData())
                try await myNameLabel.text = FirebaseClient.shared.getMyNameData()
                
                friendDataList = try await FirebaseClient.shared.getFriendProfileData()
                self.friendcollectionView.reloadData()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.viewDidLoad()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                print("friendlistViewContro viewdidload error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width, height: 80)
        friendcollectionView.collectionViewLayout = layout
    }
    
    //リンクのシェアシート出す
    @IBAction func pressedButton() {
        showShareSheet()
    }
    func showShareSheet() {
        let task = Task {
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                print("自分のユーザーIDを取得しました")
                let shareWebsite = URL(string: "sanitas-ios-dev://?id=\(userID)")!
                let activityVC = UIActivityViewController(activityItems: [shareWebsite], applicationActivities: nil)
                present(activityVC, animated: true, completion: nil)
            } catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.viewDidLoad()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                print("FriendListViewContro showShareSheet:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    @objc func refresh(sender: UIRefreshControl) {
        let task = Task { [weak self] in
            do {
                friendDataList = try await FirebaseClient.shared.getFriendProfileData()
                self!.friendcollectionView.reloadData()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self!.viewDidLoad()
                }
                alert.addAction(ok)
                self!.present(alert, animated: true, completion: nil)
                print("FreindListViewContro refresh error:", error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
        refreshCtl.endRefreshing()
    }
}

extension FriendListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendDataList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frienddatacell", for: indexPath)  as! FriendDataCell
        
        cell.nameLabel.text = friendDataList[indexPath.row].name
        cell.iconView.kf.setImage(with: URL(string: friendDataList[indexPath.row].IconImageURL)!)
        return cell
    }
    //友達を削除する
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let deleteFriendId = friendDataList[indexPath.row].id else { return }
        let alert = UIAlertController(title: "注意", message: "友達を削除しますか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { [self] (action) -> Void in
            let task = Task {
                do {
                    try await FirebaseClient.shared.deleteFriendQuery(deleteFriendId: deleteFriendId)
                    friendDataList = try await FirebaseClient.shared.getFriendProfileData()
                    self.friendcollectionView.reloadData()
                }
                catch {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.viewDidLoad()
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                    print("FriendListViewContro collectionview error:",error.localizedDescription)
                }
            }
            cancellables.insert(.init { task.cancel() })
        })
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) -> Void in
            print("キャンセル")
        })
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
