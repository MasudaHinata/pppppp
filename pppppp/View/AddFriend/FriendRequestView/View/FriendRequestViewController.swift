import UIKit
import SwiftUI
import Combine

class FriendRequestHostingViewController: UIHostingController<FriendRequestContentView> {
    private var cancellables: [AnyCancellable] = []

    init(viewModel: FriendRequestViewModel) {
        super.init(rootView: .init(viewModel: viewModel))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
