//
//  Compent.swift
//  EXKit_Example
//
//  Created by cwd on 2023/5/17.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit

enum CompentType:String,CaseIterable {
    case color     = "Color"
    case textField = "输入框"
    case button    = "按钮 & Switch"
    case alert     = "Dialoag 对话框"
    case selector  = "选中器"
    case tag       = "标签"
    case popCard   = "Toast 轻提示气泡"
    case skeleton  = "骨架"
    case search    = "搜索"
    ///
    var exampleViewController: UIViewController? {
        switch self {
            case .textField: return InputViewController()
            case .button: return ButtonViewController()
            case .alert: return AlertViewController()
            case .selector: return nil
            case .tag: return TagViewController()
            case .popCard: return PopoverViewController()
            case .skeleton: return SkeletonViewController()
            case .search: return SearchBarViewController()
            case .color: return EXColorTableViewController()
        }
    }
}
