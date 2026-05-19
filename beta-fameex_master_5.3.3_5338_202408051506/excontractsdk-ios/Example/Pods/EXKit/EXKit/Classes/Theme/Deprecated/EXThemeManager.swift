//
//  EXThemeManager.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/30.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

private let defaults = UserDefaults.standard

public enum EXThemeManager: Int {
    
    case day   = 0
    case night = 1
    case dayKlinenight = 2
    
    // MARK: -
    public static var current: EXThemeManager {
        switch EXTheme.current {
        case .light:
            return .day
        case .dark:
            return .night
        case .dayKLineNight:
            return .dayKlinenight
        default:
            return .day
        }
    }
    
    public static func isNight(_ module:UIColor.Ex = .global) -> Bool {
        return EXTheme.current.color(for: module) == .dark
    }
}

public struct EXKLineManager {
    public static func isGreen() -> Bool {
        return EXTheme.KLineTrend.current == .default
    }
}

