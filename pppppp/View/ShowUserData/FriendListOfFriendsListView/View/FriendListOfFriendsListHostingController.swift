import UIKit
import SwiftUI
import Combine

class FriendListOfFriendsListHostingController: UIHostingController<FriendListOfFriendsListContentView> {

    private var cancellables: [AnyCancellable] = []


    init(viewModel: FriendListOfFriendsListViewModel) {
        super.init(rootView: .init(viewModel: viewModel))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
