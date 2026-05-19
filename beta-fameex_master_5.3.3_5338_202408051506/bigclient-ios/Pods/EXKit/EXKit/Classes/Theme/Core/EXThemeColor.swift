//
//  EXColors.swift
//  EXUIKit
//
//  Created by zq on 2023/1/18.
//

import UIKit

public extension UIColor {
    enum Ex: Int, CaseIterable, Codable {
        /// Module of global
        case global
        /// Module of kLine
        case kLine
        ///
        public var color: Color { EXTheme.current.color(for: self) }
        ///
        public var isDark: Bool { color == .dark }
        ///
        public static var isDark: Bool { global.isDark }
    }
}

public extension UIColor.Ex {
    
    /// 背景灰色
    ///
    /// 类别:填充色Fill
    static var fill1: UIColor { global.fill1 }
    var fill1: UIColor { named(.fill1) }
    
    /// 卡片色一
    ///
    /// 类别:填充色Fill
    static var fill2: UIColor { global.fill2 }
    var fill2: UIColor { named(.fill2) }
    
    /// 卡片色二
    ///
    /// 类别:填充色Fill
    static var fill3: UIColor { global.fill3 }
    var fill3: UIColor { named(.fill3) }
    
    /// 间隔色
    ///
    /// 类别:填充色Fill
    static var fill4: UIColor { global.fill4 }
    var fill4: UIColor { named(.fill4) }
    
    /// 二级按钮点击色
    ///
    /// 类别:填充色Fill
    static var fill5: UIColor { global.fill5 }
    var fill5: UIColor { named(.fill5) }
    
    /// 弹窗背景
    ///
    /// 类别:填充色Fill
    static var fill6: UIColor { global.fill6 }
    var fill6: UIColor { named(.fill6) }
    
    /// 黑色遮罩色
    ///
    /// 类别:填充色Fill
    static var fill7: UIColor { global.fill7 }
    var fill7: UIColor { named(.fill7) }
    
    /// Toast提示背景色
    ///
    /// 类别:填充色Fill
    static var fill8: UIColor { global.fill8 }
    var fill8: UIColor { named(.fill8) }
    
    /// 标签背景色
    ///
    /// 类别:填充色Fill
    static var fill9: UIColor { global.fill9 }
    var fill9: UIColor { named(.fill9) }
    
    /// 一级颜色
    ///
    /// 类别:文字色Text
    static var text1: UIColor { global.text1 }
    var text1: UIColor { named(.text1) }
    
    /// 二级颜色
    ///
    /// 类别:文字色Text
    static var text2: UIColor { global.text2 }
    var text2: UIColor { named(.text2) }
    
    /// 三级颜色
    ///
    /// 类别:文字色Text
    static var text3: UIColor { global.text3 }
    var text3: UIColor { named(.text3) }
    
    /// 四级颜色
    ///
    /// 类别:文字色Text
    static var text4: UIColor { global.text4 }
    var text4: UIColor { named(.text4) }
    
    /// 五级颜色
    ///
    /// 类别:文字色Text
    static var text5: UIColor { global.text5 }
    var text5: UIColor { named(.text5) }
    
    /// 背景色
    ///
    /// 类别:特殊色Special
    static var special1: UIColor { global.special1 }
    var special1: UIColor { named(.special1) }
    
    /// 背景色
    ///
    /// 类别:特殊色Special
    static var special2: UIColor { global.special2 }
    var special2: UIColor { named(.special2) }
    
    /// 卡片色一
    ///
    /// 类别:特殊色Special
    static var special3: UIColor { global.special3 }
    var special3: UIColor { named(.special3) }
    
    /// 类别:特殊色Special
    static var special4: UIColor { global.special4 }
    var special4: UIColor { named(.special4) }
    
    /// 蓝色常规
    ///
    /// 类别:主色
    static var main1: UIColor { global.main1 }
    var main1: UIColor { named(.main1) }
    
    /// 按钮点击
    ///
    /// 类别:主色
    static var main2: UIColor { global.main2 }
    var main2: UIColor { named(.main2) }
    
    /// 标签背景色
    ///
    /// 类别:主色
    static var main3: UIColor { global.main3 }
    var main3: UIColor { named(.main3) }
    
    /// 文字按钮色
    ///
    /// 类别:主色
    static var main4: UIColor { global.main4 }
    var main4: UIColor { named(.main4) }
    
    /// 上涨绿色
    ///
    /// 类别:辅助色/涨跌色
    static var rise1: UIColor { global.rise1 }
    var rise1: UIColor { named(.rise1) }
    
