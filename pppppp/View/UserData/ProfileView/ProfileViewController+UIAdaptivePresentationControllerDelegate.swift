import UIKit

@available(iOS 16.0, *)
extension ProfileViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
        myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
    }
}
