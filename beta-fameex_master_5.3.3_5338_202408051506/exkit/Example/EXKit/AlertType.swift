//
//  AlertType.swift
//  EXKit_Example
//
//  Created by cwd on 2023/5/17.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

enum AlertType:String,CaseIterable {
    case activities
    case versionUpdate
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    var desc: String{
        switch self{
        case .activities:
            return "运营活动"
        case .versionUpdate:
            return "版本升级"
        case .one:
            return "标题-横向2按钮"
        case .two:
            return "标题-只有一个按钮"
        case .three:
            return "标题-内容-横向2按钮"
        case .four:
            return "标题-内容-一个按钮"
        case .five:
            return "图-=标题-内容-横向2按钮"
        case .six:
            return "图-=标题-内容-一个按钮"
        case .seven:
            return "标题-竖2个按钮"
        case .eight:
            return "标题-内容-竖2个按钮"
        default:
            return "xxxx"
        }
    }
}
