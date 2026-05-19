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


enum DecimalType {
    case cny //Precision of fiat currency
    case coin //Currency accuracy
}


class EXBaseField: NibBaseView {
    var inputLimitPattern: String?
    var decimalType:DecimalType = .coin
    var symbol:String = ""
    var decimal:String = ""
    var maxLenth:Int = 32 {
        didSet{
            if maxLenth > 0 {
                self.forceInputLenth = true 
            }
        }
    }  //Default maximum length of 32
    var forceInputLenth:Bool = false
    var rxhasError = BehaviorRelay<Bool>(value: false)
    var hasError:Bool {
        get {
            return rxhasError.value
        }
        set {
            rxhasError.accept(newValue)
        }
    }
    
    typealias TxtFieldDidBeginBlock = () -> ()
    typealias TxtFieldDidEndBlock = () -> ()
    typealias TxtFieldValueChanged = (String) -> ()
    var textfieldDidBeginBlock : TxtFieldDidBeginBlock?
    var textfieldDidEndBlock : TxtFieldDidEndBlock?
    var textfieldValueChangeBlock : TxtFieldValueChanged?
    
    func setPlaceHolder(placeHolder:String , font : CGFloat) {}
    func setText(text:String) {}
    func setTitle(title:String) {}
    
//    func showError(){}
//    func hideError(){}
//    
    
    override func onCreate() {
        self.backgroundColor = UIColor.ThemeView.bg
        self.rxhasError.asObservable()
        .subscribe(onNext: { [weak self] error in
            guard self != nil else { return }
            if error {
//                self.showError()
            }
        }).disposed(by: self.disposeBag)
    }
    
    
    func hideError(_ textField:UITextField) {
        if let placeHolder = textField.placeholder {
            textField.setPlaceHolderAtt(placeHolder)
        }
    }
//
//    func showError(_ textField:UITextField? = nil , _ effectView:UIView? = nil, _ isBorder:Bool = false) {
//        guard let txtField = textField else {return}
//        guard let effectsView = effectView else {return}
//        if isBorder {
//            effectsView.layer.borderColor = UIColor.ThemeState.fail.cgColor
//        }else {
//            effectsView.backgroundColor = UIColor.ThemeState.fail
//        }
//        if let placeHolder = txtField.placeholder {
//            txtField.setPlaceHolderAtt(placeHolder,color:UIColor.ThemeState.fail)
//        }
//    }
}

extension EXBaseField : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if self.inputLimitPattern != nil{
            let nsString = textField.text as NSString?
            let newString = nsString? .replacingCharacters(in: range, with: string)
//            print("textField.text =>\(nsString)")
//            print("newString =>\(newString)")
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
                //Ultra long processing, other downward logic
                if newStr.count > maxLenth {
                    return false
                }
            }
            
//            if textField.keyboardType == .numberPad{
//                if BusinessTools.number(newString ?? ""){
//                    return true
//                }else{
//                    EXAlert.showFail(msg: "userinfo_tip_inputPhone".localized())
//                    return false
//                }
//            }
            
            if string.isEmpty {
                return true
            }else {
                //If none are specified, it doesn't matter
                if symbol.isEmpty && decimal.isEmpty {
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
//                        let regex = "^([0-9]*)?(\\.)?([0-9]{0,\(decimalPrecision)})?$"
//                        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
//                        return predicate.evaluate(with: newString)
                    }
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
    
    func containSpecialCha(fullStr: String) -> Bool{
        let regex = try? NSRegularExpression(pattern: self.inputLimitPattern!, options: .caseInsensitive)
        if let matches = regex?.matches(in: fullStr, options: [], range: NSMakeRange(0, fullStr.count)) {
            return matches.count > 0
        } else {
            return false
        }
    }
}


class EXComBaseFieldDelegate: NSObject  {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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

