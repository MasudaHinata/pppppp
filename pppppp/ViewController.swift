import UIKit
import SwiftUI

class ViewController: UIViewController, UITextFieldDelegate {
    
    var me: User!
    var friendIdList = [String]()
    
    var friendList = [User]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: 500, height: 100)
            collectionView.collectionViewLayout = layout
            
            collectionView.register(UINib(nibName: "DashBoardFriendDataCell", bundle: nil), forCellWithReuseIdentifier: "DashBoardFriendDataCell")
        }
    }
    
    
    @IBOutlet var loginLabel: UILabel!
    @IBAction func dataputButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "HealthDataViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let task = Task { [weak self] in
            do {
                let friendIds = try? await FirebaseClient.shared.getfriendIds()
                guard let friendIds = friendIds else { return }
                for id in friendIds {
                    let friend = try? await FirebaseClient.shared.getUserDataFromId(friendId: id)
                    if let friend = friend {
                        self?.friendList.append(friend)
                        //FIXME: 本当はここで呼びたくない
                        self?.collectionView.reloadData()
                    }
                }
            }
            catch {
                //TODO: ERROR Handling
                print("error")
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardFriendDataCell", for: indexPath)  as! DashBoardFriendDataCell
        cell.nameLabel.text = friendList[indexPath.row].name
        return cell
    }
}
