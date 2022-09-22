import UIKit

extension ShareMyDataViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        if let selectedImage = info[.originalImage] as? UIImage {
            guard let ciimg = CIImage(image: selectedImage) else {
                //画像変換に失敗
                return
            }
            
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil)
            guard let results = detector!.features(in: ciimg) as? [CIQRCodeFeature] else {
                //画像認識に失敗
                return
            }
            for a in results {
                UIApplication.shared.open(URL(string: a.messageString!)!, options: [:], completionHandler: nil)
            }
            self.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
