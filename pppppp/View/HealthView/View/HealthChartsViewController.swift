import UIKit
import SwiftUI
import Charts
import Combine

@available(iOS 16.0, *)
class HealthChartsViewController: UIHostingController<HealthChartsContentView> {

    private var cancellables: [AnyCancellable] = []

    init(viewModel: HealthChartsViewModel) {
        super.init(rootView: .init(viewModel: viewModel))
    }

    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
