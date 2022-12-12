import Foundation
import Combine

final class Onboarding1ViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()

    @Published var sceneOnboarding2View: Void = ()

    func sceneOnboarding2() {
        self.sceneOnboarding2View = ()
    }
}

