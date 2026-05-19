//
//  EXThemeFont.swift
//  EXUIKit
//
//  Created by zq on 2023/1/31.
//

import UIKit

extension UIFont {
    public struct Ex {
        public static func regular(_ size:CGFloat) -> UIFont {
            return fontWith(size: size, weight: .regular)
        }
        public static func medium(_ size:CGFloat) -> UIFont {
            return fontWith(size: size, weight: .medium)
        }
        public static func bold(_ size:CGFloat) -> UIFont {
            return fontWith(size: size, weight: .bold)
        }
        public static func fontWith(size:CGFloat, weight:UIFont.Weight) -> UIFont {
            return Harmony(size: size, weight: weight)
        }
        
        /// Get font with specified type, size, weight and traits
        /// - Parameters:
        ///   - type: any ExFont
        ///   - size: font size
        ///   - weight: all weight supported
        ///   - traits: Condensed | Bold | Italic, if weight is bold or semibold, the bold trait will be ignored
        /// - Returns: UIFont. if the font is not exist, will be resolved to the system font
        internal static func fontWith<T:ExFont>(type:T, size:CGFloat, weight:UIFont.Weight, traits:CTFontSymbolicTraits = []) -> UIFont {
            return fontWith(name: type.fontName(of: weight, traits: traits), size: size, weight: weight)
        }
        
        /// Get font with specified name, size and weight
        /// - Parameters:
        ///   - name: font name
        ///   - size: font size
        ///   - weight: font weight
        /// - Returns: UIFont. if the font is not exist, will be resolved to the system font
        public static func fontWith(name:String?, size:CGFloat, weight:UIFont.Weight) -> UIFont {
            if let name = name, let font = UIFont(name: name, size: size) { return font }
            return .systemFont(ofSize: size, weight: weight)
        }
    }
}

extension UIFont.Ex {
    public struct Family { @available(*, unavailable) init() {} }
}

// MARK: - HarmonyOS_Sans_SC
extension UIFont.Ex {
    public static func Harmony(type:Family.Harmony = .SC, size:CGFloat, weight:UIFont.Weight) -> UIFont {
        return fontWith(type: type, size: size, weight: weight)
    }
}

extension UIFont.Ex.Family {
    public enum Harmony : String, CaseIterable {
        case SC = "HarmonyOS_Sans_SC"
    }
}

extension UIFont.Ex.Family.Harmony : ExFont {
    ///
    public static let `default`: Self = .SC
    ///
    private static let suffixes:[UIFont.Weight:String] = [.regular : "Regular",
                                                          .medium  : "Medium",
                                                          .semibold: "Bold",/// compatibility
                                                          .bold    : "Bold"]
    var availableWeights: [UIFont.Weight] { [.regular,  .medium, .semibold, .bold] }
    
    /// SCFont.Weight:SCFont.Name
    private static var SCFontNames:[UIFont.Weight:String] = [:]
    ///
    public func fontName(of weight: UIFont.Weight, traits: CTFontSymbolicTraits = []) -> String? {
        guard availableWeights.contains(weight), let suffix = Self.suffixes[weight] else { return nil }
        if let name = Self.SCFontNames[weight] { return name }
        let fileName = rawValue + "_" + suffix
        objc_sync_enter(Self.SCFontNames)
        defer { objc_sync_exit(Self.SCFontNames) }
        if let name = Self.SCFontNames[weight] { return name }
        if let url = EXThemeBundle.url(forResource: fileName, withExtension: "ttf", subdirectory: "Font"),
           let data = CGDataProvider(url: url as CFURL),
           let font = CGFont(data) {
            var error:Unmanaged<CFError>? = nil
            if CTFontManagerRegisterGraphicsFont(font, &error),
               error?.takeUnretainedValue() == nil,
               let name = font.postScriptName as? String {
                Self.SCFontNames[weight] = name
                return name
            }
        }
        return nil
    }
}


// MARK: - DIN

//extension UIFont.Ex {
//    public static func DIN(type:Family.DINs = .Pro, size:CGFloat, weight:UIFont.Weight) -> UIFont {
//        return fontWith(type: type, size: size, weight: weight)
//    }
//}
//
//extension UIFont.Ex.Family {
//    public enum DINs : String, CaseIterable {
//        case Pro       = "DINPro"
//        case Alternate = "DINAlternate"
//        case Condensed = "DINCondensed"
//    }
//}
//
//extension UIFont.Ex.Family.DINs : ExFont {
//    ///
//    public static let `default`: Self = .Pro
//    ///
//    private static let suffixes:[UIFont.Weight:String] = [.regular : "Regular",
//                                                          .medium  : "Medium",
//                                                          .semibold: "Bold",/// compatibility
//                                                          .bold    : "Bold"]
//    var availableWeights: [UIFont.Weight] {
//        switch self {
//            case .Pro:       return [.regular,  .medium, .semibold, .bold]
//            case .Alternate: return [.semibold, .bold]
//            case .Condensed: return [.semibold, .bold]
//        }
//    }
//    /// ProFont.Weight:ProFont.Name
//    private static var ProFontNames:[UIFont.Weight:String] = [:]
//    ///
//    public func fontName(of weight: UIFont.Weight, traits: CTFontSymbolicTraits = []) -> String? {
//        guard availableWeights.contains(weight), let suffix = Self.suffixes[weight] else { return nil }
//        switch self {
//            case .Alternate, .Condensed:
//                return rawValue + "-" + suffix
//            case .Pro:
//                if let name = Self.ProFontNames[weight] { return name }
//                let fileName = rawValue + "-" + suffix
//                objc_sync_enter(Self.ProFontNames)
//                defer { objc_sync_exit(Self.ProFontNames) }
//                if let name = Self.ProFontNames[weight] { return name }
//                if let url = EXThemeBundle.url(forResource: fileName, withExtension: "otf", subdirectory: "Font"),
//                   let data = CGDataProvider(url: url as CFURL),
//                   let font = CGFont(data) {
//                    var error:Unmanaged<CFError>? = nil
//                    if CTFontManagerRegisterGraphicsFont(font, &error),
//                       error?.takeUnretainedValue() == nil,
//                       let name = font.postScriptName as? String {
//                        Self.ProFontNames[weight] = name
//                        return name
//                    }
//                }
//        }
//        return nil
//    }
//}
//

