//
//  EXInputSheetModel.swift
//  Chainup
//
//  Created by liuxuan on 2020/3/16.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit

public enum SheetFieldItemlStyle {
    case input // 纯输入框
    case sms // 发验证码的
    case email // 邮箱验证码
    case paste //黏贴功能
}

public class EXInputSheetModel: NSObject {
    typealias ClickBlock = () -> ()//点击block
    var clickBlock : ClickBlock?
    var title:String = ""//输入框的title,没有不写
    var inputText:String = ""//输入框的内容
    var inputPlaceHoloder:String = ""//输入框的placeholder
    var type:SheetFieldItemlStyle = .input
    var keyboard:UIKeyboardType = UIKeyboardType.default
    var key:String = ""
    var enablePrivacy:Bool = false
    var enableTitleMode:Bool = false
    var unit = ""
    ///部分页面(例如忘记密码),会在弹出的时候,自动发送一次验证码
    var autoSend:Bool = false
    
    public class func setModel(withTitle:String = "",
                        key:String,
                        inputText:String = "",
                        placeHolder:String = "",
                        type:SheetFieldItemlStyle = .input,
                        autoSend:Bool = false,
                        privacyMode:Bool = false,
                        keyBoard:UIKeyboardType? = nil,
                        unit:String = "") -> EXInputSheetModel{
        let model = EXInputSheetModel.init()
        if withTitle.isEmpty {
            model.enableTitleMode = false
        }else {
            model.enableTitleMode = true
        }
        model.key = key
        model.title = withTitle
        model.inputText = inputText
        model.inputPlaceHoloder = placeHolder
        model.type = type
        model.autoSend = autoSend
        model.enablePrivacy = privacyMode
        if let keyBoard = keyBoard {
            model.keyboard = keyBoard
        }else{
            if type == .sms {
                model.keyboard = .phonePad
            }else if type == .email {
                model.keyboard = .emailAddress
            }else if type == .paste {
                model.keyboard = .numberPad
            }
        }
        model.unit = unit
        return model
    }
    
}
