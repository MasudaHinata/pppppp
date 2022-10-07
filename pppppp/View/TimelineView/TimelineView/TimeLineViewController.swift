import UIKit

class TimeLineViewController: UIViewController {
    
    let layout = UICollectionViewFlowLayout()
    var refreshCtl = UIRefreshControl()
    var postDataItem = [PostDisplayData]()
    
    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.collectionViewLayout = layout
            collectionView.register(UINib(nibName: "TimelinePostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TimelinePostCollectionViewCell")
        }
    }
    
    @IBAction func bellButton() {
        let secondVC = StoryboardScene.TimelineNotificationView.initialScene.instantiate()
        self.navigationController?.pushViewController(secondVC, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshCtl.tintColor = .white
        collectionView.refreshControl = refreshCtl
        refreshCtl.addAction(.init { _ in self.refresh() }, for: .valueChanged)
        layout.estimatedItemSize = CGSize(width: self.view.frame.width * 0.96, height: 104)
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                postDataItem = try await FirebaseClient.shared.getPointActivityPost()
                collectionView.reloadData()
            }
            catch {
                print("TimeLineViewContro viewdid error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
                        self.viewDidAppear(true)
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    //MARK: - 引っ張ってcollectionViewの更新する
    func refresh() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                postDataItem = try await FirebaseClient.shared.getPointActivityPost()
                collectionView.reloadData()
            }
            catch {
                print("TimeLineViewContro refresh error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
                        self.viewDidLoad()
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
        refreshCtl.endRefreshing()
    }
}
