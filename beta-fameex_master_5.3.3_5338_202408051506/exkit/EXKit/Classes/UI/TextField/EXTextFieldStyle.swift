//
//  EXTextFieldStyle.swift
//  Chainup
//
//  Created by liuxuan on2020/3/12.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

public class EXTextFieldStyle: NSObject {
    
    public let disposebg = DisposeBag()
    public static let `style` = EXTextFieldStyle()
    open class var commonStyle: EXTextFieldStyle {
        return style
    }
    public var highlightColor:UIColor = UIColor.ThemeView.highlight {
        didSet {
            if highlightColor.rgbString == "D1425E" {
                print("")
            }
        }
    }
    public var normalBorderColor:UIColor = UIColor.ThemeView.border
    
    public func bindHighlight(textField:UITextField,effectView:UIView,isBorder:Bool = false) {

        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext:{[weak self] _ in
                self?.showHilights(on: true, effectView: effectView, borderHighlight: isBorder)
            }).disposed(by: disposebg)
        textField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext:{[weak self] _ in
                self?.showHilights(on: false, effectView: effectView, borderHighlight: isBorder)
            }).disposed(by: disposebg)
    }
    
    public func showHilights(on:Bool,effectView:UIView,borderHighlight:Bool) {
        if borderHighlight {
            effectView.layer.borderColor = on ? highlightColor.cgColor : normalBorderColor.cgColor
        }else {
            effectView.backgroundColor = on ? highlightColor : UIColor.ThemeTextField.seperator
        }
    }

}
