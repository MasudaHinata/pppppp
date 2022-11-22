import UIKit
import SwiftUI
import Combine

class SettingGoalWeightHostingController: UIHostingController<SettingGoalWeightContentView> {

    private var cancellables: [AnyCancellable] = []

    init(viewModel: SettingGoalWeightViewModel) {
        super.init(rootView: .init(viewModel: viewModel))
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
