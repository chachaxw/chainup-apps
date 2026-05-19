//
//  EXCountField.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

/*
 self.textfieldValueChangeBlock?(value)
 self.textfieldDidBeginBlock?()
 self.textfieldDidEndBlock?()
 */

import UIKit
import RxSwift
import RxCocoa
import EXKit
class EXCountField: EXBaseField {
    
    typealias CountBtnBlock = () -> ()
    var resendCallback : CountBtnBlock?
    
    let disBag = DisposeBag()
    var disposable: Disposable? = nil
    let countDownStopped = BehaviorRelay<Bool>(value:true)
    let leftTime :PublishSubject<Int> = PublishSubject.init()
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var baseLine: UIView!
    @IBOutlet var input: UITextField!
    @IBOutlet var tapAction: RepeatButton!
    let style = EXTextFieldStyle.commonStyle
    @IBOutlet var topMarginConsaint: NSLayoutConstraint!
    private let topMargin:CGFloat = 22

    var seconds:Int = 90 {
        didSet {
           countDownSeconds = seconds
        }
    }
    
    private var countDownSeconds:Int = 90
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    var enableTitleModel:Bool = false {
        didSet {
            self.titleMode(enabled: enableTitleModel)
        }
    }
    
    func titleMode(enabled:Bool) {
        topMarginConsaint.constant = enabled ? topMargin : 0
    }
    
    override func onCreate() {
        super.onCreate()
        self.titleMode(enabled: false)
        self.timeLabel.textColor = UIColor.ThemeLabel.colorHighlight
        self.timeLabel.text = "common_action_getCode".localized()
        self.presenter.configWithTextField(input: input)
        countDownStopped.asDriver().drive(tapAction.rx.isEnabled).disposed(by:disBag)
        Observable.combineLatest(leftTime.asObservable(), countDownStopped.asObservable()) { [weak self]
            leftTimeValue, countDownStoppedValue in
            if countDownStoppedValue {
                self?.timeLabel.textColor = UIColor.ThemeLabel.colorHighlight
                return "login_action_resendCode".localized()
            }else{
                self?.timeLabel.textColor = UIColor.ThemeLabel.colorMedium
                return "(\(leftTimeValue)s)"+"login_action_resendCode".localized()
            }
            }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disBag)
        style.bindHighlight(textField: input, effectView: baseLine)
    }
    
    override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    override func setText(text: String) {
        input.text = text
    }
    
    override func setTitle(title: String) {
        titleLabel.text = title
    }
    //Intentionally depart with one automatic click

    func justFire() {
        self.tapAction.sendActions(for: .touchUpInside)
    }
    
    @IBAction private func tapActionTap(_ sender: UIButton) {
        self.startFire()
        countDownSeconds = 90
        leftTime.onNext(countDownSeconds)
        self.countDownSeconds = self.seconds
        countDownStopped.accept(false)
        self.resendCallback?()
    }
    
    private func startFire() {
        self.disposable?.dispose()
        self.disposable =
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] (element) in
                    guard let `self` = self else { return }
//                    print(element)
                    self.countDownSeconds -= 1
                    self.leftTime.onNext(self.countDownSeconds)
                    if self.countDownSeconds <= 0 {
                        self.disposable?.dispose()
                        self.countDownStopped.accept(true)
                    }
                })
    }
    
    deinit {
        self.disposable?.dispose()
    }
}

extension EXCountField : ExTextFieldProtocol {
    
    func textValueChanged(value: String) {
        self.textfieldValueChangeBlock?(value)
    }
    
    func inputDidBeginEditing() {
        self.hideError(input)
        self.textfieldDidBeginBlock?()
    }
    
    func inputDidEndEditing() {
        self.textfieldDidEndBlock?()
    }
}

extension EXCountField : EXTextFieldConfigurable {
    
    var baseField: UITextField {
        return self.input
    }
    
    var baseHighlight: UIView {
        return self.baseLine
    }
}

