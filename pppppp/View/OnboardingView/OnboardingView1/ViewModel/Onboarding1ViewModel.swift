import Foundation
import Combine

final class Onboarding1ViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()

    @Published var sceneOnboarding2View: Void = ()
    @Published var healthKitPermissionFlg: Bool = false

    func sceneOnboarding2() {
        self.sceneOnboarding2View = ()
    }

    func getPermissionHealthKit() {
        healthKitPermissionFlg = true
        HealthKit_ScoreringManager.shared.getPermissionHealthKit()
    }

    func checkHealthKitPermission() {
        if healthKitPermissionFlg {
            sceneOnboarding2()
        }
    }
}

