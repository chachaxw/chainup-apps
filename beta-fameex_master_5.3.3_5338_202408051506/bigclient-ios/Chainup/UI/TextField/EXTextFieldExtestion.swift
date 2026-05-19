
//
//  EXBaseField.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit

extension EXBaseField : EXSwiftLoadProtocol {
    public static func swiftLoad() {
        EXBaseField.shouldChangeCharactersInBlock = { (baseField, textField, range, string) in
            let result = baseField.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
            return result
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.inputLimitPattern != nil{
            let nsString = textField.text as NSString?
            let newString = nsString? .replacingCharacters(in: range, with: string)
            if let newStr = newString {
                let result = containSpecialCha(fullStr: newStr)
                return !result
            }
            return true
        }
        
        if textField.keyboardType == .numberPad ||
            textField.keyboardType == .decimalPad {
            let nsString = textField.text as NSString?
            let newString = nsString? .replacingCharacters(in: range, with: string)
            
            if let newStr = newString {
                //超长处理，其他往下走逻辑
                if newStr.count > maxLenth {
                    return false
                }
            }
            
            if textField.keyboardType == .numberPad{
                if BusinessTools.number(newString ?? ""){
                    return true
                }else{
                    return false
                }
            }
            
            if string.isEmpty {
                return true
            }else {
                if symbol.isEmpty && decimal.isEmpty {
                    return true
                }else {
                    var decimalPrecision = 8
                    if decimalType == .coin {
                        if decimal.count > 0 {
                            let decimal = Int(self.decimal)
                            if let symbolDecimal = decimal,symbolDecimal >= 0 {
                                decimalPrecision = symbolDecimal
                            }
                        }else {
                            if let precision = EXAppMarketManager.sharedInstance.getCoinEntity(self.symbol)?.showPrecision {
                                let decimal = Int(precision)
                                if let symbolDecimal = decimal,symbolDecimal >= 0 {
                                    decimalPrecision = symbolDecimal
                                }
                            }
                        }
                    }else {
                        if decimal.count > 0 {
                            decimalPrecision = Int(decimal) ?? 8
                        }else {
                            decimalPrecision = EXAppMarketManager.sharedInstance.getRatePrecision()
                        }
                    }
                    guard let inputStr = newString else {
                        return false
                    }
                    return inputStr.isValidInputAmount(decimal: decimalPrecision)
                }
            }
        }else {
            if forceInputLenth {
                let nsString = textField.text as NSString?
                let newString = nsString? .replacingCharacters(in: range, with: string)
                
                if let newStr = newString {
                    if newStr.count > maxLenth {
                        return false
                    }
                }
                return true
            }
            return true
        }
    }
}
extension EXBaseField{
    func containSpecialCha(fullStr: String) -> Bool{
        let regex = try? NSRegularExpression(pattern: self.inputLimitPattern!, options: .caseInsensitive)
        if let matches = regex?.matches(in: fullStr, options: [], range: NSMakeRange(0, fullStr.count)) {
            return matches.count > 0
        } else {
            return false
        }
    }
}
