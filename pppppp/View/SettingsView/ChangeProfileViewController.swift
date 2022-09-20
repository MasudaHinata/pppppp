import UIKit
import Combine

class ChangeProfileViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    var profileName: String = ""
    var myName: String!
    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var myNameLabel: UILabel!
    @IBOutlet var myIconView: UIImageView! {
        didSet {
            myIconView.layer.cornerRadius = 41
            myIconView.clipsToBounds = true
            myIconView.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var nameTextField: UITextField! {
        didSet {
            nameTextField.layer.cornerRadius = 8
            nameTextField.clipsToBounds = true
            nameTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var changeProfileLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Save Change"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.showsActivityIndicator = false
            changeProfileLayout.configuration = configuration
        }
    }
    
    @IBAction func uploadButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func changeProfile() {
        if let selectImage = myIconView.image {
            let task = Task { [weak self] in
                guard let self = self else { return }
                do {
                    var configuration = UIButton.Configuration.filled()
                    configuration.title = "Save Change..."
                    configuration.baseBackgroundColor = .init(hex: "92B2D3")
                    configuration.showsActivityIndicator = true
                    changeProfileLayout.configuration = configuration
                    profileName = (self.nameTextField.text!)
                    if profileName != "" {
                        async let putImage: () = FirebaseClient.shared.putFirebaseStorage(selectImage: selectImage)
                        async let putName: () = FirebaseClient.shared.putNameFirestore(name: profileName)
                        let _ = try await (putName,putImage)
                    } else {
                        try await FirebaseClient.shared.putFirebaseStorage(selectImage: selectImage)
                    }
                    
                    ShowAlertHelper.okAlert(vc: self, title: "完了", message: "変更しました", handler: { (_) in
                        var configuration = UIButton.Configuration.gray()
                        configuration.title = "Save Change"
                        configuration.baseBackgroundColor = .init(hex: "92B2D3")
                        configuration.baseForegroundColor = .white
                        self.changeProfileLayout.configuration = configuration
                        self.myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
                    })
                }
                catch {
                    print("ChangeProfile putFirebaseStorage error:", error.localizedDescription)
                    if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { (_) in })
                    } else {
                        ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { (_) in })
                    }
                }
            }
            self.cancellables.insert(.init { task.cancel() })
        } else {
            ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "画像を選択してください", handler: { (_) in })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.style = .large
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        self.nameTextField.delegate = self
        
        myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
        myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
        let task = Task { [weak self] in
            guard let self = self else { return }
            do {
                activityIndicator.startAnimating()
                try await FirebaseClient.shared.userAuthCheck()
                activityIndicator.stopAnimating()
            }
            catch {
                print("ChangeProfileView didLoad error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "インターネット接続を確認してください", handler: { (_) in
                        self.dismiss(animated: true, completion: nil)
                    })
                } else {
                    ShowAlertHelper.okAlert(vc: self, title: "エラー", message: "\(error.localizedDescription)", handler: { (_) in })
                }
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
