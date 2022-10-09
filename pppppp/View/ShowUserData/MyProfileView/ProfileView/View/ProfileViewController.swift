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