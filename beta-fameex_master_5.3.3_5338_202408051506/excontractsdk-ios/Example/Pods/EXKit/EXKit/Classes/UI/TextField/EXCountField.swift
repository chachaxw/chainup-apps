//
//  EXCountField.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/6.
//  Copyright © 2019 zewu wang. All rights reserved.
//

/*
 self.textfieldValueChangeBlock?(value)
 self.textfieldDidBeginBlock?()
 self.textfieldDidEndBlock?()
 */

import UIKit
import RxSwift
import RxCocoa

public class EXLineGapView:UIView {
    public override func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor.ThemeView.bg
        UIColor.ThemeLabel.colorMedium.setStroke()
        let path = UIBezierPath()
        let startX = rect.size.width/2
        let startY = (rect.size.height - 10)/2
        path.lineWidth = 1.0 // 线条宽度
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: startX, y: startY+10))
        path.stroke()
    }
}

public class EXCountField: EXBaseField {
    public typealias CountBtnBlock = (Bool) -> ()
    public var resendCallback : CountBtnBlock?
    public var isVoice:Bool = false
    public let disBag = DisposeBag()
    public var disposable: Disposable? = nil
    public let countDownStopped = BehaviorRelay<Bool>(value:true)
    public let leftTime :PublishSubject<Int> = PublishSubject.init()
    @IBOutlet public var timeLabel: UILabel!
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet public var baseLine: UIView!
    @IBOutlet public var input: UITextField!
    @IBOutlet public var tapAction: UIButton!
    @IBOutlet public var voiceAction: UIButton!
    @IBOutlet public var gap: EXLineGapView!
    public let style = EXTextFieldStyle.commonStyle
    @IBOutlet public var topMarginConsaint: NSLayoutConstraint!
    private let topMargin:CGFloat = 22
    @IBOutlet public var btnContainer: UIStackView!
    
    public var supportVoiceCode:Bool = false {
        didSet {
            self.handleWithVoiceCode(show: supportVoiceCode)
        }
    }
    
    private var countDownSeconds:Int = 90
    
    fileprivate lazy var presenter : EXTextFieldPresenter = {
        return EXTextFieldPresenter.init(presenter: self)
    }()
    
    public var enableTitleModel:Bool = false {
        didSet {
            self.titleMode(enabled: enableTitleModel)
        }
    }
    
    public func titleMode(enabled:Bool) {
        topMarginConsaint.constant = enabled ? topMargin : 0
    }
    
    private func handleWithVoiceCode(show:Bool) {
        self.voiceAction.isHidden = !show
        gap.isHidden = !show
        if show {
            self.tapAction.setTitle("login_action_sms".localized(), for: .normal)
        }else {
            self.tapAction.setTitle("otc_action_sendmsg".localized(), for: .normal)
        }
    }
    
    @objc public func startApp() {
        
        if countDownStopped.value == true {
            return
        }
        
        if let lastRun = UserDefaults.standard.object(forKey:EXAppNoti.onEnterBgDate) as? Date {
            let diff = Int(Date().timeIntervalSince(lastRun))
            countDownSeconds -= diff
            if countDownSeconds <= 1 {
                countDownStopped.accept(true)
            }else {
                self.continueCount(seconds: countDownSeconds)
            }
        }
    }
    
    @objc public func pauseApp() {
        if countDownStopped.value == true {
            return
        }
        UserDefaults.standard.setValue(Date(), forKey:EXAppNoti.onEnterBgDate)
    }
    
    public override func onCreate() {
        super.onCreate()
        NotificationCenter.default.addObserver(self, selector: #selector(pauseApp), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startApp), name: UIApplication.didBecomeActiveNotification, object: nil)

        self.titleMode(enabled: false)
        
        self.tapAction.setTitleColor(UIColor.ThemeBtn.highlight, for: .normal)
        
        self.voiceAction.setTitle("login_action_voice".localized(), for: .normal)
        self.voiceAction.setTitleColor(UIColor.ThemeBtn.highlight, for: .normal)
        
        self.timeLabel.textColor = UIColor.ThemeLabel.colorMedium
        self.presenter.configWithTextField(input: input)
        Observable.combineLatest(leftTime.asObservable(), countDownStopped.asObservable()) { [weak self]
            leftTimeValue, countDownStoppedValue in
            guard let `self` = self else { return ""}
            
            if countDownStoppedValue {
                self.btnContainer.isHidden = false
                return ""
            }else{
                self.btnContainer.isHidden = true
                if self.supportVoiceCode {
                    if self.isVoice {
                        return "(\(leftTimeValue)s)" + "login_action_voice".localized()
                    }else {
                        return "(\(leftTimeValue)s)" + "login_action_sms".localized()
                    }
                }else {
                    return "(\(leftTimeValue)s)"+"login_action_resendCode".localized()
                }
            }
            }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disBag)
        style.bindHighlight(textField: input, effectView: baseLine)
    }
    
    public override func setPlaceHolder(placeHolder: String , font : CGFloat = 14) {
        input.setPlaceHolderAtt(placeHolder, color: UIColor.ThemeLabel.colorDark, font: font)
    }
    
    public override func setText(text: String) {
        input.text = text
    }
    
    public override func setTitle(title: String) {
        titleLabel.text = title
    }
    //故意出发一次自动点击

    public func justFire() {
        self.tapAction.sendActions(for: .touchUpInside)
    }
    
    @IBAction private func tapActionTap(_ sender: UIButton) {
        self.isVoice = (sender == self.voiceAction)
        self.continueCount(seconds: 90)
        self.startFire()
        self.resendCallback?(isVoice)
        if voiceAction.isHidden {
            self.tapAction.setTitle("login_action_resendCode".localized(), for: .normal)
        }else {
            self.tapAction.setTitle("login_action_sms".localized(), for: .normal)
        }
    }
    
    public func continueCount(seconds:Int) {
        countDownSeconds = seconds
        leftTime.onNext(countDownSeconds)
        countDownStopped.accept(false)
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
    
    public func stopCountDown() {
        self.countDownStopped.accept(true)
    }
    
    deinit {
        self.disposable?.dispose()
    }
}

extension EXCountField : EXTextFieldPresenterProtocol {
    
    public func textValueChanged(value: String) {
        self.textfieldValueChangeBlock?(value)
    }
    
    public func inputDidBeginEditing() {
        self.hideError(input)
        self.textfieldDidBeginBlock?()
    }
    
    public func inputDidEndEditing() {
        self.textfieldDidEndBlock?()
    }
}

extension EXCountField : EXTextFieldConfigurable {
    
    public var baseField: UITextField {
        return self.input
    }
    
    public var baseHighlight: UIView {
        return self.baseLine
    }
}