    /// 按钮点击
    ///
    /// 类别:辅助色/涨跌色
    static var rise2: UIColor { global.rise2 }
    var rise2: UIColor { named(.rise2) }
    
    /// 绿色图表色
    ///
    /// 类别:辅助色/涨跌色
    static var rise3: UIColor { global.rise3 }
    var rise3: UIColor { named(.rise3) }
    
    /// 下跌红色
    ///
    /// 类别:辅助色/涨跌色
    static var fall1: UIColor { global.fall1 }
    var fall1: UIColor { named(.fall1) }
    
    /// 标签背景色
    ///
    /// 类别:辅助色/涨跌色
    static var fall2: UIColor { global.fall2 }
    var fall2: UIColor { named(.fall2) }
    
    /// 红色图表色
    ///
    /// 类别:辅助色/涨跌色
    static var fall3: UIColor { global.fall3 }
    var fall3: UIColor { named(.fall3) }
    
    /// 警示/提醒色
    ///
    /// 类别:辅助色/功能色
    static var warning1: UIColor { global.warning1 }
    var warning1: UIColor { named(.warning1) }
    
    /// 黄色警示图表色
    ///
    /// 类别:辅助色/功能色
    static var warning2: UIColor { global.warning2 }
    var warning2: UIColor { named(.warning2) }
    
    /// 红色错误提示
    ///
    /// 类别:辅助色/功能色
    static var error1: UIColor { global.error1 }
    var error1: UIColor { named(.error1) }
    
    /// 指标黄
    ///
    /// 类别:辅助色/K线指标色
    static var line1: UIColor { global.line1 }
    var line1: UIColor { named(.line1) }
    
    /// 指标绿
    ///
    /// 类别:辅助色/K线指标色
    static var line2: UIColor { global.line2 }
    var line2: UIColor { named(.line2) }
    
    /// 指标紫
    ///
    /// 类别:辅助色/K线指标色
    static var line3: UIColor { global.line3 }
    var line3: UIColor { named(.line3) }
    
    /// 指标红
    ///
    /// 类别:辅助色/K线指标色
    static var line4: UIColor { global.line4 }
    var line4: UIColor { named(.line4) }
    
    /// 涨
    static var up1: UIColor { global.up1 }
    var up1: UIColor { EXTheme.KLineTrend.isReversed ? fall1 : rise1 }
    ///
    static var up2: UIColor { global.up2 }
    var up2: UIColor { EXTheme.KLineTrend.isReversed ? fall2 : rise2 }
    ///
    static var up3: UIColor { global.up3 }
    var up3: UIColor { EXTheme.KLineTrend.isReversed ? fall3 : rise3 }
    
    /// 跌
    static var down1: UIColor { global.down1 }
    var down1: UIColor { EXTheme.KLineTrend.isReversed ? rise1 : fall1 }
    ///
    static var down2: UIColor { global.down2 }
    var down2: UIColor { EXTheme.KLineTrend.isReversed ? rise2 : fall2 }
    ///
    static var down3: UIColor { global.down3 }
    var down3: UIColor { EXTheme.KLineTrend.isReversed ? rise3 : fall3 }
    
    ///
    static var kLineTrendReversed: Bool { EXTheme.KLineTrend.isReversed }
}

public extension UIColor.Ex {
    ///
    enum Color : Int, CaseIterable, Codable {
        case unspecified = 0
        case light = 1
        case dark = 2
        ///
        public var resolved: Self {
            switch self {
                case .unspecified:
                    return UIScreen.main.traitCollection.userInterfaceStyle == .dark ? .dark : .light
                case .light,.dark:
                    return self
            }
        }
        ///
        public static var allCases: [Self] = [.light, .dark]
    }
}

extension UIColor.Ex.Color {
    public static var global: Self { UIColor.Ex.global.color }
    public static var kLine : Self { UIColor.Ex.kLine.color }
}

extension UIColor.Ex {
    
    /// Get color with the specified name and color
    /// - Parameters:
    ///   - name: colorName of the descriptor, which is decoded from the configuartion file
    ///   - color: The color style. If the color is nil, will be resolved to the color of this module
    /// - Returns: UIColor or the resolved color
    public static func named(_ name:String, color:Color? = nil) -> UIColor {
        return global.named(name, color: color)
    }
    public func named(_ name:String, color:Color? = nil) -> UIColor {
        return Descriptor.for(name: name, color: (color ?? self.color).resolved)?.color ?? Self.resolved
    }
    
