//
//  EXTextFieldPresenter.swift
//  Chainup
//
//  Created by liuxuan on2020/3/12.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit
import RxSwift

// 设置颜色
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
        self.baseField.sendActions(for: .valueChanged)
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

public protocol EXTextFieldPresenterProtocol {
    func textValueChanged(value:String)
    func inputDidBeginEditing()
    func inputDidEndEditing()
}

public class EXTextFieldPresenter: NSObject {
    public var presenter: EXTextFieldPresenterProtocol!
    public let disposebg = DisposeBag()
    public init(presenter:EXTextFieldPresenterProtocol) {
        self.presenter = presenter;
    }
    
    public func configWithTextField(input:UITextField) {
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
