import Combine
import UIKit
import FirebaseStorage

class AccountViewController: UIViewController ,UITextFieldDelegate {
    var cancellables = Set<AnyCancellable>()
    var profileName: String = ""
    @IBOutlet var GoButton: UIButton!
    @IBOutlet var emailTextField: UITextField! {
        didSet {
            emailTextField.attributedPlaceholder = NSAttributedString(string: "Enter your EmailAddress", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var passwordTextField: UITextField! {
        didSet {
            passwordTextField.attributedPlaceholder = NSAttributedString(string: "Enter your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var password2TextField: UITextField! {
        didSet {
            password2TextField.attributedPlaceholder = NSAttributedString(string: "confirm your Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    @IBOutlet var nameTextField: UITextField! {
        didSet {
            nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter your name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
    
    @IBAction func GooButton() {
        if self.isValidEmail(self.emailTextField.text!) {
            print("メールアドレスok")
            checkpassword()
        } else {
            // メールアドレスが正しく入力されなかった場合
            print("メールアドレスの形式が間違っています")
            let alert = UIAlertController(title: "メールアドレスの形式が間違っています", message: "メールアドレスを確認してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
        
    }
    override func viewDidLoad() {
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
        
        design()
        super.viewDidLoad()
        self.nameTextField?.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.password2TextField.delegate = self
    }
    //②
    func checkpassword() {
        if passwordTextField.text == password2TextField.text && passwordTextField.text != "" {
            print("パスワードok")
            let email = self.emailTextField.text!
            let password = self.passwordTextField.text!
            self.profileName = (self.nameTextField.text!)
            
            if profileName != "" {
                let task = Task {
                    do {
                        try await FirebaseClient.shared.createAccount(email: email, password: password)
                        try await self.initializePersonalData()
                    }
                    catch {
                        print("check password error")
                    }
                }
                cancellables.insert(.init { task.cancel() })
                let alert = UIAlertController(title: "仮登録を行いました", message: "入力したメールアドレス宛に確認メールを送信しました。", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                    aaa()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                let alert = UIAlertController(title: "エラー", message: "名前を入力してください", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                }
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
        } else if passwordTextField.text == "" {
            print("パスワードが入力されていない")
            let alert = UIAlertController(title: "パスワードが入力されていません", message: "パスワードを入力してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        } else if passwordTextField.text != password2TextField.text {
            let alert = UIAlertController(title: "パスワードが一致しません", message: "パスワードを確認してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    func aaa() {
        let task = Task {
            do {
                var result = try await FirebaseClient.shared.putNameFirestore(name: self.profileName)
                result = try await FirebaseClient.shared.putIconFirestore(image: "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11")
                result = try await FirebaseClient.shared.firebasePutData(point: 0)
                print(result)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "LoginViewController")
                self.showDetailViewController(secondVC, sender: self)
            }
            catch {
                print("error")
            }
        }
        cancellables.insert(.init { task.cancel() })
    }
    
    func initializePersonalData() async throws {
        try await FirebaseClient.shared.putNameFirestore(name: self.profileName)
        try await FirebaseClient.shared.putIconFirestore(image: "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11")
        try await FirebaseClient.shared.firebasePutData(point: 0)
    }

    func design() {
        emailTextField.layer.cornerRadius = 24
        emailTextField.clipsToBounds = true
        emailTextField.layer.cornerCurve = .continuous
        passwordTextField.layer.cornerRadius = 24
        passwordTextField.clipsToBounds = true
        passwordTextField.layer.cornerCurve = .continuous
        password2TextField.layer.cornerRadius = 24
        password2TextField.clipsToBounds = true
        password2TextField.layer.cornerCurve = .continuous
        nameTextField.layer.cornerRadius = 24
        nameTextField.clipsToBounds = true
        nameTextField.layer.cornerCurve = .continuous
        GoButton.layer.cornerRadius = 24
        GoButton.clipsToBounds = true
        GoButton.layer.cornerCurve = .continuous
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        password2TextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        return true
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    @IBAction func LoginButton () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "LoginViewController")
        self.showDetailViewController(secondVC, sender: self)
    }
    func isValidEmail(_ string: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: string)
        return result
    }
}
