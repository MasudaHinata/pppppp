import UIKit
import SwiftUI
import Combine

class Onboarding1HostingController: UIHostingController<Onboarding1ContentView> {

    private var cancellables: [AnyCancellable] = []

    init(viewModel: Onboarding1ViewModel) {
        super.init(rootView: .init(viewModel: viewModel))

//        //MARK: 画面遷移
//        viewModel.$getPermissionHealthKitView
//            .dropFirst()
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//
//                HealthKitScoreringManager.shared.getPermissionHealthKit()
//
//            }.store(in: &cancellables)

        viewModel.$sceneOnboarding2View
            .dropFirst()
            .sink {
                //TODO: 横に遷移したい
                let Onboarding2VC = Onboarding2HostingController(viewModel: Onboarding2ViewModel())
                Onboarding2VC.modalPresentationStyle = .fullScreen
                self.showDetailViewController(Onboarding2VC, sender: self)
            }.store(in: &cancellables)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
