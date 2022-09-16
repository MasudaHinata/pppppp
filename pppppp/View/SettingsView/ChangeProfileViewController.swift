import UIKit
import Combine

class ChangeProfileViewController: UIViewController {
    
    var cancellables = Set<AnyCancellable>()
    var profileName: String = ""
    var myName: String!
    var ActivityIndicator: UIActivityIndicatorView!
    
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
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
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
            let task = Task {
                do {
                    var configuration = UIButton.Configuration.filled()
                    configuration.title = "Save Change..."
                    configuration.baseBackgroundColor = .init(hex: "92B2D3")
                    configuration.showsActivityIndicator = true
                    configuration.imagePadding = 24
                    configuration.imagePlacement = .trailing
                    changeProfileLayout.configuration = configuration
                    profileName = (self.nameTextField.text!)
                    if profileName != "" {
                        async let putImage: () = FirebaseClient.shared.putFirebaseStorage(selectImage: selectImage)
                        async let putName: () = FirebaseClient.shared.putNameFirestore(name: profileName)
                        let _ = try await (putName,putImage)
                    } else {
                        try await FirebaseClient.shared.putFirebaseStorage(selectImage: selectImage)
                    }
                    let alert = UIAlertController(title: "完了", message: "変更しました", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        var configuration = UIButton.Configuration.gray()
                        configuration.title = "Save Change"
                        configuration.baseBackgroundColor = .init(hex: "92B2D3")
                        configuration.imagePlacement = .trailing
                        configuration.baseForegroundColor = .white
                        configuration.imagePadding = 24
                        self.changeProfileLayout.configuration = configuration
                        self.myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
                    }
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                catch {
                    print("ChangeProfile putFirebaseStorage error:", error.localizedDescription)
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
            self.cancellables.insert(.init { task.cancel() })
        } else {
            let alert = UIAlertController(title: "エラー", message: "画像を選択してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ActivityIndicator = UIActivityIndicatorView()
        ActivityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        ActivityIndicator.center = self.view.center
        ActivityIndicator.style = .large
        ActivityIndicator.hidesWhenStopped = true
        self.view.addSubview(ActivityIndicator)
        
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        self.nameTextField.delegate = self
        
        myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
        myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
        let task = Task {
            do {
                ActivityIndicator.startAnimating()
                try await FirebaseClient.shared.userAuthCheck()
                ActivityIndicator.stopAnimating()
            }
            catch {
                print("ChangeProfileView didLoad error:",error.localizedDescription)
                if error.localizedDescription == "Network error (such as timeout, interrupted connection or unreachable host) has occurred." {
                    let alert = UIAlertController(title: "エラー", message: "インターネット接続を確認してください", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                        self.dismiss(animated: true, completion: nil)
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
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

//MARK: - extension
extension ChangeProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])  {
        if let selectedImage = info[.originalImage] as? UIImage {
            myIconView.image = selectedImage
        }
        self.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChangeProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
}
