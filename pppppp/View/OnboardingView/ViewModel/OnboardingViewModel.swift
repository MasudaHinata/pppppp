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
            if granted {
                // 通知の処理
            } else {
                // 許可がないとき
            }
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
            }
        }
        self.cancellables.insert(.init { task.cancel() })
    }
}

