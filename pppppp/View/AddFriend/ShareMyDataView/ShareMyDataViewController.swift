import UIKit
import Combine
import AVFoundation

class ShareMyDataViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private let session = AVCaptureSession()
    var flag = Bool()
    var cancellables = Set<AnyCancellable>()
    var qrCodeBackgroundView = UIView()
    var qrCodeImageView = UIImageView()
    var dismissButton = UIButton()
    var saveButton = UIButton()

    @IBOutlet weak var caputureView: UIView!
    
    @IBOutlet var alertButtonLayout: UIButton! {
        didSet {
            alertButtonLayout.tintColor = Asset.Colors.black00.color
        }
    }
    
    @IBOutlet var gradationFilterView: UIView! {
        didSet {
            gradationFilterView.backgroundColor = .clear
            let gradientLayer: CAGradientLayer = CAGradientLayer()
            gradientLayer.frame.size = gradationFilterView.frame.size
            //TODO: ColorAssetにする
            gradientLayer.colors = [UIColor.init(hex: "4A0061", alpha: 0.6).cgColor, UIColor.init(hex: "0045F5",alpha: 0.6).cgColor]
            gradationFilterView.layer.addSublayer(gradientLayer)
        }
    }
    
    @IBOutlet var showMyQRCodeLayout: UIButton! {
        didSet {
            showMyQRCodeLayout.tintColor = Asset.Colors.black39.color
        }
    }
    
    @IBOutlet var shareLinkLayout: UIButton! {
        didSet {
            shareLinkLayout .tintColor = Asset.Colors.black39.color
        }
    }
    
    @IBOutlet var settingLightLayout: UIButton! {
        didSet {
            settingLightLayout.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = Asset.Colors.black39.color
            configuration.cornerStyle = .capsule
            settingLightLayout.configuration = configuration
        }
    }
    
    @IBOutlet var albumButtonLayout: UIButton! {
        didSet {
            albumButtonLayout.setImage(UIImage(systemName: "photo"), for: .normal)
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = Asset.Colors.black39.color
            configuration.cornerStyle = .capsule
            albumButtonLayout.configuration = configuration
        }
    }

    //MARK: - カメラの許可がない時のアラート
    @IBAction func alertButton() {
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    //MARK: - ライブラリを開く
    @IBAction func openAlbumButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.present(picker, animated: true, completion: nil)
    }

    //MARK: - QRCodeを表示
    @IBAction func showMyQRCode() {
        flag = false
        qrCodeBackgroundView = UIView()
        qrCodeBackgroundView.backgroundColor = Asset.Colors.white00.color
        qrCodeBackgroundView.layer.cornerRadius = 64
        qrCodeBackgroundView.layer.cornerCurve = .continuous
        qrCodeBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        qrCodeImageView = UIImageView()
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false


        dismissButton = UIButton()
        dismissButton.backgroundColor = Asset.Colors.black39.color
        dismissButton.addTarget(self, action: #selector(ShareMyDataViewController.onClickDismissButton(sender:)), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false

        saveButton = UIButton(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        saveButton.layer.position = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 108)
        saveButton.backgroundColor = Asset.Colors.white48.color
        saveButton.layer.cornerRadius = 28.0
        saveButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        saveButton.tintColor = .black
        saveButton.addTarget(self, action: #selector(ShareMyDataViewController.onClickSaveQRCodeImageButton(sender:)), for: .touchUpInside)

        qrCodeBackgroundView.isHidden = false
        qrCodeImageView.isHidden = false
        dismissButton.isHidden = false
        saveButton.isHidden = false

        self.view.addSubview(dismissButton)
        self.view.addSubview(qrCodeBackgroundView)
        self.view.addSubview(qrCodeImageView)
        self.view.addSubview(saveButton)

        let constraints = [qrCodeBackgroundView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
                           qrCodeBackgroundView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
                           qrCodeBackgroundView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                           qrCodeBackgroundView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),

                           qrCodeImageView.leadingAnchor.constraint(equalTo: qrCodeBackgroundView.leadingAnchor, constant: 32),
                           qrCodeImageView.trailingAnchor.constraint(equalTo: qrCodeBackgroundView.trailingAnchor, constant: -32),
                           qrCodeImageView.topAnchor.constraint(equalTo: qrCodeBackgroundView.topAnchor, constant: 32),
                           qrCodeImageView.bottomAnchor.constraint(equalTo: qrCodeBackgroundView.bottomAnchor, constant: -32),

                           dismissButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           dismissButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           dismissButton.topAnchor.constraint(equalTo: self.view.topAnchor),
                           dismissButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)]

        NSLayoutConstraint.activate(constraints)

        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await makeQRcode(uiImage: qrCodeImageView)
            } catch {
                print("ShareMyDataViewController showMyQRCode error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください") { _ in
                        self.viewDidLoad()
                    }
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message:"\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    @IBAction func shareLink() {
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                let userID = try await FirebaseClient.shared.getUserUUID()
                var shareWebsite: URL?

#if DEBUG
                shareWebsite = URL(string: "sanitas-ios-dev-debug://?id=\(userID)")!
#else
                shareWebsite = URL(string: "sanitas-ios-dev://?id=\(userID)")!
#endif
                
                let activityVC = UIActivityViewController(activityItems: [shareWebsite], applicationActivities: nil)
                present(activityVC, animated: true, completion: nil)
            } catch {
                print("ShareMyDataViewContro shareLink error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください")
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message:"\(error.localizedDescription)")
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    @IBAction func settingLight() {
        if settingLightLayout.currentImage == UIImage(systemName: "flashlight.off.fill") {
            ledFlash(true)
            settingLightLayout.setImage(UIImage(systemName: "flashlight.on.fill"), for: .normal)
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = Asset.Colors.white00.color
            configuration.baseForegroundColor = Asset.Colors.black00.color
            configuration.cornerStyle = .capsule
            settingLightLayout.configuration = configuration
        } else if settingLightLayout.currentImage == UIImage(systemName: "flashlight.on.fill") {
            ledFlash(false)
            settingLightLayout.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
            var configuration = UIButton.Configuration.filled()
            configuration.baseBackgroundColor = Asset.Colors.black39.color
            configuration.cornerStyle = .capsule
            settingLightLayout.configuration = configuration
        }
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
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            guard let value = metadata.stringValue else { return }
            if let url = URL(string: value) {
                self.session.stopRunning()

                var recievedId: String = ""
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
                if let queryValue = urlComponents?.queryItems?.first?.value {
                    recievedId = queryValue
                }

                let mainStoryboard: UIStoryboard = UIStoryboard(name: "FriendProfileView", bundle: nil)
                let resultVC: FriendProfileViewController = mainStoryboard.instantiateInitialViewController() as! FriendProfileViewController
                resultVC.friendId = recievedId
                resultVC.linkJudge = true
                self.present(resultVC, animated: true)
            }
        }
    }
    
    //MARK: - QRCode生成
    func makeQRcode(uiImage: UIImageView) async throws {
        let userID = try await FirebaseClient.shared.getUserUUID()
#if DEBUG
        let myProfileURL = "sanitas-ios-dev-debug://?id=\(userID)"
#else
        let myProfileURL = "sanitas-ios-dev://?id=\(userID)"
#endif
        let url = myProfileURL
        let data = url.data(using: .utf8)!
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "M"])!
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
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
    
    //MARK: - dismissButtonが押された時の処理
    @objc func onClickDismissButton(sender: UIButton) {
        qrCodeBackgroundView.isHidden = true
        qrCodeImageView.isHidden = true
        dismissButton.isHidden = true
        saveButton.isHidden = true
    }

    //MARK: - QRCode保存ボタンが押された時の処理
    @objc func onClickSaveQRCodeImageButton(sender: UIButton) {
        let screenShot = qrCodeImageView.getScreenShot(windowFrame: qrCodeImageView.frame, adFrame: CGRect(x: 0, y: 0, width: 0, height: 0))
        UIImageWriteToSavedPhotosAlbum(screenShot, self, #selector(self.showResultOfSaveImage(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc func showResultOfSaveImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
        var title = "完了"
        var message = "カメラロールに保存しました"

        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }
        ShowAlertHelper.okAlert(vc: self, title: title, message: message)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        alertButtonLayout.isHidden = true
        useCameraPermission()
        initDeviceCamera()
    }

    //MARK: カメラの許可
    func useCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] (res) in
            guard let self = self else { return }
            if res == false {
                DispatchQueue.main.async {
                    self.alertButtonLayout.isHidden = false
                }
            }
        }
    }
}
