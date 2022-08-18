//
//  FriendListViewController.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/05/18.
//

import UIKit
import Combine
import Kingfisher

@MainActor
final class FriendListViewController: UIViewController, FirebaseClientDelegate {
    let user = FirebaseClient.shared.user
    var shareUrlString: String?
    var completionHandlers = [() -> Void]()
    var friendList = [User]()
    var friendLists = [UserIcon]()
    var cancellables = Set<AnyCancellable>()
    @IBOutlet var myIconView: UIImageView!
    @IBOutlet var myNameLabel: UILabel!
    @IBAction func goSettingButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "ChangeProfileViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
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
    @IBAction func reloadButton() {
        friendList.removeAll()
        friendLists.removeAll()
        let task = Task { [weak self] in
            do {
                let userID = FirebaseClient.shared.userID
                try await myIconView.kf.setImage(with: FirebaseClient.shared.getMyData(user: userID!))
                try await myNameLabel.text = FirebaseClient.shared.getMyNameData(user: userID!)
                
                let friendIds = try? await FirebaseClient.shared.getfriendIds()
                guard let friendIds = friendIds else { return }
                for id in friendIds {
                    let friend = try? await FirebaseClient.shared.getUserDataFromId(friendId: id)
                    if let friend = friend {
                        self?.friendList.append(friend)
                    }
                    let friendss = try? await FirebaseClient.shared.getIconDataFromId(friendIds: id)
                    if let friendss = friendss {
                        self?.friendLists.append(friendss)
                    }
                    self!.friendcollectionView.reloadData()
                }
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myIconView.layer.cornerRadius = 32
        myIconView.clipsToBounds = true
        myIconView.layer.cornerCurve = .continuous
        
        guard let userID = user?.uid else { return }
        print("自分のユーザーIDを取得しました")
        shareUrlString = "sanitas-ios-dev://?id=\(userID)"
        
        friendList.removeAll()
        friendLists.removeAll()
        let task = Task { [weak self] in
            do {
                let userID = FirebaseClient.shared.userID
                try await myIconView.kf.setImage(with: FirebaseClient.shared.getMyData(user: userID!))
                try await myNameLabel.text = FirebaseClient.shared.getMyNameData(user: userID!)
                
                let friendIds = try? await FirebaseClient.shared.getfriendIds()
                guard let friendIds = friendIds else { return }
                for id in friendIds {
                    let friend = try? await FirebaseClient.shared.getUserDataFromId(friendId: id)
                    if let friend = friend {
                        self?.friendList.append(friend)
                    }
                    let friendss = try? await FirebaseClient.shared.getIconDataFromId(friendIds: id)
                    if let friendss = friendss {
                        self?.friendLists.append(friendss)
                    }
                    self!.friendcollectionView.reloadData()
                }
            }
            catch {
                //TODO: ERROR Handling
                print("error")
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
    
    func friendDeleted() {
        let alert = UIAlertController(title: "友達の削除", message: "友達を削除しました。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    //リンクのシェアシート出す
    @IBAction func pressedButton() {
        showShareSheet()
    }
    func showShareSheet() {
        guard let userID = user?.uid else { return }
        let shareWebsite = URL(string: "sanitas-ios-dev://?id=\(userID)")!
        let activityVC = UIActivityViewController(activityItems: [shareWebsite], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
}

extension FriendListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "frienddatacell", for: indexPath)  as! FriendDataCell
        
        cell.nameLabel.text = friendList[indexPath.row].name
        cell.iconView.kf.setImage(with: URL(string: friendLists[indexPath.row].imageURL)!)
        return cell
    }
    //友達を削除する
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let deleteFriendId = friendList[indexPath.row].id else { return }
        let alert = UIAlertController(title: "注意", message: "友達を削除しますか？", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style: .destructive, handler: { [self] (action) -> Void in
            let task = Task {
                do {
                    try await FirebaseClient.shared.deleteFriendQuery(deleteFriendId: deleteFriendId)
                }
                catch {
                    //TODO: ERROR Handling
                    print("error")
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
