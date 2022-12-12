import UIKit
import SwiftUI
import Combine

class Onboarding2HostingController: UIHostingController<Onboarding2ContentView> {

    private var cancellables: [AnyCancellable] = []

    init(viewModel: Onboarding2ViewModel) {
        super.init(rootView: .init(viewModel: viewModel))

        //MARK: 画面遷移
        viewModel.$getPermissionHealthKitView
            .dropFirst()
            .sink {
                HealthKit_ScoreringManager.shared.getPermissionHealthKit()
            }.store(in: &cancellables)

    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
