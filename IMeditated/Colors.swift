// Generated using SwiftGen, by O.Halligon — https://github.com/AliSoftware/SwiftGen

#if os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIColor
  typealias Color = UIColor
#elseif os(OSX)
  import AppKit.NSColor
  typealias Color = NSColor
#endif

extension Color {
  convenience init(rgbaValue: UInt32) {
    let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
    let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
    let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
    let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0

    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}

// swiftlint:disable file_length
// swiftlint:disable type_body_length
enum ColorName {
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#0b4f6c"></span>
  /// Alpha: 100% <br/> (0x0b4f6cff)
  case darkImperialBlue
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#edd3bb"></span>
  /// Alpha: 100% <br/> (0xedd3bbff)
  case dutchWhite
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#145c9e"></span>
  /// Alpha: 100% <br/> (0x145c9eff)
  case lapisLazuli
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#020202"></span>
  /// Alpha: 100% <br/> (0x020202ff)
  case richBlack
  /// <span style="display:block;width:3em;height:2em;border:1px solid black;background:#75604b"></span>
  /// Alpha: 100% <br/> (0x75604bff)
  case spicyMix

  var rgbaValue: UInt32 {
    switch self {
    case .darkImperialBlue: return 0x0b4f6cff
    case .dutchWhite: return 0xedd3bbff
    case .lapisLazuli: return 0x145c9eff
    case .richBlack: return 0x020202ff
    case .spicyMix: return 0x75604bff
    }
  }

  var color: Color {
    return Color(named: self)
  }
}
// swiftlint:enable type_body_length

extension Color {
  convenience init(named name: ColorName) {
    self.init(rgbaValue: name.rgbaValue)
  }
}
