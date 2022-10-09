import UIKit
import SwiftUI
import Combine
import Kingfisher

@MainActor
final class ProfileViewController: UIHostingController<ProfileContentView>, FireStoreCheckNameDelegate, UIAdaptivePresentationControllerDelegate {

    private var cancellables: [AnyCancellable] = []

    //MARK: 画面遷移
    init(viewModel: ProfileViewModel) {
        super.init(rootView: .init(viewModel: viewModel))

        viewModel.$friendListView
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let friendListViewController = StoryboardScene.FriendListView.initialScene.instantiate()
                self.present(friendListViewController, animated: true)
            }.store(in: &cancellables)

        viewModel.$changeProfileView
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }

                let changeProfileViewController = StoryboardScene.ChangeProfileView.initialScene.instantiate()
                if let sheet = changeProfileViewController.sheetPresentationController {
                    sheet.detents = [.custom { context in 0.35 * context.maximumDetentValue }]
                }
                changeProfileViewController.presentationController?.delegate = self
                self.present(changeProfileViewController, animated: true, completion: nil)
            }.store(in: &cancellables)

        viewModel.$shareMyData
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let shareMyDataViewController = StoryboardScene.ShareMyDataView.initialScene.instantiate()
                self.present(shareMyDataViewController, animated: true)
            }.store(in: &cancellables)

        viewModel.$settingView
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let settingViewController = StoryboardScene.SettingView.initialScene.instantiate()
                self.present(settingViewController, animated: true)
            }.store(in: &cancellables)

    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Setting Delegate
    func notChangeName() {
        let secondVC = StoryboardScene.SetNameView.initialScene.instantiate()
        self.showDetailViewController(secondVC, sender: self)
    }

    func scene() {
        viewDidLoad()
    }
}


//    var completionHandlers = [() -> Void]()
//    var pointDataList = [PointData]()
//    var likedFriendDataList = [UserData]()
//    let layout = UICollectionViewFlowLayout()
//    var cancellables = Set<AnyCancellable>()
//
//    @IBOutlet var sceneFriendListButtonLayout: UIButton!
//
//    @IBOutlet var pointLabel: UILabel!
//
//    @IBOutlet var activityBackgroundView: UIView!
//
//    @IBOutlet var myIconView: UIImageView! {
//        didSet {
//            myIconView.layer.cornerRadius = 36
//            myIconView.clipsToBounds = true
//            myIconView.layer.cornerCurve = .continuous
//        }
//    }
//
//    @IBOutlet var collectionView: UICollectionView! {
//        didSet {
//            collectionView.delegate = self
//            collectionView.dataSource = self
//            layout.minimumLineSpacing = 4.5
//            layout.minimumInteritemSpacing = 4.2
//            collectionView.collectionViewLayout = layout
//            collectionView.register(UINib(nibName: "SummaryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SummaryCollectionViewCell")
//            layout.estimatedItemSize = CGSize(width: 17, height: 16)
//        }
//    }
//
//    @IBOutlet var tableView: UITableView! {
//        didSet {
//            tableView.delegate = self
//            tableView.dataSource = self
//            tableView.register(UINib(nibName: "RecentActivitysTableViewCell", bundle: nil), forCellReuseIdentifier: "RecentActivitysTableViewCell")
//            tableView.backgroundView = nil
//            tableView.backgroundColor = .clear
//        }
//    }
//
//    @IBAction func sceneFriendListButton() {
//        let secondVC = StoryboardScene.FriendListView.initialScene.instantiate()
//        self.navigationController?.pushViewController(secondVC, animated: true)
//    }
//
//    @IBAction func editButtonPressed(_ sender: Any) {
//            if #available(iOS 16.0, *) {
//                let secondVC = StoryboardScene.ChangeProfileView.initialScene.instantiate()
//                if let sheet = secondVC.sheetPresentationController {
//                    sheet.detents = [.custom { context in 0.35 * context.maximumDetentValue }]
//                }
//                secondVC.presentationController?.delegate = self
//                self.present(secondVC, animated: true, completion: nil)
//            } else {
//                let secondVC = StoryboardScene.ChangeProfileView.initialScene.instantiate()
//                self.present(secondVC, animated: true, completion: nil)
//            }
//    }
//
//    @IBAction func sceneSettingView() {
//        let secondVC = StoryboardScene.SettingView.initialScene.instantiate()
//        self.showDetailViewController(secondVC, sender: self)
//    }
//
//    @IBAction func scneShareMyDataView() {
//        let secondVC = StoryboardScene.ShareMyDataView.initialScene.instantiate()
//        self.showDetailViewController(secondVC, sender: self)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        FirebaseClient.shared.notChangeDelegate = self
//
//        let task = Task {  [weak self] in
//            guard let self = self else { return }
//            do {
//                let userID = try await FirebaseClient.shared.getUserUUID()
//                let likedFriendDataList = try await FirebaseClient.shared.getProfileData(includeMe: false)
//                sceneFriendListButtonLayout.titleLabel?.font = UIFont(name: "F5.6", size: 16)
//                sceneFriendListButtonLayout.setTitle("\(likedFriendDataList.count)", for: .normal)
//
//                let type = UserDefaults.standard.object(forKey: "accumulationType") ?? "今日までの一週間"
//                let point = try await FirebaseClient.shared.getPointDataSum(id: userID, accumulationType: type as! String)
//                pointLabel.text = "\(point)"
//
//                try await FirebaseClient.shared.checkNameData()
//                try await FirebaseClient.shared.checkIconData()
//                navigationItem.title = UserDefaults.standard.object(forKey: "name")! as? String
//                myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
//
//                pointDataList = try await FirebaseClient.shared.getPointData(id: userID)
//                pointDataList.reverse()
//                self.collectionView.reloadData()
//                self.tableView.reloadData()
//            }
//            catch {
//                print("ProfileViewContro ViewDid error:",error.localizedDescription)
//                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
//                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
//                        self.viewDidLoad()
//                    }
//                } else {
//                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
//                }
//            }
//        }
//        cancellables.insert(.init { task.cancel() })
//    }
