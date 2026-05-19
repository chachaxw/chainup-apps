//
//  EXTextFieldPresenter.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

//Set Color
public protocol EXTextFieldConfigurable {
    var baseField: UITextField { get }
    var baseHighlight: UIView { get }
    func configPlaceHolder(placeHolder:String)
    func configText(text:String)
    func showError()
}

public extension EXTextFieldConfigurable where Self:UIView {
    
    func configPlaceHolder(placeHolder:String) {
        self.baseField.setPlaceHolderAtt(placeHolder)
    }
    
    func configText(text:String) {
        self.baseField.text = text
        self.baseField.sendActions(for: UIControl.Event.valueChanged)
    }
    
    func currentTxtField()->UITextField {
        return self.baseField
    }
    
    func showError(){
        self.baseHighlight.backgroundColor = UIColor.ThemeState.fail
        if let placeHolder = self.baseField.placeholder {
            self.baseField.setPlaceHolderAtt(placeHolder,color:UIColor.ThemeState.fail)
        }
    }
}

protocol ExTextFieldProtocol {
    func textValueChanged(value:String)
    func inputDidBeginEditing()
    func inputDidEndEditing()
}

class EXTextFieldPresenter: NSObject {
    var presenter: ExTextFieldProtocol!
    let disposebg = DisposeBag()
    init(presenter:ExTextFieldProtocol) {
        self.presenter = presenter;
    }
    
    func configWithTextField(input:UITextField) {
        input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] text in
                self?.presenter.textValueChanged(value:text)
            }).disposed(by: disposebg)
        
        input.rx.controlEvent(UIControl.Event.editingDidBegin)
            .subscribe(onNext:{[weak self] _ in
                self?.presenter.inputDidBeginEditing()
            }).disposed(by: disposebg)
        
        input.rx.controlEvent(UIControl.Event.editingDidEnd)
            .subscribe(onNext:{[weak self] _ in
                self?.presenter.inputDidEndEditing()
            }).disposed(by: disposebg)
    }
}

