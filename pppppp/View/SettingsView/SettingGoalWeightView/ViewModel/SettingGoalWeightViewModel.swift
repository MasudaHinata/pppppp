import Foundation
import Combine

final class SettingGoalWeightViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    @Published var weightGoal = 0
    @Published var weight = 0

    @Published var dismissView: Void = ()

    func dismiss() {
        self.dismissView = ()
    }

    func setWeightGoal() {
        if weightGoal == 0 {
            //TODO: alert
            print("目標体重を入力してください")
        } else {
            let task = Task {
                do {
                    if weight != 0 {
                        try await HealthKit_ScoreringManager.shared.writeWeight(weight: Double(weight))
                    }
                    try await FirebaseClient.shared.putWeightGoal(weightGoal: Double(weightGoal))
                    //TODO: alert
                    print("記録済み")
                }
                catch {
                    print("SetGoalWeightViewDid error:", error.localizedDescription)
                    //TODO: alert
                    //                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)")
                }
            }
            self.cancellables.insert(.init { task.cancel() })
        }
    }
}

