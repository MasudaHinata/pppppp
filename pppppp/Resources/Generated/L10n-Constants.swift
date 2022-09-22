// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Share
  /// your health point
  /// with your friends
  internal static let onboardingView1 = L10n.tr("Localizable", "OnboardingView1", fallback: "Share\nyour health point\nwith your friends")
  /// Collect points
  /// by exercising and
  /// walking more
  internal static let onboardingView2 = L10n.tr("Localizable", "OnboardingView2", fallback: "Collect points\nby exercising and\nwalking more")
  /// Earn points
  /// by opening the app
  /// every day
  internal static let onboardingView3 = L10n.tr("Localizable", "OnboardingView3", fallback: "Earn points\nby opening the app\nevery day")
  /// Get step count with HealthKit
  internal static let onboardingViewHealthKit = L10n.tr("Localizable", "OnboardingView_HealthKit", fallback: "Get step count with HealthKit")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
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
