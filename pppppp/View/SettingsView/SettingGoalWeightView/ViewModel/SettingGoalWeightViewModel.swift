import Foundation
import Combine

final class SettingGoalWeightViewModel: ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    @Published var weightGoal = 0
    @Published var weight = 0

    func setWeightGoal() {
        if weightGoal == 0 {
            print("目標体重を入力してください")
        } else {

            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    if weight != 0 {
                        try await HealthKit_ScoreringManager.shared.writeWeight(weight: Double(weight))
                    }
                    try await FirebaseClient.shared.putWeightGoal(weightGoal: Double(weightGoal))
                    print("記録済み")
                    //TODO: alert・画面遷移
                    //                    ShowAlertHelper.okAlert(vc: self, title: "完了", message: "記録しました") { _ in
                    //                        let mainVC = StoryboardScene.Main.initialScene.instantiate()
                    //                        self.showDetailViewController(mainVC, sender: self)
                    //                    }
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