    /// Get colors with the specified name, used for gradient views always.
    /// - Parameter name: colorName of the descriptor, which is decoded from the configuartion file
    /// - Returns: The gradient colors
    public static func named(_ name:String, color:Color? = nil) -> [UIColor]? {
        return global.named(name, color: color)
    }
    public func named(_ name:String, color:Color? = nil) -> [UIColor]? {
        return Descriptor.for(name: name, color: (color ?? self.color).resolved)?.colors
    }
}

extension UIColor.Ex {
    /// default colors
    public var defaultColors: [UIColor] { named(.default) ?? [] }
    public static var defaultColors: [UIColor] { global.defaultColors }
    
    // skeleton
    public var skeleton: [UIColor] { named(.skeleton)! }
    public static var skeleton: [UIColor] { global.skeleton }
    
    /// The default color, resolved to white
    fileprivate static let resolved:UIColor = .white
}

extension UIColor.Ex {
    public struct Name {
        ///
        public enum Color:String {
            case fill1
            case fill2
            case fill3
            case fill4
            case fill5
            case fill6
            case fill7
            case fill8
            case fill9
            case text1
            case text2
            case text3
            case text4
            case text5
            case special1
            case special2
            case special3
            case special4
            case main1
            case main2
            case main3
            case main4
            case rise1
            case rise2
            case rise3
            case fall1
            case fall2
            case fall3
            case warning1
            case warning2
            case error1
            case line1
            case line2
            case line3
            case line4
        }
        ///
        public enum Colors:String {
            case `default` = "gradient.default"
            case skeleton  = "gradient.skeleton"
        }
    }
    ///
    public func named(_ name:Name.Color, color:Color? = nil) -> UIColor {
        named(name.rawValue, color: color)
    }
    ///
    public static func named(_ name:Name.Color, color:Color? = nil) -> UIColor {
        return named(name.rawValue, color: color)
    }
    ///
    public func named(_ name:Name.Colors, color:Color? = nil) -> [UIColor]? {
        named(name.rawValue, color: color)
    }
    ///
    public static func named(_ name:Name.Colors, color:Color? = nil) -> [UIColor]? {
        named(name.rawValue, color: color)
    }
}

public extension UIColor {
    /// String value of rgba
    var rgbaString: String? {
        guard let rgb = rgbString else { return nil }
        return rgb + alphaString
    }
    /// String value of argb
    var argbString: String? {
        guard let rgb = rgbString else { return nil }
        return alphaString + rgb
    }
    /// String value of rgb
    var rgbString: String? {
        /// [CGColorSpaceModel.rgb,.monochrome].contains(cgColor.colorSpace?.model)
        guard let components = cgColor.components,components.count > 0 else { return nil }
        let count = cgColor.numberOfComponents
        guard count == 2 || count == 4 else { return nil }
        let red:CGFloat = components.first!
        var green:CGFloat = 1.0, blue:CGFloat = 1.0
        if count == 4 {
            green = components[1]
            blue = components[2]
        }
        let rgb = [red,green,blue].map({ $0.colorHexString }).reduce("", +)
        return rgb
    }
    var alphaString: String { cgColor.alpha.colorHexString }
}

extension CGFloat {
    var colorHexString: String { String(format: "%02lX", Int(self * 255)) }
}

