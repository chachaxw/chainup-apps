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


//enum DecimalType {
//    case cny //法币精度 English: Fiat currency accuracy
//    case coin //币种精度 English: Currency accuracy
//}


class EXSBaseField: EXSNibBaseView {
//    var decimalType:DecimalType = .coin
    var symbol:String = ""
    var decimal:String = ""
    var maxLenth:Int = 32 //默认最长32 English: Default maximum length of 32
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
        }).disposed(by: self.exs_disposeBag)
        
       
    }
    
    func hideError(_ textField:UITextField) {
        if let placeHolder = textField.placeholder {
            
            textField.exs_setPlaceHolderAtt(placeHolder)
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

extension EXSBaseField : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.keyboardType == .numberPad ||
            textField.keyboardType == .decimalPad {
            let nsString = textField.text as NSString?
            let newString = nsString? .replacingCharacters(in: range, with: string)
            
            if let newStr = newString {
                //超长处理，其他往下走逻辑 English: Extra long processing, other downstream logic
                if newStr.count > maxLenth {
                    return false
                }
            }
            
//            if textField.keyboardType == .numberPad{
//                if BusinessTools.number(newString ?? ""){
//                    return true
//                }else{
//                    EXAlert.showFail(msg: "userinfo_tip_inputPhone".ex_localized())
//                    return false
//                }
//            }
            
            if string.isEmpty {
                return true
            }else {
                //如果都没指定,都不管 English: If none of them are specified, it doesn't matter
                if symbol.isEmpty && decimal.isEmpty {
                    return true
                }else {
                    guard let inputStr = newString else {
                        return false
                    }
                    return inputStr.isValidInputAmount(decimal: 8)
                }
            }
        }else {
            if forceInputLenth {
                let nsString = textField.text as NSString?
                let newString = nsString? .replacingCharacters(in: range, with: string)
                
                if let newStr = newString {
                    //超长处理，其他往下走逻辑 English: Extra long processing, other downstream logic
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



///--------
class EXSNewBaseField: EXCOCustomBaseView {
//    var decimalType:DecimalType = .coin
    var symbol:String = ""
    var decimal:String = ""
    var maxLenth:Int = 32 //默认最长32 English: Default maximum length of 32
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
    
    override func setSubView() {
        
        self.backgroundColor = UIColor.ThemeView.bg
        self.rxhasError.asObservable()
        .subscribe(onNext: { [weak self] error in
            guard self != nil else { return }
            if error {
//                self.showError()
            }
        }).disposed(by: self.exs_disposeBag)
        
       
    }
    
    func hideError(_ textField:UITextField) {
        if let placeHolder = textField.placeholder {
            
            textField.exs_setPlaceHolderAtt(placeHolder)
        }
    }
}
extension EXSNewBaseField : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.keyboardType == .numberPad ||
            textField.keyboardType == .decimalPad {
            let nsString = textField.text as NSString?
            let newString = nsString? .replacingCharacters(in: range, with: string)
            
            if let newStr = newString {
                //超长处理，其他往下走逻辑 English: Extra long processing, other downstream logic
                if newStr.count > maxLenth {
                    return false
                }
            }
            
//            if textField.keyboardType == .numberPad{
//                if BusinessTools.number(newString ?? ""){
//                    return true
//                }else{
//                    EXAlert.showFail(msg: "userinfo_tip_inputPhone".ex_localized())
//                    return false
//                }
//            }
            
            if string.isEmpty {
                return true
            }else {
                //如果都没指定,都不管 English: If none of them are specified, it doesn't matter
                if symbol.isEmpty && decimal.isEmpty {
                    return true
                }else {
                    guard let inputStr = newString else {
                        return false
                    }
                    return inputStr.isValidInputAmount(decimal: 8)
                }
            }
        }else {
            if forceInputLenth {
                let nsString = textField.text as NSString?
                let newString = nsString? .replacingCharacters(in: range, with: string)
                
                if let newStr = newString {
                    //超长处理，其他往下走逻辑 English: Extra long processing, other downstream logic
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



