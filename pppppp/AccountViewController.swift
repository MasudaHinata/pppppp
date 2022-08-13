import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage

class AccountViewController: UIViewController ,UITextFieldDelegate {
    
    var auth: Auth!
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
        //①
        
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
        auth = Auth.auth()
        self.nameTextField?.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.password2TextField.delegate = self
    }
    //②
    func checkpassword() {
        if passwordTextField.text == password2TextField.text && passwordTextField.text != ""{
            print("パスワードok")
            let email = self.emailTextField.text!
            let password = self.passwordTextField.text!
            
            self.auth.createUser(withEmail: email, password: password) { (result, error) in
                if error == nil, let result = result {
                    result.user.sendEmailVerification(completion: { [weak self] (error) in
                        if error == nil {
                            print("アカウントを作成しました")
                            let alert = UIAlertController(title: "仮登録を行いました", message: "入力したメールアドレス宛に確認メールを送信しました。", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                                self?.profileName = (self?.nameTextField.text!)!
                                self?.saveProfileName(profileName: self!.profileName)
                            }
                            alert.addAction(ok)
                            self?.present(alert, animated: true, completion: nil)
                        }
                    })
                } else {
                    print("error occured\(error)")
                }
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
    //③firebaseに名前を保存
    func saveProfileName(profileName: String) {
        let db = Firestore.firestore()
        var userID = Auth.auth().currentUser?.uid
        
        if profileName != "" {
            db.collection("UserData").document(userID!).setData(["name": String(profileName)]) { [self] err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("名前をfirestoreに保存しました")
                    self.ImageputFirestore()
                }
            }
        } else {
            let alert = UIAlertController(title: "エラー", message: "名前を入力してください", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    //④画像をfirestoreに保存する
    func ImageputFirestore() {
//        let db = Firestore.firestore()
//        var userID = Auth.auth().currentUser?.uid
//        db.collection("UserData").document(userID!).collection("IconData").document("Icon").setData([
//            "imageURL": "https://firebasestorage.googleapis.com/v0/b/healthcare-58d8a.appspot.com/o/posts%2F64f3736430fc0b1db5b4bd8cdf3c9325.jpg?alt=media&token=abb0bcde-770a-47a1-97d3-eeed94e59c11"
//        ])
//        print("初期画像を設定")
        FirebaseClient.shared.putIconFirestore()
        
        let task = Task {
            do {
                var point = Scorering.shared.sanitasPoint
                point = 0
                try await FirebaseClient.shared.firebasePutData(point: point)
                
                print("初期ポイントをfirestoreに保存成功")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondVC = storyboard.instantiateViewController(identifier: "LoginViewController")
                self.showDetailViewController(secondVC, sender: self)
            }
            catch{
                print("初期ポイントをfirestoreに保存error")
            }
        }
    }
    func design() {
        emailTextField.layer.cornerRadius = 24
        emailTextField.clipsToBounds = true
        passwordTextField.layer.cornerRadius = 24
        passwordTextField.clipsToBounds = true
        password2TextField.layer.cornerRadius = 24
        password2TextField.clipsToBounds = true
        nameTextField.layer.cornerRadius = 24
        nameTextField.clipsToBounds = true
        GoButton.layer.cornerRadius = 24
        GoButton.clipsToBounds = true
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
