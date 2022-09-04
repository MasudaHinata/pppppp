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
            nameTextField.layer.cornerRadius = 24
            nameTextField.clipsToBounds = true
            nameTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var goButtonLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Save changes"
            configuration.baseBackgroundColor = .init(hex: "92B2D3")
            configuration.imagePlacement = .trailing
            configuration.showsActivityIndicator = false
            configuration.imagePadding = 24
            configuration.cornerStyle = .capsule
            goButtonLayout.configuration = configuration
            goButtonLayout.layer.cornerRadius = 24
            goButtonLayout.clipsToBounds = true
            goButtonLayout.layer.cornerCurve = .continuous
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
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Save..."
        configuration.baseBackgroundColor = .init(hex: "92B2D3")
        configuration.showsActivityIndicator = true
        configuration.imagePadding = 24
        configuration.imagePlacement = .trailing
        configuration.cornerStyle = .capsule
        goButtonLayout.configuration = configuration
        saveProfile()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        myNameLabel.text = UserDefaults.standard.object(forKey: "name")! as? String
        myIconView.kf.setImage(with: URL(string: UserDefaults.standard.object(forKey: "IconImageURL") as! String))
        let task = Task {
            do {
                ActivityIndicator.startAnimating()
                try await FirebaseClient.shared.userAuthCheck()
                ActivityIndicator.stopAnimating()
            }
            catch {
                let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.viewDidLoad()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                print("ChangeProfileView didAppear error:",error.localizedDescription)
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    func saveProfile() {
        if let selectImage = myIconView.image {
            let task = Task {
                do {
                    profileName = (self.nameTextField.text!)
                    if profileName != "" {
                        try await FirebaseClient.shared.putFirebaseStorage(selectImage: selectImage)
                        try await FirebaseClient.shared.putNameFirestore(name: profileName)
                        //FIXME: ここで呼びたくない
                        let alert = UIAlertController(title: "完了", message: "変更しました", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        try await FirebaseClient.shared.putFirebaseStorage(selectImage: selectImage)
                        //FIXME: ここで呼びたくない
                        let alert = UIAlertController(title: "完了", message: "変更しました", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
//                    //FIXME: ここで呼びたくない
//                    let alert = UIAlertController(title: "完了", message: "変更しました", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
//                        self.dismiss(animated: true, completion: nil)
//                    }
//                    alert.addAction(ok)
//                    self.present(alert, animated: true, completion: nil)
                }
                catch {
                    let alert = UIAlertController(title: "エラー", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    print("ChangeProfile putFirebaseStorage error:", error.localizedDescription)
                }
            }
            self.cancellables.insert(.init { task.cancel() })
            //FIXME: ここで呼びたくない
            let alert = UIAlertController(title: "完了", message: "変更しました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "エラー", message: "画像を選択してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        var configuration = UIButton.Configuration.gray()
        configuration.title = "Save changes"
        configuration.baseBackgroundColor = .init(hex: "92B2D3")
        configuration.cornerStyle = .capsule
        configuration.imagePlacement = .trailing
        configuration.baseForegroundColor = .white
        configuration.imagePadding = 24
        self.goButtonLayout.configuration = configuration
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

extension ChangeProfileViewController {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
}
