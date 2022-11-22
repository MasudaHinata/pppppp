import UIKit

extension UIView {
    func getScreenShot(windowFrame: CGRect, adFrame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(windowFrame.size, false, 0.0)
        // swiftlint:disable:next force_unwrapping
        let context: CGContext = UIGraphicsGetCurrentContext()!
        layer.render(in: context)
        // swiftlint:disable:next force_unwrapping
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}
