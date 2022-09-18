import UIKit
import Combine
import AVFoundation

class ShareMyDataViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var qrCodeView = UIView()
    var qrCodeImageView = UIImageView()
    var dismissButton = UIButton()
    var flag = Bool()
    var cancellables = Set<AnyCancellable>()
    private let session = AVCaptureSession()
    
    @IBOutlet weak var caputureView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet var gradationFilterView: UIView! {
        didSet {
            gradationFilterView.backgroundColor = .clear
            let gradientLayer: CAGradientLayer = CAGradientLayer()
            gradientLayer.frame.size = gradationFilterView.frame.size
            gradientLayer.colors = [UIColor.init(hex: "6E3722", alpha: 0.75).cgColor, UIColor.init(hex: "4A0061",alpha: 0.75).cgColor]
            gradationFilterView.layer.addSublayer(gradientLayer)
        }
    }
    
    @IBOutlet var showMyQRCodeLayout: UIButton! {
        didSet {
            showMyQRCodeLayout.tintColor = UIColor.init(hex: "000000", alpha: 0.39)
        }
    }
    
    @IBOutlet var shareLinkLayout: UIButton! {
        didSet {
            shareLinkLayout .tintColor = UIColor.init(hex: "000000", alpha: 0.39)
        }
    }
    
    @IBOutlet var settingLightLayout: UIButton! {
        didSet {
            settingLightLayout.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = .init(hex: "000000", alpha: 0.39)
            configuration.cornerStyle = .capsule
            settingLightLayout.configuration = configuration
        }
    }
    
    @IBOutlet var albumButtonLayout: UIButton! {
        didSet {
            albumButtonLayout.setImage(UIImage(systemName: "photo"), for: .normal)
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = .init(hex: "000000", alpha: 0.39)
            configuration.cornerStyle = .capsule
            albumButtonLayout.configuration = configuration
        }
    }
    
    @IBAction func albumButton() {
    }
    
    
    @IBAction func settingLight() {
        if settingLightLayout.currentImage == UIImage(systemName: "flashlight.off.fill") {
            ledFlash(true)
            settingLightLayout.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal)
        } else if settingLightLayout.currentImage == UIImage(systemName: "flashlight.on.fill") {
            ledFlash(false)
            settingLightLayout.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
        }
    }
    
    @IBAction func shareLink() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                let shareWebsite = URL(string: "sanitas-ios-dev://?id=\(userID)")!
                let activityVC = UIActivityViewController(activityItems: [shareWebsite], applicationActivities: nil)
                present(activityVC, animated: true, completion: nil)
            } catch {
                print("SanitasViewContro showShareSheet:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    let alert = UIAlertController(title: "エラー", message: "インターネット接続を確認してください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default)
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
    
    @IBAction func showMyQRCode() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await makeQRcode(uiImage: qrCodeImageView)
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
        
        flag = false
        qrCodeView = UIView(frame: CGRect(x: 16, y: 240, width: 360, height: 360))
        qrCodeView.backgroundColor = UIColor.init(hex: "FFFFFF")
        qrCodeView.layer.cornerRadius = 72
        qrCodeView.layer.cornerCurve = .continuous
        qrCodeImageView = UIImageView(frame: CGRect(x: 64, y: 288, width: 264, height: 264))
        
        //TODO: 他のところ触ったら閉じるようにする
        dismissButton = UIButton(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        dismissButton.layer.position = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 108)
        dismissButton.backgroundColor = UIColor.init(hex: "000000", alpha: 0.39)
        dismissButton.layer.cornerRadius = 28.0
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.init(hex: "FFFFFF")
        dismissButton.addTarget(self, action: #selector(ShareMyDataViewController.onClickDismissButton(sender:)), for: .touchUpInside)
        
        qrCodeView.isHidden = false
        qrCodeImageView.isHidden = false
        dismissButton.isHidden = false
        self.view.addSubview(qrCodeView)
        self.view.addSubview(qrCodeImageView)
        self.view.addSubview(dismissButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initDeviceCamera()
    }
    //MARK: - QRCode読み取り
    private func initDeviceCamera() {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        
        let devices = discoverySession.devices
        if let backCamera = devices.first {
            do {
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                doInit(deviceInput: deviceInput)
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
    }
    
    private func doInit(deviceInput: AVCaptureDeviceInput) {
        if !session.canAddInput(deviceInput) { return }
        session.addInput(deviceInput)
        let metadataOutput = AVCaptureMetadataOutput()
        if !session.canAddOutput(metadataOutput) { return }
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        previewLayer.videoGravity = .resizeAspectFill
        caputureView.layer.addSublayer(previewLayer)
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            guard let value = metadata.stringValue else { return }
            if let url = URL(string: value) {
                self.session.stopRunning()
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    //MARK: - QRCode生成
    func makeQRcode(uiImage: UIImageView) async throws {
        let userID = try await FirebaseClient.shared.getUserUUID()
        let myProfileURL = "sanitas-ios-dev://?id=\(userID)"
        let url = myProfileURL
        let data = url.data(using: .utf8)!
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])!
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 1)
        uiImage.image = UIImage(ciImage:qr.outputImage!.transformed(by: sizeTransform))
    }
    
    //MARK: - ライトのオンオフ
    func ledFlash(_ flg: Bool) {
        guard let avDevice = AVCaptureDevice.default(for: .video) else { return }
        if avDevice.hasTorch {
            do {
                try avDevice.lockForConfiguration()
                avDevice.torchMode = flg ? .on : .off
                avDevice.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        }
    }
    
    @objc func onClickDismissButton(sender: UIButton) {
        qrCodeView.isHidden = true
        qrCodeImageView.isHidden = true
        dismissButton.isHidden = true
    }
}
