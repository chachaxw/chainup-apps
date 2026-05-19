//
//  EXInputSheetModel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/16.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXSSheetFieldItemlStyle {
    case input // 纯输入框 English: Pure input box
    case sms // 发验证码的 English: Sending verification codes
    case paste //黏贴功能 English: Adhesive function
}

class EXSInputSheetModel: NSObject {
    typealias ClickBlock = () -> ()//点击block English: Click on block
    var clickBlock : ClickBlock?
    var title:String = ""//输入框的title,没有不写 English: Enter the title of the input box, do not write it if there is none
    var inputText:String = ""//输入框的内容 English: The content of the input box
    var inputPlaceHoloder:String = ""//输入框的placeholder English: Placeholder of input box
    var type:EXSSheetFieldItemlStyle = .input
    var keyboard:UIKeyboardType = UIKeyboardType.default
    var key:String = ""
    var enablePrivacy:Bool = false
    var enableTitleMode:Bool = false
    var unit = ""
    
    class func setModel(withTitle:String = "",
                        key:String,
                        inputText:String = "",
                        placeHolder:String = "",
                        type:EXSSheetFieldItemlStyle = .input,
                        privacyMode:Bool = false,
                        keyBoard:UIKeyboardType = .default,
                        unit:String = "") -> EXSInputSheetModel{
        let model = EXSInputSheetModel.init()
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
        model.enablePrivacy = privacyMode
        model.keyboard = keyBoard
        model.unit = unit
        return model
    }
}

