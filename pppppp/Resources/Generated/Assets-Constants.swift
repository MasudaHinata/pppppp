// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Assets {
    internal static let accentColor = ColorAsset(name: "AccentColor")
    internal static let group2 = ImageAsset(name: "Group 2")
    internal static let rectangle1 = ImageAsset(name: "Rectangle1")
    internal static let rectangle2 = ImageAsset(name: "Rectangle2")
    internal static let rectangle3 = ImageAsset(name: "Rectangle3")
    internal static let rectangle4 = ImageAsset(name: "Rectangle4")
    internal static let sanitasIcon = ImageAsset(name: "SanitasIcon")
    internal static let sanitasLogo1 = ImageAsset(name: "Sanitas_logo1")
    internal static let scanQRCode = ImageAsset(name: "ScanQRCode")
    internal static let addFriendBackground = ImageAsset(name: "addFriendBackground")
    internal static let addFriendGradationBackground = ImageAsset(name: "addFriendGradationBackground")
    internal static let gradation = ImageAsset(name: "gradation")
    internal static let logo = ImageAsset(name: "logo")
    internal static let morflaxStudio18 = ImageAsset(name: "morflax-studio-18")
    internal static let onboardingImage1 = ImageAsset(name: "onboardingImage1")
    internal static let onboardingImage2 = ImageAsset(name: "onboardingImage2")
    internal static let onboardingImage3 = ImageAsset(name: "onboardingImage3")
    internal static let blue = ImageAsset(name: "blue")
    internal static let green = ImageAsset(name: "green")
    internal static let orange = ImageAsset(name: "orange")
    internal static let pink = ImageAsset(name: "pink")
  }
  internal enum Colors {
    internal static let black00 = ColorAsset(name: "black00")
    internal static let black39 = ColorAsset(name: "black39")
    internal static let bronze = ColorAsset(name: "bronze")
    internal static let gold = ColorAsset(name: "gold")
    internal static let gradation1 = ColorAsset(name: "gradation1")
    internal static let gradation2 = ColorAsset(name: "gradation2")
    internal static let grass1 = ColorAsset(name: "grass1")
    internal static let grass2 = ColorAsset(name: "grass2")
    internal static let grass3 = ColorAsset(name: "grass3")
    internal static let grass4 = ColorAsset(name: "grass4")
    internal static let gray50 = ColorAsset(name: "gray50")
    internal static let lightBlue00 = ColorAsset(name: "lightBlue00")
    internal static let lightBlue25 = ColorAsset(name: "lightBlue25")
    internal static let mainColor = ColorAsset(name: "mainColor")
    internal static let purple00 = ColorAsset(name: "purple00")
    internal static let purple50 = ColorAsset(name: "purple50")
    internal static let silver = ColorAsset(name: "silver")
    internal static let subColor = ColorAsset(name: "subColor")
    internal static let white0 = ColorAsset(name: "white0")
    internal static let white00 = ColorAsset(name: "white00")
    internal static let white16 = ColorAsset(name: "white16")
    internal static let white48 = ColorAsset(name: "white48")
    internal static let white75 = ColorAsset(name: "white75")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

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
