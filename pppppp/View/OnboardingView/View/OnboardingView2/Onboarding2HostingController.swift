import UIKit
import SwiftUI
import Combine

class Onboarding2HostingController: UIHostingController<Onboarding2ContentView> {

    private var cancellables: [AnyCancellable] = []

    init(viewModel: OnboardingViewModel) {
        super.init(rootView: .init(viewModel: viewModel))

        viewModel.$dismissView
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let mainVC = StoryboardScene.Main.initialScene.instantiate()
                self.showDetailViewController(mainVC, sender: self)
            }.store(in: &cancellables)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

