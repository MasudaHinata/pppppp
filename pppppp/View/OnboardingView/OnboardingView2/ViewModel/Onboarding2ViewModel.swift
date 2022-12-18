import Foundation
import UserNotifications
import Combine

final class Onboarding2ViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()

    @Published var dismissView: Void = ()
    @Published var flg: Bool = false

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
}
