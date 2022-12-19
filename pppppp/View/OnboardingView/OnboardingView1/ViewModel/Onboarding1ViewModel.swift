import Foundation
import Combine

@MainActor
final class Onboarding1ViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()

    @Published var sceneOnboarding2View: Void = ()

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

