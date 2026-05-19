//
//  EXTextFieldStyle.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

class EXSTextFieldStyle: NSObject {
    
    let disposebg = DisposeBag()
    static let `style` = EXSTextFieldStyle()
    open class var commonStyle: EXSTextFieldStyle {
        return style
    }
    func bindHighlight(textField:UITextField,effectView:UIView,isBorder:Bool = false) {

        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext:{[weak self] _ in
                self?.showHilights(on: true, effectView: effectView, borderHighlight: isBorder)
            }).disposed(by: disposebg)
        
        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext:{[weak self] _ in
                self?.showHilights(on: false, effectView: effectView, borderHighlight: isBorder)
            }).disposed(by: disposebg)
    }
    
    func showHilights(on:Bool,effectView:UIView,borderHighlight:Bool) {
        if borderHighlight {
            effectView.layer.borderColor = on ? UIColor.ThemeView.highlight.cgColor : UIColor.ThemeView.bgIcon.cgColor
        }else {
            effectView.backgroundColor = on ? UIColor.ThemeView.highlight : UIColor.ThemeTextField.seperator
        }
    }

}
