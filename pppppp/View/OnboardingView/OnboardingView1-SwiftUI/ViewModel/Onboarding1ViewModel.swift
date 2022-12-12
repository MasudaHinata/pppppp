import Foundation
import Combine

final class Onboarding1ViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()

    @Published var getPermissionHealthKitView: Void = ()

    func getPermissionHealthKit() {
        self.getPermissionHealthKitView = ()
    }
}

