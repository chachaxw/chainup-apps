//
//  EXBaseField.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/12.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public enum DecimalType {
    case cny //法币精度
    case coin //币种精度
}


open class EXBaseField: NibBaseView {
    public static var shouldChangeCharactersInBlock:((EXBaseField, UITextField, NSRange, String) -> Bool)?
    open var decimalType:DecimalType = .coin
    open var symbol:String = ""
    open var decimal:String = ""
    open var maxLenth:Int = 32 {
        didSet{
            if maxLenth > 0 {
                self.forceInputLenth = true 
            }
        }
    }  //默认最长32
    open var forceInputLenth:Bool = false
    open var rxhasError = BehaviorRelay<Bool>(value: false)
    open var hasError:Bool {
        get {
            return rxhasError.value
        }
        set {
            rxhasError.accept(newValue)
        }
    }
    
    public typealias TxtFieldDidBeginBlock = () -> ()
    public typealias TxtFieldDidEndBlock = () -> ()
    public typealias TxtFieldValueChanged = (String) -> ()
    open var textfieldDidBeginBlock : TxtFieldDidBeginBlock?
    open var textfieldDidEndBlock : TxtFieldDidEndBlock?
    open var textfieldValueChangeBlock : TxtFieldValueChanged?
    open var shouldBeginEditingBlock: ((UITextField) -> Bool)?
    open func setPlaceHolder(placeHolder:String , font : CGFloat) {}
    open func setText(text:String) {}
    open func setTitle(title:String) {}
    
//    func showError(){}
//    func hideError(){}
//    
    
    open override func onCreate() {
        self.backgroundColor = UIColor.ThemeView.bg
        self.rxhasError.asObservable()
        .subscribe(onNext: { [weak self] error in
            guard self != nil else { return }
            if error {
//                self.showError()
            }
        }).disposed(by: self.disposeBag)
    }
    
    
    open func hideError(_ textField:UITextField) {
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
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let shouldBeginEditingBlock = shouldBeginEditingBlock { return shouldBeginEditingBlock(textField) }
        return true
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let block = EXBaseField.shouldChangeCharactersInBlock {
            return block(self,textField,range,string)
        }
        return true
    }
}
