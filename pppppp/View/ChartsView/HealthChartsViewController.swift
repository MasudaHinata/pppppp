import UIKit
import Combine
import SwiftUI
import Charts

@available(iOS 16.0, *)
class HealthChartsViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        let vc = UIHostingController(rootView: HealthChartsContentView())
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            vc.view.topAnchor.constraint(equalTo: view.topAnchor)])
    }
}
