import UIKit
import SwiftUI
import Combine

class SettingGoalWeightHostingController: UIHostingController<SettingGoalWeightContentView> {

    private var cancellables: [AnyCancellable] = []

    init(viewModel: SettingGoalWeightViewModel) {
        super.init(rootView: .init(viewModel: viewModel))

        //MARK: 画面遷移
        viewModel.$dismissView
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true)
            }.store(in: &cancellables)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