fileprivate extension UIColor.Ex {
    final class Descriptor : Codable {
        /// category of this descriptor
        fileprivate let category: String?
        /// name of this descriptor, must be unique
        fileprivate let name: String
        /// old style color will redirect to the descriptor named $redirect
        fileprivate let redirect: String?
        /// desc for this descriptor
        fileprivate let desc: String?
        /// hex for this descriptor, format must be ARGB_8888 or RGB_888, such as FFEEDDCC, EEDDCC ... etc
        private let colorValue: String?
        /// hex array for gradient
        private let colorsValue: [String]?
        /// alpha of the color, such as 0.1, 0.15, 1 ...
        private let alphaValue: String?
        /// version of this descriptor
        fileprivate let version: String?
        ///
        private enum CodingKeys:String,CodingKey {
            case category
            case name
            case redirect
            case colorValue  = "color"
            case colorsValue = "colors"
            case alphaValue  = "alpha"
            case desc
            case version
        }
        
        ///
        private lazy var alpha: CGFloat? = {
            guard let string = alphaValue, let alpha = Double(string), (0...1.0).contains(alpha) else { return nil }
            return CGFloat(alpha)
        }()
        
        /// color from hex value
        fileprivate lazy var color: UIColor? = { Self.color(with: colorValue, alpha: alpha) }()
        /// colors from hex values for gradient
        fileprivate lazy var colors: [UIColor]? = { colorsValue?.compactMap({ Self.color(with:$0) }) }()
        ///
        fileprivate static func `for`(name:String,color:UIColor.Ex.Color) -> Descriptor? {
            let descriptor = color.configuartion[name]
            assert(descriptor != nil, "could not find the descriptor named (\(name)) for color(\(color))")
            return descriptor
        }
        
        /// Get color with the specified hex value and alpha
        /// - Parameters:
        ///   - value: The color description with hex style, format must be ARGB_888 or RGB_8888, such as FFEEDDCC, EEDDCC ... etc
        ///   - alpha: Alpha of the color, such as 0.1, 0.15, 1 ...
        /// - Returns: An instance of UIColor if success, nil otherwise
        ///
        /// - The color format must be ARGB_888 or RGB_8888, such as FFEEDDCC, EEDDCC ... etc
        /// - The priority of alpha is higher than the value of the hex input
        private static func color(with value:String?, alpha:CGFloat? = nil) -> UIColor? {
            guard let value = value else { return nil }
            /// remove all whitespaces and newlines
            var string = value.components(separatedBy: .whitespacesAndNewlines).joined()
            /// remove #
            if string.hasPrefix("#") { string.removeFirst() }
            /// remove 0X or 0x
            if string.hasPrefix("0X") || string.hasPrefix("0x") { string.removeFirst(2) }
            ///
            if !string.isEmpty {
                string = string.uppercased()
                if string.count == 6 { string = "FF" + string }
                var color:UIColor?
                if string.count == 8, let value = Int(string,radix: 16) {
                    let alpha = 0xFF & value >> 24
                    let red = 0xFF & value >> 16
                    let green = 0xFF & value >> 8
                    let blue = 0xFF & value
                    color = UIColor(red   : CGFloat(red)   / 255.0,
                                    green : CGFloat(green) / 255.0,
                                    blue  : CGFloat(blue)  / 255.0,
                                    alpha : CGFloat(alpha) / 255.0)
                }
                if let alpha = alpha {
                    color = color?.withAlphaComponent(alpha)
                }
                return color
            }
            assertionFailure("could not get the color from \(value)")
            return nil
        }
    }
}

extension UIColor.Ex.Color : CustomStringConvertible {
    public var description: String {
        switch self {
            case .light: return "Light"
            case .dark : return "Dark"
            case .unspecified: return resolved.description
        }
    }
}

extension UIColor.Ex.Color {
    public var resourceSuffix: String {
        switch self {
            case .light: return "_daytime"
            case .dark : return "_night"
            case .unspecified: return resolved.resourceSuffix
        }
    }
    private var fileName:String {
        switch self {
            case .light: return "EXThemeColorLight"
            case .dark : return "EXThemeColorDark"
            case .unspecified: return resolved.fileName
        }
    }
    private static var configuartions:[UIColor.Ex.Color:[String:UIColor.Ex.Descriptor]] = [:]
    fileprivate var configuartion: [String:UIColor.Ex.Descriptor] {
        if let configuartion = Self.configuartions[self] { return configuartion }
        objc_sync_enter(Self.configuartions)
        defer { objc_sync_exit(Self.configuartions) }
        if let configuartion = Self.configuartions[self] { return configuartion }
        if let path = EXThemeBundle.path(forResource: fileName, ofType: "json", inDirectory: "Color"),
           let data = NSData(contentsOfFile: path),
           let configuartion = try? JSONDecoder().decode([UIColor.Ex.Descriptor].self, from: data as Data) {
            var map:[String:UIColor.Ex.Descriptor] = [:]
            configuartion.forEach { map[$0.name] = $0 }
            /// update redirections
            configuartion.forEach { descriptor in
                guard let redirect = descriptor.redirect else { return }
                let name = descriptor.name
                guard let descriptor = map[redirect] else { return }
                map[name] = descriptor
            }
            Self.configuartions[self] = map
            return map
        }
        assertionFailure("configuartion named \(fileName).plist for color:\(self) does not exist")
        return [:]
    }
}

extension UIColor.Ex {
    public static let LookinColorAlias: [String:Any] = {
        var colors:[String:Any] = [:]
        Color.allCases.forEach { `case` in
            let type = `case`.description
            var map:[String:UIColor] = [:]
            `case`.configuartion.forEach { (key: String, value: UIColor.Ex.Descriptor) in
                guard let color = value.color else { return }
                ///
                var name = value.name
                if let desc = value.desc {
                    name = "★ \(value.name) [\(desc)]"
                }
                /// for section panel menu item
                map[name] = color
                /// for color alias panel
                colors[type + " " + name] = color
            }
            colors[type] = map
        }
        return colors
    }()
}
