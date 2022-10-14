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
                self.present(addFriendVC, animated: true)

            }.store(in: &cancellables)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
