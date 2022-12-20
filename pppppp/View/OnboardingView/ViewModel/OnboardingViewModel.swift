import Foundation
import UserNotifications
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()

    @Published var sceneOnboarding2View: Void = ()
    @Published var dismissView: Void = ()

    func dismiss() {
        self.dismissView = ()
    }

    func getNotifiedPermission() -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
            //TODO: Health data is unavailable on this deviceアラート
        }
        return true
    }

    func sceneOnboarding2() {
        self.sceneOnboarding2View = ()
    }

    func getPermissionHealthKit() {
        let task = Task {
            do {
                try await HealthKitScoreringManager.shared.getPermissionHealthKit()
                sceneOnboarding2()
            }
            catch {
                print(error.localizedDescription)
                sceneOnboarding2()
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}

