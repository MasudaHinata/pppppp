import UIKit
import SwiftUI
import Combine

@available(iOS 16.0, *)
class HealthDataViewController: UIViewController {
    
  var cancellables = Set<AnyCancellable>()
    var chartsStepItem = [ChartsStepItem]()
    
    @IBOutlet var stepChartsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let task = Task {
            do {
                chartsStepItem = try await Scorering.shared.createStepsChart()
                chartsStepItem.reverse()
                let vc: UIHostingController = UIHostingController(rootView: StepsChartsUIView(data: chartsStepItem))
                stepChartsView.addSubview(vc.view)
                vc.view.translatesAutoresizingMaskIntoConstraints = false
                vc.view.topAnchor.constraint(equalTo: stepChartsView.topAnchor, constant: 80).isActive = true
                vc.view.bottomAnchor.constraint(equalTo: stepChartsView.bottomAnchor, constant: -8).isActive = true
                vc.view.leftAnchor.constraint(equalTo: stepChartsView.leftAnchor, constant: 0).isActive = true
                vc.view.rightAnchor.constraint(equalTo: stepChartsView.rightAnchor, constant: 0).isActive = true
                vc.view.centerYAnchor.constraint(equalTo: stepChartsView.centerYAnchor).isActive = true
            }
            catch {
                print("HealthDataView ViewDid error:",error.localizedDescription)
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
