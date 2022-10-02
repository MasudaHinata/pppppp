import UIKit
import Combine
import SwiftUI
import Charts

//@available(iOS 16.0, *)
class HealthChartsViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    let calendar = Calendar.current
    var selectedMenuType = MenuType.week
    var chartsStepItem = [ChartsStepItem]()
    var weightStepItem = [ChartsWeightItem]()
//    var stepChartsHostingController: UIHostingController<StepsChartsUIView>?
    
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
            if #available(iOS 16.0, *) {
                self.stepChartsView.isHidden = false
                self.averageStepLabel.isHidden = false
                self.averageLabel.isHidden = false
                self.selectStepChartsType.isHidden = false
                self.weightChartsView.isHidden = true
                self.todayWeightLabel.isHidden = true
                self.todayLabel.isHidden = true
            } else {
                self.stepChartsView.isHidden = false
                self.averageStepLabel.isHidden = true
                self.averageLabel.isHidden = true
                self.selectStepChartsType.isHidden = true
                self.weightChartsView.isHidden = true
                self.todayWeightLabel.isHidden = true
                self.todayLabel.isHidden = true
            }
        } else if sender.selectedSegmentIndex == 1 {
            if #available(iOS 16.0, *) {
                self.stepChartsView.isHidden = true
                self.averageStepLabel.isHidden = true
                self.averageLabel.isHidden = true
                self.selectStepChartsType.isHidden = true
                self.weightChartsView.isHidden = false
                self.todayWeightLabel.isHidden = false
                self.todayLabel.isHidden = false
            } else {
                self.stepChartsView.isHidden = true
                self.averageStepLabel.isHidden = true
                self.averageLabel.isHidden = true
                self.selectStepChartsType.isHidden = true
                self.weightChartsView.isHidden = false
                self.todayWeightLabel.isHidden = true
                self.todayLabel.isHidden = true
            }
        }
    }
    
    @IBAction func reloadButton() {
        selectStepChartsType.showsMenuAsPrimaryAction = true
        selectStepChartsType.setTitle(MenuType.week.title, for: .normal)
        
        let subviews = self.stepChartsView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        let task = Task {  [weak self] in
            guard let self = self else { return }
            do {
                if #available(iOS 16.0, *) {
                    chartsStepItem = try await ChartsManager.shared.createWeekStepsChart()
                    chartsStepItem.reverse()
                    let vc: UIHostingController = UIHostingController(rootView: StepsChartsUIView(data: chartsStepItem))
                    stepChartsView.addSubview(vc.view)
                    vc.view.translatesAutoresizingMaskIntoConstraints = false
                    vc.view.topAnchor.constraint(equalTo: stepChartsView.topAnchor, constant: 24).isActive = true
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
                    weightVC.view.topAnchor.constraint(equalTo: weightChartsView.topAnchor, constant: 24).isActive = true
                    weightVC.view.bottomAnchor.constraint(equalTo: weightChartsView.bottomAnchor, constant: -8).isActive = true
                    weightVC.view.leftAnchor.constraint(equalTo: weightChartsView.leftAnchor, constant: 16).isActive = true
                    weightVC.view.rightAnchor.constraint(equalTo: weightChartsView.rightAnchor, constant: -16).isActive = true
                    weightVC.view.centerYAnchor.constraint(equalTo: weightChartsView.centerYAnchor).isActive = true
                    let weight = try await ChartsManager.shared.readWeight()
                    todayWeightLabel.text = "\(weight) kg"
                } else {
                    todayLabel.isHidden = true
                    averageLabel.isHidden = true
                    selectStepChartsType.isHidden = true
                    ios16onlyLabel.isHidden = false
                    ios16only2Label.isHidden = false
                }
            }
            catch {
                print("ProfileViewContro ViewDid error:",error.localizedDescription)
                ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMenu()
        self.view.backgroundColor = Asset.Colors.mainColor.color
        self.weightChartsView.isHidden = true
        self.todayWeightLabel.isHidden = true
        self.todayLabel.isHidden = true
        ios16onlyLabel.isHidden = true
        ios16only2Label.isHidden = true
        
        let task = Task {  [weak self] in
            guard let self = self else { return }
            do {
                
                if #available(iOS 16.0, *) {
                    chartsStepItem = try await ChartsManager.shared.createWeekStepsChart()
                    chartsStepItem.reverse()
                    let vc: UIHostingController<StepsChartsUIView> = UIHostingController(rootView: StepsChartsUIView(data: chartsStepItem))
                    stepChartsView.addSubview(vc.view)
                    vc.view.translatesAutoresizingMaskIntoConstraints = false
                    vc.view.topAnchor.constraint(equalTo: stepChartsView.topAnchor, constant: 24).isActive = true
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
                    weightVC.view.topAnchor.constraint(equalTo: weightChartsView.topAnchor, constant: 24).isActive = true
                    weightVC.view.bottomAnchor.constraint(equalTo: weightChartsView.bottomAnchor, constant: -8).isActive = true
                    weightVC.view.leftAnchor.constraint(equalTo: weightChartsView.leftAnchor, constant: 16).isActive = true
                    weightVC.view.rightAnchor.constraint(equalTo: weightChartsView.rightAnchor, constant: -16).isActive = true
                    weightVC.view.centerYAnchor.constraint(equalTo: weightChartsView.centerYAnchor).isActive = true
                    let weight = try await ChartsManager.shared.readWeight()
                    todayWeightLabel.text = "\(weight) kg"
                } else {
                    todayLabel.isHidden = true
                    averageLabel.isHidden = true
                    selectStepChartsType.isHidden = true
                    ios16onlyLabel.isHidden = false
                    ios16only2Label.isHidden = false
                }
            }
            catch {
                print("ProfileViewContro ViewDid error:",error.localizedDescription)
                ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    func configureMenu() {
        if #available(iOS 16.0, *) {
            let actions = MenuType.allCases.compactMap { type in
                UIAction(title: type.title, state: type == selectedMenuType ? .on : .off, handler: { _ in
                    let task = Task {  [weak self] in
                        guard let self = self else { return }
                        do {
                            let subviews = self.stepChartsView.subviews
                            for subview in subviews {
                                subview.removeFromSuperview()
                            }
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
                                let averageStep = try await ChartsManager.shared.getAverageStepPoint(date: Double(365 - ((dayCount - todayCount) + 1)))
                                self.averageStepLabel.text = "\(averageStep) steps"
                            }
                            
                            let vc: UIHostingController = UIHostingController(rootView: StepsChartsUIView(data: self.chartsStepItem))
                            self.stepChartsView.addSubview(vc.view)
                            vc.view.translatesAutoresizingMaskIntoConstraints = false
                            vc.view.topAnchor.constraint(equalTo: self.stepChartsView.topAnchor, constant: 24).isActive = true
                            vc.view.bottomAnchor.constraint(equalTo: self.stepChartsView.bottomAnchor, constant: -8).isActive = true
                            vc.view.leftAnchor.constraint(equalTo: self.stepChartsView.leftAnchor, constant: 16).isActive = true
                            vc.view.rightAnchor.constraint(equalTo: self.stepChartsView.rightAnchor, constant: -16).isActive = true
                            vc.view.centerYAnchor.constraint(equalTo: self.stepChartsView.centerYAnchor).isActive = true
                            self.selectedMenuType = type
                            self.configureMenu()
                        }
                        catch {
                            print("ViewController reloadButton error:",error.localizedDescription)
                            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
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