// MARK: - PingFang
extension UIFont.Ex {
    public static func PingFang(type:Family.PingFangs = .SC, size:CGFloat, weight:UIFont.Weight) -> UIFont {
        return fontWith(type: type, size: size, weight: weight)
    }
}

extension UIFont.Ex.Family {
    public enum PingFangs : String, CaseIterable {
        case HK = "PingFangHK"
        case SC = "PingFangSC"
        case TC = "PingFangTC"
    }
}

extension UIFont.Ex.Family.PingFangs : ExFont {
    ///
    public static let `default`: Self = .SC
    ///
    private static let suffixes:[UIFont.Weight:String] = [.ultraLight: "Ultralight",
                                                          .thin      : "Thin",
                                                          .light     : "Light",
                                                          .regular   : "Regular",
                                                          .medium    : "Medium",
                                                          .semibold  : "Semibold",
                                                          .bold      : "Semibold"]/// compatibility
    var availableWeights: [UIFont.Weight] { [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold] }
    ///
    public func fontName(of weight: UIFont.Weight, traits: CTFontSymbolicTraits = []) -> String? {
        guard availableWeights.contains(weight), let suffix = Self.suffixes[weight] else { return nil }
        return rawValue + "-" + suffix
    }
}

// MARK: - Arial

extension UIFont.Ex {
    public static func Arial(type:Family.Arials = .arial, size:CGFloat, weight: UIFont.Weight, traits:CTFontSymbolicTraits = []) -> UIFont {
        return fontWith(type: type, size: size, weight: weight, traits: traits)
    }
}

extension UIFont.Ex.Family {
    /**
     "ArialMT"
     "Arial-BoldMT"
     "Arial-ItalicMT"
     "Arial-BoldItalicMT"
     */
    public enum Arials: String, CaseIterable{
        case arial = "Arial"
    }
}

extension UIFont.Ex.Family.Arials : ExFont {
    ///
    public static let `default`: Self = .arial
    ///
    var availableWeights: [UIFont.Weight] { [.regular, .semibold, .bold] }
    ///
    private static let suffixes:[UIFont.Weight:String] = [.semibold  : "Bold",/// compatibility
                                                          .bold      : "Bold"]
    ///
    public func fontName(of weight: UIFont.Weight, traits: CTFontSymbolicTraits = []) -> String? {
        guard availableWeights.contains(weight) else { return nil }
        var prefix = rawValue
        var suffix = Self.suffixes[weight] ?? ""
        if traits.contains(.traitItalic) { suffix += "Italic" }
        let infix = suffix.isEmpty ? "" : "-"
        return prefix + infix + suffix + "MT"
    }
}


// MARK: - Helvetica

extension UIFont.Ex {
    public static func Helvetica(type:Family.Helveticas = .normal, size:CGFloat, weight: UIFont.Weight, traits:CTFontSymbolicTraits = []) -> UIFont {
        return fontWith(type: type, size: size, weight: weight, traits: traits)
    }
}

extension UIFont.Ex.Family {
    public enum Helveticas : String, CaseIterable {
        case normal = "Helvetica"
        case neue   = "HelveticaNeue"
    }
}
extension UIFont.Ex.Family.Helveticas : ExFont {
    ///
    public static let `default`: Self = .neue
    ///
    internal static let suffixes:[UIFont.Weight:String] = [.ultraLight: "Ultralight",
                                                           .thin      : "Thin",
                                                           .light     : "Light",
                                                           .medium    : "Medium",
                                                           .semibold  : "Bold", /// compatibility
                                                           .bold      : "Bold",
                                                           .black     : "Black"]
    ///
    var availableWeights: [UIFont.Weight] {
        switch self {
            case .normal: return [.light, .regular, .semibold, .bold]
            case .neue:   return [.ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .black]
        }
    }
    ///
    public func fontName(of weight: UIFont.Weight, traits: CTFontSymbolicTraits = []) -> String? {
        guard availableWeights.contains(weight) else { return nil }
        var prefix = rawValue
        var suffix = ""
        if self == .neue, weight == .semibold || weight == .bold || weight == .black {
            if traits.contains(.traitCondensed) { suffix += "Condensed" }
        }
        suffix += Self.suffixes[weight] ?? ""
        if traits.contains(.traitItalic) { suffix += "Italic" }
        return prefix + "-" + suffix
    }
}

// MARK: - ExFont
internal protocol ExFont : CaseIterable, Hashable {
    //
    static var `default`: Self { get }
    //
    var availableWeights: [UIFont.Weight] { get }
    //
    func fontName(of weight: UIFont.Weight, traits:CTFontSymbolicTraits) -> String?
}
