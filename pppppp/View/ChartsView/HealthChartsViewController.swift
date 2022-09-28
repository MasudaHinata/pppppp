import UIKit
import Combine
import SwiftUI
import Charts

class HealthChartsViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    var chartsStepItem = [ChartsStepItem]()
    var weightStepItem = [ChartsWeightItem]()
    
    @IBOutlet var stepChartsView: UIView!
    @IBOutlet var weightChartsView: UIView!
    @IBOutlet var averageStepLabel: UILabel!
    @IBOutlet var todayWeightLabel: UILabel!
    @IBOutlet var todayLabel: UILabel!
    @IBOutlet var averageLabel: UILabel!
    @IBOutlet var ios16onlyLabel: UILabel!
    @IBOutlet var ios16only2Label: UILabel!
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.stepChartsView.isHidden = false
            self.weightChartsView.isHidden = true
        } else if sender.selectedSegmentIndex == 1 {
            self.stepChartsView.isHidden = true
            self.weightChartsView.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Asset.Colors.mainColor.color
        self.weightChartsView.isHidden = true
        let task = Task {  [weak self] in
            guard let self = self else { return }
            do {
                if #available(iOS 16.0, *) {
                    ios16onlyLabel.isHidden = true
                    ios16only2Label.isHidden = true
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
                    
                    weightStepItem = try await Scorering.shared.readWeightData()
                    weightStepItem.reverse()
                    let weightVC: UIHostingController = UIHostingController(rootView: WeightChartsUIView(data: weightStepItem))
                    weightChartsView.addSubview(weightVC.view)
                    weightVC.view.translatesAutoresizingMaskIntoConstraints = false
                    weightVC.view.topAnchor.constraint(equalTo: weightChartsView.topAnchor, constant: 54).isActive = true
                    weightVC.view.bottomAnchor.constraint(equalTo: weightChartsView.bottomAnchor, constant: -8).isActive = true
                    weightVC.view.leftAnchor.constraint(equalTo: weightChartsView.leftAnchor, constant: 16).isActive = true
                    weightVC.view.rightAnchor.constraint(equalTo: weightChartsView.rightAnchor, constant: -16).isActive = true
                    weightVC.view.centerYAnchor.constraint(equalTo: weightChartsView.centerYAnchor).isActive = true
                    let weight = try await Scorering.shared.readWeight()
                    todayWeightLabel.text = "\(weight) kg"
                } else {
                    todayLabel.isHidden = true
                    averageLabel.isHidden = true
                }
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
