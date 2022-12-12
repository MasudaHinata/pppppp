import UIKit
import SwiftUI
import Combine

class Onboarding1HostingController: UIHostingController<Onboarding1ContentView> {

    private var cancellables: [AnyCancellable] = []

    init(viewModel: Onboarding1ViewModel) {
        super.init(rootView: .init(viewModel: viewModel))

        //MARK: 画面遷移
        viewModel.$getPermissionHealthKitView
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }

                HealthKit_ScoreringManager.shared.getPermissionHealthKit()

            }.store(in: &cancellables)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
