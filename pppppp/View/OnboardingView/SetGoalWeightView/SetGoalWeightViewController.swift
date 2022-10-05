import UIKit

class SetGoalWeightViewController: UIViewController {
    
    @IBOutlet var weightTextField: UITextField! {
        didSet {
            weightTextField.layer.cornerRadius = 8
            weightTextField.clipsToBounds = true
            weightTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var weightGoalTextField: UITextField! {
        didSet {
            weightGoalTextField.layer.cornerRadius = 8
            weightGoalTextField.clipsToBounds = true
            weightGoalTextField.layer.cornerCurve = .continuous
        }
    }
    
    @IBOutlet var saveWeightGoalButtonLayout: UIButton! {
        didSet {
            var configuration = UIButton.Configuration.filled()
            configuration.title = "Seve your weight & goal"
            configuration.baseBackgroundColor = Asset.Colors.lightBlue00.color
            configuration.showsActivityIndicator = false
            saveWeightGoalButtonLayout.configuration = configuration
        }
    }

    @IBAction func saveWeightGoalButton(_ sender: Any) {
        
    
        let secondVC = StoryboardScene.Main.initialScene.instantiate()
        self.showDetailViewController(secondVC, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.set(true, forKey: "initialScreen")
    }
    
}
