import UIKit
import SwiftUI
import Combine

class FriendListOfFriendsListHostingController: UIHostingController<FriendListOfFriendsListContentView> {

    private var cancellables: [AnyCancellable] = []

    init(viewModel: FriendListOfFriendsListViewModel) {
        super.init(rootView: .init(viewModel: viewModel))

        viewModel.$addFriendView
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }

                let addFriendVC = StoryboardScene.FriendProfileView.initialScene.instantiate()
                addFriendVC.modalPresentationStyle = .fullScreen
                addFriendVC.friendId = viewModel.friendIdOfFriend
                addFriendVC.linkJudge = false
                self.present(addFriendVC, animated: true)

            }.store(in: &cancellables)

        viewModel.$friendProfileView
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }

                let profileVC = ProfileHostingController(viewModel: .init())
                self.present(profileVC, animated: true)

            }.store(in: &cancellables)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
