//
//  EXTextFieldStyle.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class EXTextFieldStyle: NSObject {
    
    let disposebg = DisposeBag()
    static let `style` = EXTextFieldStyle()
    open class var commonStyle: EXTextFieldStyle {
        return style
    }
    var highlightColor:UIColor = UIColor.ThemeView.highlight
    
    func bindHighlight(textField:UITextField,effectView:UIView,isBorder:Bool = false) {

        textField.rx.controlEvent(UIControl.Event.editingDidBegin)
            .subscribe(onNext:{[weak self] _ in
                self?.showHilights(on: true, effectView: effectView, borderHighlight: isBorder)
            }).disposed(by: disposebg)
        textField.rx.controlEvent(UIControl.Event.editingDidEnd)
            .subscribe(onNext:{[weak self] _ in
                self?.showHilights(on: false, effectView: effectView, borderHighlight: isBorder)
            }).disposed(by: disposebg)
    }
    
    func showHilights(on:Bool,effectView:UIView,borderHighlight:Bool) {
        if borderHighlight {
            effectView.layer.borderColor = on ? highlightColor.cgColor : UIColor.ThemeView.border.cgColor
        }else {
            effectView.backgroundColor = on ? highlightColor : UIColor.ThemeTextField.seperator
        }
    }

}
