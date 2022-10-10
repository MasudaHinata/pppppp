// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length implicit_return

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:disable type_body_length type_name
internal enum StoryboardScene {
  internal enum AddFriendView: StoryboardType {
    internal static let storyboardName = "AddFriendView"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: AddFriendView.self)
  }
  internal enum ChangeProfileView: StoryboardType {
    internal static let storyboardName = "ChangeProfileView"

    internal static let initialScene = InitialSceneType<ChangeProfileViewController>(storyboard: ChangeProfileView.self)
  }
  internal enum DashboardView: StoryboardType {
    internal static let storyboardName = "DashboardView"

    internal static let initialScene = InitialSceneType<DashboardViewController>(storyboard: DashboardView.self)
  }
  internal enum EmailSignInView: StoryboardType {
    internal static let storyboardName = "EmailSignInView"

    internal static let initialScene = InitialSceneType<EmailSignInViewController>(storyboard: EmailSignInView.self)
  }
  internal enum FriendListView: StoryboardType {
    internal static let storyboardName = "FriendListView"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: FriendListView.self)
  }
  internal enum FriendProfileView: StoryboardType {
    internal static let storyboardName = "FriendProfileView"

    internal static let initialScene = InitialSceneType<FriendProfileViewController>(storyboard: FriendProfileView.self)
  }
  internal enum Main: StoryboardType {
    internal static let storyboardName = "Main"

    internal static let initialScene = InitialSceneType<MainTabBarController>(storyboard: Main.self)

    internal static let tabBarViewController = SceneType<MainTabBarController>(storyboard: Main.self, identifier: "TabBarViewController")
  }
  internal enum OnboardingView1: StoryboardType {
    internal static let storyboardName = "OnboardingView1"

    internal static let initialScene = InitialSceneType<OnboardingViewController1>(storyboard: OnboardingView1.self)
  }
  internal enum OnboardingView2: StoryboardType {
    internal static let storyboardName = "OnboardingView2"

    internal static let initialScene = InitialSceneType<OnboardingViewController2>(storyboard: OnboardingView2.self)
  }
  internal enum OnboardingView3: StoryboardType {
    internal static let storyboardName = "OnboardingView3"

    internal static let initialScene = InitialSceneType<OnboardingViewController3>(storyboard: OnboardingView3.self)
  }
  internal enum RecordExerciseView: StoryboardType {
    internal static let storyboardName = "RecordExerciseView"

    internal static let initialScene = InitialSceneType<RecordExerciseViewController>(storyboard: RecordExerciseView.self)
  }
  internal enum RecordWeightView: StoryboardType {
    internal static let storyboardName = "RecordWeightView"

    internal static let initialScene = InitialSceneType<RecordWeightViewController>(storyboard: RecordWeightView.self)
  }
  internal enum ResetPasswordView: StoryboardType {
    internal static let storyboardName = "ResetPasswordView"

    internal static let initialScene = InitialSceneType<ResetPasswordViewController>(storyboard: ResetPasswordView.self)
  }
  internal enum SanitasView: StoryboardType {
    internal static let storyboardName = "SanitasView"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: SanitasView.self)

    internal static let sanitasViewController = SceneType<UIKit.UINavigationController>(storyboard: SanitasView.self, identifier: "SanitasViewController")
  }
  internal enum SelfCheckView: StoryboardType {
    internal static let storyboardName = "SelfCheckView"

    internal static let initialScene = InitialSceneType<SelfCheckViewController>(storyboard: SelfCheckView.self)

    internal static let selfCheckViewController = SceneType<SelfCheckViewController>(storyboard: SelfCheckView.self, identifier: "SelfCheckViewController")
  }
  internal enum SetGoalWeightView: StoryboardType {
    internal static let storyboardName = "SetGoalWeightView"

    internal static let initialScene = InitialSceneType<SetGoalWeightViewController>(storyboard: SetGoalWeightView.self)
  }
  internal enum SetNameView: StoryboardType {
    internal static let storyboardName = "SetNameView"

    internal static let initialScene = InitialSceneType<SetNameViewController>(storyboard: SetNameView.self)
  }
  internal enum SettingView: StoryboardType {
    internal static let storyboardName = "SettingView"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: SettingView.self)

    internal static let settingViewController = SceneType<SettingViewController>(storyboard: SettingView.self, identifier: "SettingViewController")
  }
  internal enum ShareMyDataView: StoryboardType {
    internal static let storyboardName = "ShareMyDataView"

    internal static let initialScene = InitialSceneType<ShareMyDataViewController>(storyboard: ShareMyDataView.self)
  }
  internal enum SignInWithAppleView: StoryboardType {
    internal static let storyboardName = "SignInWithAppleView"

    internal static let initialScene = InitialSceneType<SignInWithAppleViewController>(storyboard: SignInWithAppleView.self)

    internal static let signInWithAppleViewController = SceneType<SignInWithAppleViewController>(storyboard: SignInWithAppleView.self, identifier: "SignInWithAppleViewController")
  }
  internal enum TimeLineView: StoryboardType {
    internal static let storyboardName = "TimeLineView"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: TimeLineView.self)

    internal static let tImeLineViewController = SceneType<TimeLineViewController>(storyboard: TimeLineView.self, identifier: "TImeLineViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length prefer_self_in_static_references
// swiftlint:enable type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: BundleToken.bundle)
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    return storyboard.storyboard.instantiateViewController(identifier: identifier, creator: block)
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }

  @available(iOS 13.0, tvOS 13.0, *)
  internal func instantiate(creator block: @escaping (NSCoder) -> T?) -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController(creator: block) else {
      fatalError("Storyboard \(storyboard.storyboardName) does not have an initial scene.")
    }
    return controller
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
