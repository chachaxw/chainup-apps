//
//  Theme.swift
//  EXUIKit
//
//  Created by zq on 2023/1/20.
//

import UIKit

// MARK: - EXTheme
public struct EXTheme : Codable {
    ///
    internal let configuartion:[UIColor.Ex:UIColor.Ex.Color]
    internal let version:Int
    public static let version:Int = 1
    public init(_ configuration:[UIColor.Ex:UIColor.Ex.Color], version:Int = EXTheme.version) {
        var map = configuration
        if let globalColor = map[.global] {
            UIColor.Ex.allCases.forEach { module in
                guard map[module] == nil else { return }
                map[module] = globalColor
            }
        }
        self.configuartion = map
        self.version = version
    }
    ///
    public init(_ color:UIColor.Ex.Color) {
        var configuration:[UIColor.Ex:UIColor.Ex.Color] = [:]
        UIColor.Ex.allCases.forEach { configuration[$0] = color }
        self.init(configuration)
    }
}

extension EXTheme: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.configuartion == rhs.configuartion && lhs.version == rhs.version
    }
}

extension EXTheme: CaseIterable {
    /// 白天版
    public static let light = Self(.light)
    /// 夜间版
    public static let dark  = Self(.dark)
    /// 白天版&K线夜间版
    public static let dayKLineNight = Self([.global:.light, .kLine:.dark])
    /// 默认主题集合
    public static let allCases: [Self] = [light, dark, dayKLineNight]
    /// 默认主题
    public static var `default`: Self = .light
    ///
    public static var isDark: Bool { current.isDark }
    ///
    public var isDark: Bool { self == .dark }
}

extension EXTheme: RawRepresentable {
    public typealias RawValue = Data?
    public var rawValue: Data? { try? JSONEncoder().encode(self) }
    public init?(rawValue: Data?) {
        guard let data = rawValue else { return nil }
        guard let theme = try? JSONDecoder().decode(EXTheme.self, from: data) else { return nil }
        self = theme
    }
}

public extension EXTheme {
    func color(for module:UIColor.Ex) -> UIColor.Ex.Color {
        return (configuartion[module] ?? .unspecified).resolved
    }
    var global: UIColor.Ex.Color { color(for: .global) }
    var kLine : UIColor.Ex.Color { color(for: .kLine) }
}

extension EXTheme {
    /// 初始值
    private static let initial: Self = {
        /// 如果有新的数据,则取新数据
        if let value = UserDefaults.standard.data(forKey: didUpdateNotification.rawValue),
           let theme = Self(rawValue: value) {
            return theme
        }
        /**
         old
         case day   = 0
         case night = 1
         case dayKlinenight = 2
         */
        /// 兼容之前的旧版数据
        if UserDefaults.standard.dictionaryRepresentation().keys.contains(lastThemeIndexKey) {
            let oldThemeValue = UserDefaults.standard.integer(forKey: lastThemeIndexKey)
            var theme:EXTheme?
            switch oldThemeValue {
            case 0://day
                theme = .light
            case 1://night
                theme = .dark
            case 2://dayKlinenight
                theme = .dayKLineNight
            default:
                break
            }
            if let theme = theme {
                theme.save() // 迁移旧版Theme数据
                return theme
            }
        }
        /// 首次要看本地
        if isDarkAsDefault {
            /// 存储下数据
            dark.save()
            return .dark
        }
        `default`.save() // 可根据需要决定是否存储默认值,以防止未来默认值更新导致用户界面的变化
        return .default
    }()
    
    private static let isDarkAsDefault: Bool = {
        return (Bundle.main.infoDictionary?["appDarkTheme"] as? String == "1") == true
    }()
    
    ///
    private static var `internal`: Self?
    /// 当前配置
    public private (set) static var current: Self {
        set {
            let equal = newValue == Self.internal
            Self.internal = newValue
            newValue.save()
            if !equal { NotificationCenter.default.post(name: didUpdateNotification, object: self) }
        }
        get { `internal` ?? initial }
    }
    ///
    private func save() {
        UserDefaults.standard.set(rawValue, forKey: Self.didUpdateNotification.rawValue)
    }
    /// 主题色切换通知
    public static let didUpdateNotification: NSNotification.Name = NSNotification.Name("EXTheme")
    /// 是否为当前配置
    public var isActive: Bool { .current == self }
    /// 激活为当前配置
    @discardableResult
    public func active() -> Bool {
        guard self != .current else { return false }
        Self.current = self
        return true
    }
}

/// 涨跌色配置
extension EXTheme {
    /// K线图走势
    @frozen public enum KLineTrend : Int, CaseIterable {
        /// 跟随全局设置, 仅用于 EXTraitCollection 配置
        case unspecified = 0
        /// 绿涨红跌
        case normal = 1
        /// 红涨绿跌
        case reversed = 2
        ///
        public var resolved: Self {
            switch self {
                case .unspecified:
                    return .current
                case .normal,.reversed:
                    return self
            }
        }
        public init?(rawValue: Int) {
            switch rawValue {
                case 1:
                    self = .normal
                case 2:
                    self = .reversed
                default:
                    return nil
            }
        }
        ///
        public static var allCases: [Self] = [.normal, .reversed]
    }
}


// MARK: - KLineTrend
extension EXTheme.KLineTrend {
    /// 初始值
    private static let initial: Self = {
        /// 如果有新的数据,则取新数据
        if let trend = Self(rawValue: UserDefaults.standard.integer(forKey: didUpdateNotification.rawValue)) {
            return trend
        }
        /// 兼容之前的旧版数据
        if UserDefaults.standard.dictionaryRepresentation().keys.contains(lastedKlineIndex),
           let trend = Self(rawValue: UserDefaults.standard.integer(forKey: lastedKlineIndex) + 1) { /// 之前版本的是 0:绿涨红跌 1:红涨绿跌
            trend.save() // 迁移旧版Thrend数据
            return trend
        }
        `default`.save() // 可根据需要决定是否存储默认值,以防止未来默认值更新导致用户界面的变化
        return .default
    }()
    /// 默认配置
    public  static var `default`: Self = .normal
    ///
    public  static var isReversed: Bool { current == .reversed }
    ///
    private static var `internal`: Self?
    /// 当前配置
    public private (set) static var current: Self {
        set {
            var trend = newValue
            if trend == .unspecified {
                assertionFailure("value of unspecified cannot be specified, and will be redirect to the default value")
                trend = .default
            }
            let equal = newValue == Self.internal
            guard !equal else { return }
            Self.internal = trend
            UserDefaults.standard.set(trend.rawValue, forKey: didUpdateNotification.rawValue)
            if !equal { NotificationCenter.default.post(name: didUpdateNotification, object: self) }
        }
        get { `internal` ?? initial }
    }
    ///
    private func save() {
        UserDefaults.standard.set(rawValue, forKey: Self.didUpdateNotification.rawValue)
    }
    /// 涨跌色切换通知
    public static let didUpdateNotification: NSNotification.Name = .init("EXTheme.KLineTrend")
    /// 是否为当前配置
    public var isActive: Bool { .current == self }
    /// 激活为当前配置
    @discardableResult
    public func active() -> Bool {
        guard self != .current else { return false }
        Self.current = self
        return true
    }
}
