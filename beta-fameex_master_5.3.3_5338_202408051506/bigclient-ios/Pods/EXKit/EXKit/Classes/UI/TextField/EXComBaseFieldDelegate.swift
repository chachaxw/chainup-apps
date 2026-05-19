//
//  EXComBaseFieldDelegate.swift
//  EXKit
//
//  Created by cwd on 2023/11/30.
//

import UIKit

public class EXComBaseFieldDelegate: NSObject  {
    var decimalType:DecimalType = .coin
    var symbol:String = ""
    var decimal:String = ""
    var maxLenth:Int = 32 {
        didSet{
            if maxLenth > 0 {
                self.forceInputLenth = true
            }
        }
    }
    var forceInputLenth:Bool = false
}

extension EXComBaseFieldDelegate : UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.keyboardType == .numberPad ||
            textField.keyboardType == .decimalPad {
            let nsString = textField.text as NSString?
            let newString = nsString? .replacingCharacters(in: range, with: string)
            
            if let newStr = newString {
                //Ultra long processing, other downward logic
                if newStr.count > maxLenth {
                    return false
                }
            }
            
            if string.isEmpty {
                return true
            }else {
                //Whether it is legal currency precision or currency precision, the beginning of the dot returns false
                let regex = "^[0][0-9]+$"
                let regexDot = "^[.]+$"
                let predicate0 = NSPredicate(format: "SELF MATCHES %@", regex)
                let predicateDot = NSPredicate(format: "SELF MATCHES %@", regexDot)
                let isZeroPrefix = predicate0.evaluate(with: newString)
                let isDotPrefix = predicateDot.evaluate(with: newString)
                if  isDotPrefix || isZeroPrefix {
                    return false
                }else {
                    var decimalPrecision = 8
                    if decimal.count > 0 {
                        decimalPrecision = Int(decimal) ?? 8
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
                    //Ultra long processing, other downward logic
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

