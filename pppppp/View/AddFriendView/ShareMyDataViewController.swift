import UIKit
import Combine

class ShareMyDataViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    
    @IBOutlet var myProfileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let task = Task {
            do {
                try await setURL()
            } catch {
                print("ShareMyDataViewController 21:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    let alert = UIAlertController(title: "エラー", message: "インターネット接続を確認してください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.viewDidLoad()
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    //URLを設定する
    func setURL() async throws {
        let userID = try await FirebaseClient.shared.getUserUUID()
        let myProfileURL = "sanitas-ios-dev://?id=\(userID)"
        generateQR(url: myProfileURL, uiImage: myProfileImageView)
    }
    
    //QRコードを生成する
    func generateQR(url: String, uiImage: UIImageView){
        let url = url
        let data = url.data(using: .utf8)!
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])!
        let sizeTransform = CGAffineTransform(scaleX: 1, y: 1)
        uiImage.image = UIImage(ciImage:qr.outputImage!.transformed(by: sizeTransform))
    }
}
