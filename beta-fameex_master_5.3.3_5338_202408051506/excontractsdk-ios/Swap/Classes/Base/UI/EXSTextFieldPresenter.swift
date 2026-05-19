//
//  EXTextFieldPresenter.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

// 设置颜色 English: Set Color
public protocol EXSTextFieldConfigurable {
    var baseField: UITextField { get }
    var baseHighlight: UIView { get }
    func configPlaceHolder(placeHolder:String)
    func configText(text:String)
    func showError()
}

public extension EXSTextFieldConfigurable where Self:UIView {
    
    func configPlaceHolder(placeHolder:String) {
        self.baseField.exs_setPlaceHolderAtt(placeHolder)
    }
    
    func configText(text:String) {
        self.baseField.text = text
        self.baseField.sendActions(for: .valueChanged)
    }
    
    func currentTxtField()->UITextField {
        return self.baseField
    }
    
    func showError(){
        self.baseHighlight.backgroundColor = UIColor.ThemeState.fail
        if let placeHolder = self.baseField.placeholder {
            self.baseField.exs_setPlaceHolderAtt(placeHolder,color:UIColor.ThemeState.fail)
        }
    }
}

protocol EXSTextFieldProtocol {
    func textValueChanged(value:String)
    func inputDidBeginEditing()
    func inputDidEndEditing()
}

class EXSTextFieldPresenter: NSObject {
    var presenter: EXSTextFieldProtocol!
    var vailded: Observable<Bool>!
    let disposebg = DisposeBag()
    init(presenter:EXSTextFieldProtocol) {
        self.presenter = presenter;
    }
    
    func configWithTextField(input:UITextField) {
        vailded = input.rx.text.orEmpty.asObservable()
            .map {
                let pass = $0.count > 0
                input.rightView?.isHidden = !pass
                return pass
            }
        input.rx.text.orEmpty.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] text in
                self?.presenter.textValueChanged(value:text)
            }).disposed(by: disposebg)
        
        input.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext:{[weak self] _ in
                self?.presenter.inputDidBeginEditing()
            }).disposed(by: disposebg)
        
        input.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext:{[weak self] _ in
                self?.presenter.inputDidEndEditing()
            }).disposed(by: disposebg)
    }
}

