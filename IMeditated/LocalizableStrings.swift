// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

import Foundation

// swiftlint:disable file_length
// swiftlint:disable line_length

// swiftlint:disable type_body_length
enum L10n {
  /// All Meditations
  case allMeditations
  /// Close
  case closeButton
  /// Custom Sample
  case customSample
  /// Edit Sample
  case editSample
}
// swiftlint:enable type_body_length

extension L10n: CustomStringConvertible {
  var description: String { return self.string }

  var string: String {
    switch self {
      case .allMeditations:
        return L10n.tr(key: "all-meditations")
      case .closeButton:
        return L10n.tr(key: "close-button")
      case .customSample:
        return L10n.tr(key: "custom-sample")
      case .editSample:
        return L10n.tr(key: "edit-sample")
    }
  }

  private static func tr(key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

func tr(_ key: L10n) -> String {
  return key.string
}
