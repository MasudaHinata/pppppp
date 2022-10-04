import UIKit

class TimeLineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let postDataItem = try await FirebaseClient.shared.getPointActivityPost()
//                print(postDataItem)
            }
            catch {
                print("TimeLineViewContro reloadButton error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { _ in
                        self.viewDidAppear(true)
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { _ in })
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
        
    }
}
