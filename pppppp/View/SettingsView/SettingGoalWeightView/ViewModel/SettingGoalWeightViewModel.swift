import Foundation
import Combine

final class SettingGoalWeightViewModel: ObservableObject {

    enum AlertType {
        case warning
        case complete
    }
    @Published var alertType: AlertType = .warning

    private var cancellables = Set<AnyCancellable>()
    @Published var weightGoal = 0
    @Published var weight = 0
    @Published var showingAlert = false

    @Published var dismissView: Void = ()

    func dismiss() {
        self.dismissView = ()
    }

    func setWeightGoal() {
        if weightGoal == 0 {
            //TODO: alert
            alertType = .warning
            self.showingAlert = true
            print("目標体重を入力してください")
        } else {
            let task = Task {
                do {
                    if weight != 0 {
                        try await HealthKitScoreringManager.shared.writeWeight(weight: Double(weight))
                    }
                    try await FirebaseClient.shared.putWeightGoal(weightGoal: Double(weightGoal))
                    alertType = .complete
                    self.showingAlert = true
                }
                catch {
                    print("SetGoalWeightViewDid error:", error.localizedDescription)
                }
            }
            self.cancellables.insert(.init { task.cancel() })
        }
    }
}

