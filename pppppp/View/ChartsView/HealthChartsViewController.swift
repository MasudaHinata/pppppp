import UIKit
import Combine
import SwiftUI
import Charts

enum MenuType: CaseIterable {
    case week
    case month
    case year
    
    var title: String {
        switch self {
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        }
    }
}

class HealthChartsViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    let calendar = Calendar.current
    var selectedMenuType = MenuType.week
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
    @IBOutlet var selectStepChartsType: UIButton!
    
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
        configureMenu()
        self.view.backgroundColor = Asset.Colors.mainColor.color
        self.weightChartsView.isHidden = true
        let task = Task {  [weak self] in
            guard let self = self else { return }
            do {
                if #available(iOS 16.0, *) {
                    ios16onlyLabel.isHidden = true
                    ios16only2Label.isHidden = true
                    
                    chartsStepItem = try await ChartsManager.shared.createWeekStepsChart()
                    chartsStepItem.reverse()
                    let vc: UIHostingController = UIHostingController(rootView: StepsChartsUIView(data: chartsStepItem))
                    stepChartsView.addSubview(vc.view)
                    vc.view.translatesAutoresizingMaskIntoConstraints = false
                    vc.view.topAnchor.constraint(equalTo: stepChartsView.topAnchor, constant: 54).isActive = true
                    vc.view.bottomAnchor.constraint(equalTo: stepChartsView.bottomAnchor, constant: -8).isActive = true
                    vc.view.leftAnchor.constraint(equalTo: stepChartsView.leftAnchor, constant: 16).isActive = true
                    vc.view.rightAnchor.constraint(equalTo: stepChartsView.rightAnchor, constant: -16).isActive = true
                    vc.view.centerYAnchor.constraint(equalTo: stepChartsView.centerYAnchor).isActive = true
                    let averageStep = try await ChartsManager.shared.getAverageStepPoint(date: 6)
                    self.averageStepLabel.text = "\(averageStep) steps"
                    
                    weightStepItem = try await ChartsManager.shared.readWeightData()
                    weightStepItem.reverse()
                    let weightVC: UIHostingController = UIHostingController(rootView: WeightChartsUIView(data: weightStepItem))
                    weightChartsView.addSubview(weightVC.view)
                    weightVC.view.translatesAutoresizingMaskIntoConstraints = false
                    weightVC.view.topAnchor.constraint(equalTo: weightChartsView.topAnchor, constant: 54).isActive = true
                    weightVC.view.bottomAnchor.constraint(equalTo: weightChartsView.bottomAnchor, constant: -8).isActive = true
                    weightVC.view.leftAnchor.constraint(equalTo: weightChartsView.leftAnchor, constant: 16).isActive = true
                    weightVC.view.rightAnchor.constraint(equalTo: weightChartsView.rightAnchor, constant: -16).isActive = true
                    weightVC.view.centerYAnchor.constraint(equalTo: weightChartsView.centerYAnchor).isActive = true
                    let weight = try await ChartsManager.shared.readWeight()
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
    
    
    func configureMenu() {
        if #available(iOS 16.0, *) {
            
            
            let actions = MenuType.allCases
                .compactMap { type in
                    UIAction(
                        title: type.title,
                        state: type == selectedMenuType ? .on : .off,
                        handler: { _ in
                            let task = Task {  [weak self] in
                                guard let self = self else { return }
                                do{
                                    //TODO: 毎回下にあるChartsを消す
                                    if type == .week {
                                        self.chartsStepItem = try await ChartsManager.shared.createWeekStepsChart()
                                        self.chartsStepItem.reverse()
                                        let averageStep = try await ChartsManager.shared.getAverageStepPoint(date: 6)
                                        self.averageStepLabel.text = "\(averageStep) steps"
                                    } else if type == .month {
                                        self.chartsStepItem = try await ChartsManager.shared.createMonthStepsChart()
                                        self.chartsStepItem.reverse()
                                        let averageStep = try await ChartsManager.shared.getAverageStepPoint(date: 30)
                                        self.averageStepLabel.text = "\(averageStep) steps"
                                    } else if type == .year {
                                        self.chartsStepItem = try await ChartsManager.shared.createYearStepsChart()
                                        self.chartsStepItem.reverse()
                                        
                                        let todayComps = self.calendar.dateComponents([.year, .month], from: Date())
                                        let todayAdds = DateComponents(month: 1, day: -1)
                                        let todayStartDate = self.calendar.date(from: todayComps)!
                                        let todayEndDate = self.calendar.date(byAdding: todayAdds, to: todayStartDate)!
                                        let dayCount = self.calendar.component(.day, from: todayEndDate)
                                        let todayCount = self.calendar.component(.day, from: Date())
                                        print("\(todayCount)月は\(dayCount)日間")
                                        
                                        let averageStep = try await ChartsManager.shared.getAverageStepPoint(date: 362)
                                        self.averageStepLabel.text = "\(averageStep) steps"
                                    }
                                    
                                    let vc: UIHostingController = UIHostingController(rootView: StepsChartsUIView(data: self.chartsStepItem))
                                    self.stepChartsView.addSubview(vc.view)
                                    vc.view.translatesAutoresizingMaskIntoConstraints = false
                                    vc.view.topAnchor.constraint(equalTo: self.stepChartsView.topAnchor, constant: 54).isActive = true
                                    vc.view.bottomAnchor.constraint(equalTo: self.stepChartsView.bottomAnchor, constant: -8).isActive = true
                                    vc.view.leftAnchor.constraint(equalTo: self.stepChartsView.leftAnchor, constant: 16).isActive = true
                                    vc.view.rightAnchor.constraint(equalTo: self.stepChartsView.rightAnchor, constant: -16).isActive = true
                                    vc.view.centerYAnchor.constraint(equalTo: self.stepChartsView.centerYAnchor).isActive = true
                                    
                                    self.selectedMenuType = type
                                    self.configureMenu()
                                }
                            }
                            self.cancellables.insert(.init { task.cancel() })
                        })
                }
            selectStepChartsType.menu = UIMenu(title: "", options: .displayInline, children: actions)
            selectStepChartsType.showsMenuAsPrimaryAction = true
            selectStepChartsType.setTitle(selectedMenuType.title, for: .normal)
        }
    }
}
