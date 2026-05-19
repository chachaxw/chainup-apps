//
//  EXSInputLimitDelegate.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/11.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXSInputLimitDelegate: NSObject {
    
    var limetValue:Int = 2 //小数点精度位数 English: Decimal precision
    var maxLength:Int = 9
    
    var maxInptLenght:Int {
        return limetValue + maxLength + 1
    }
    var decail:String = ""{
        
        didSet {
            resizeLimitValue(px_unit: decail)
        }
    }
    
    func resizeLimitValue(px_unit:String?) {
        
        if px_unit != nil {
            
            if px_unit!.contains("."){
                let pointRange = (px_unit! as NSString).range(of: ".")
                
                let subSting = (px_unit! as NSString).substring(from: pointRange.location)
                
                self.limetValue = subSting.count - 1
                if limetValue <= 0 {
                    
                    limetValue = 1
                }
                return
            }
            limetValue = 0
           
        }
    }
    
}
extension EXSInputLimitDelegate:UITextFieldDelegate {
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//
//        let nsString = textField.text as NSString?
//        let newString = nsString?.replacingCharacters(in: range, with: string)
//
//        //print("range=> \(range)")
//        //print("string=> \(string)")
//        //print("textField.text=> \(textField.text)")
//        if let newStr = newString {
//            //整数最大位数 English: Maximum number of integers
//            if newStr.contains(".") == false {
//                if newStr.count > maxLength {
//                    return false
//                }
//            }
//            //超长处理，其他往下走逻辑 English: Extra long processing, other downstream logic
//            if newStr.count > maxInptLenght  {
//                return false
//            }
//
//        }
//
//        let scanner = Scanner(string: string)
//        let numbers : NSCharacterSet
//        let pointRange = (textField.text! as NSString).range(of: ".")
//
//        if (pointRange.length > 0) && pointRange.length < range.location || pointRange.location > range.location + range.length {
//            numbers = NSCharacterSet(charactersIn: "0123456789.")
//        }else{
//            numbers = NSCharacterSet(charactersIn: "0123456789.")
//        }
//
//        if textField.text == "" && (string == "." || string == "," ){
//            return false
//        }
//
//        let tempStr = textField.text!.appending(string)
//
//        let strlen = tempStr.count
//
//        if pointRange.length > 0 && pointRange.location > 0{//判断输入框内是否含有“.”。 English: Check if there is a "." in the input box.
//            if string == "." {
//                return false
//            }
//
//            if strlen > 0 && (strlen - pointRange.location) > self.limetValue + 1 {//当输入框内已经含有“.”，当字符串长度减去小数点前面的字符串长度大于需要要保留的小数点位数，则视当次输入无效。 English: When the input box already contains "." and the length of the string minus the length of the string before the decimal point is greater than the number of decimal places to be retained, the input is considered invalid.
//                return false
//            }
//        }
//
//        let zeroRange = (textField.text! as NSString).range(of: "0")
//        if zeroRange.length == 1 && zeroRange.location == 0 { //判断输入框第一个字符是否为“0” English: Check if the first character in the input box is "0"
//            if !(string == "0") && !(string == ".") && textField.text?.count == 1 {//当输入框只有一个字符并且字符为“0”时，再输入不为“0”或者“.”的字符时，则将此输入替换输入框的这唯一字符。 English: When the input box has only one character and the character is "0", and a character other than "0" or "." is entered, this input will replace the unique character in the input box.
//                textField.text = string
//                return false
//            }else {
//                if pointRange.length == 0 && pointRange.location > 0 {//当输入框第一个字符为“0”时，并且没有“.”字符时，如果当此输入的字符为“0”，则视当此输入无效。 English: When the first character in the input box is "0" and there is no "." character, if the input character is "0", it is considered invalid.
//                    if string == "0" {
//                        return false
//                    }
//                }
//            }
//        }
//        //        let buffer : NSString!
//        if !scanner.scanCharacters(from: numbers as CharacterSet, into: nil) && string.count != 0 {
//            return false
//        }
//
//        return true
//
//    }
//}

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.keyboardType == .numberPad ||
            textField.keyboardType == .decimalPad {
            let nsString = textField.text as NSString?
            let newString = nsString? .replacingCharacters(in: range, with: string)
            //print("limint =>\(limetValue)")
            if let newStr = newString {
                //超长处理，其他往下走逻辑 English: Extra long processing, other downstream logic
                if newStr.count > maxInptLenght {
                    return false
                }
            }
            
            if textField.keyboardType == .numberPad{
                if isNumber(newString ?? ""){
                    return true
                }else{
                    //如果不是纯数字直接清空，避免无法操作。 English: If it is not a pure number, clear it directly to avoid being unable to operate.
                    textField.text = ""
                  //  EXAlert.showFail(msg: "userinfo_tip_inputPhone".localized())
                    return false
                }
            }
            
            if string.isEmpty {
                return true
            }else {
                guard let inputStr = newString else {
                    return false
                }
                return inputStr.isValidInputAmount(decimal: limetValue)
            }
        }
        return true
    }
}


// 判断是否为纯数字 English: Determine whether it is a pure number
func isNumber(_ str : String) -> Bool{
    var tmpresult = false
    
    var regex: NSRegularExpression = NSRegularExpression.init()
    
    let linkPattern: String = "^\\d{0,}$"
    
    //构造正则表达式 English: Constructing Regular Expressions
    do {
        regex = try NSRegularExpression.init(pattern: linkPattern, options: NSRegularExpression.Options.caseInsensitive)
    } catch {
       // EXAlert.showFail(msg:"正则表达式有问题".localized()) English: EXAlert. showFailure (msg: "Regular expression problem". localized())
    }
    
    //遍历目标字符串 English: Traverse target string
    regex.enumerateMatches(in: str, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, str.count)) { (result, flags, stop) in
        if result == nil {
            return
        } else {
            tmpresult = true
            return
        }
    }
    return tmpresult
}

