import UIKit
import Combine
import SwiftUI
import Charts

class HealthChartsViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    var chartsStepItem = [ChartsStepItem]()

    @IBOutlet var stepChartsView: UIView!
    @IBOutlet var averageStepLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Asset.Colors.mainColor.color
        let task = Task {  [weak self] in
            guard let self = self else { return }
            do {
                let averageStep = try await Scorering.shared.getAverageStepPoint()
                chartsStepItem = try await Scorering.shared.createWeekStepsChart()
                chartsStepItem.reverse()
                let vc: UIHostingController = UIHostingController(rootView: StepsChartsUIView(data: chartsStepItem))
                stepChartsView.addSubview(vc.view)
                vc.view.translatesAutoresizingMaskIntoConstraints = false
                vc.view.topAnchor.constraint(equalTo: stepChartsView.topAnchor, constant: 54).isActive = true
                vc.view.bottomAnchor.constraint(equalTo: stepChartsView.bottomAnchor, constant: -8).isActive = true
                vc.view.leftAnchor.constraint(equalTo: stepChartsView.leftAnchor, constant: 16).isActive = true
                vc.view.rightAnchor.constraint(equalTo: stepChartsView.rightAnchor, constant: -16).isActive = true
                vc.view.centerYAnchor.constraint(equalTo: stepChartsView.centerYAnchor).isActive = true
                averageStepLabel.text = "\(averageStep) steps"
            }
            catch {
                print("ProfileViewContro ViewDid error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
                        self.viewDidLoad()
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
}
