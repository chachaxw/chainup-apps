//
//  EXCountTextField.swift
//  EXKit
//
//  Created by bradjohn on 2024/5/15.
//

import UIKit
import RxSwift
import RxCocoa

public class EXCountTextField: EXBasicTextField {
    
    public var resendCallback : ((Bool) -> ())?
    
    public var isVoice:Bool = false
    
    public let disBag = DisposeBag()
    
    public var disposable: Disposable? = nil
    
    public let countDownStopped = BehaviorRelay<Bool>(value:true)
    
    public let leftTime:PublishSubject<Int> = PublishSubject.init()
    
    public var supportVoiceCode:Bool = false {
        didSet {
            self.handleWithVoiceCode(show: supportVoiceCode)
        }
    }
    
    public var countDownSeconds:Int = 90
    
    public override var contentInset: UIEdgeInsets {
        didSet {
            guard currentContentView.superview != nil else { return }
            currentContentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInset) }
        }
    }
    
    lazy var timeLabel: UILabel = {
        let v = UILabel(font: .Ex.medium(14), textColor: .Ex.text2)
        v.isHidden = true
        return v
    }()
    
    lazy var codeButton: EXButton = {
        let v = EXButton()
        v.selectStyle = .blueTextColor
        v.setTitle("common_action_paste".localized(), for: .normal)
        v.setTitleColor(.Ex.text2, for: .disabled)
        return v
    }()
    
    lazy var voiceButton: EXButton = {
        let v = EXButton()
        v.selectStyle = .blueTextColor
        v.setTitle("login_action_voice".localized(), for: .normal)
        v.setTitleColor(.Ex.text2, for: .disabled)
        return v
    }()
    
    private lazy var currentContentView: UIView = {
        let v = UIView()
        v.extUseAutoLayout()
        v.setContentHuggingPriority(.required, for: .horizontal)
        return v
    }()
    
    private lazy var rightButtonView: EXStackView = {
        let v = EXStackView()
        v.separatorConfiguration = .init(color: .Ex.fill4, width: 0.5, height: 14)
        v.axis = .horizontal
        v.spacing = 8
        v.distribution = .fill
        v.alignment = .center
        return v
    }()
    
    private lazy var rightView: EXStackView = {
        let v = EXStackView()
        v.separatorConfiguration = .init(color: .Ex.fill4, width: 0.5, height: 14)
        v.axis = .horizontal
        v.spacing = 8
        v.distribution = .fill
        v.alignment = .center
        return v
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
        onBindViewModel()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
        onBindViewModel()
    }
    
    func onCreate() {
        contentView.snp.removeConstraints()
        addSubview(currentContentView)
        currentContentView.addSubViews([contentView, rightView])
        rightView.addArrangedSubviews([timeLabel, rightButtonView])
        rightButtonView.addArrangedSubviews([codeButton, voiceButton])
        ///
        currentContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentInset)
        }
        ///
        contentView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        rightView.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.right).offset(8)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        ///
        contentView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        rightView.setContentHuggingPriority(.required, for: .horizontal)
        rightView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        rightButtonView.setContentHuggingPriority(.required, for: .horizontal)
        rightButtonView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        voiceButton.setContentHuggingPriority(.required, for: .horizontal)
        voiceButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        codeButton.setContentHuggingPriority(.required, for: .horizontal)
        codeButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    func onBindViewModel() {
        codeButton.rx.controlEvent(.touchUpInside)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] v in
                guard let self else { return }
                self.tapActionTap(voice: true)
            }).disposed(by: disBag)
        
        voiceButton.rx.controlEvent(.touchUpInside)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self else { return }
                self.tapActionTap(voice: true)
            }).disposed(by: disBag)
        
        Observable.combineLatest(leftTime.asObserver(), countDownStopped.asObservable()).map { [weak self] (leftTimeValue, isStopped) in
            guard let self else { return "" }
            if isStopped {
                self.timeLabel.isHidden = true
                self.rightButtonView.isHidden = false
                return String(leftTimeValue)
            } else {
                self.timeLabel.isHidden = false
                self.rightButtonView.isHidden = true
                if self.supportVoiceCode {
                    if self.isVoice {
                        return "(\(leftTimeValue)s)" + "login_action_voice".localized()
                    }else {
                        return "(\(leftTimeValue)s)" + "login_action_sms".localized()
                    }
                } else {
                    return "(\(leftTimeValue)s)"+"login_action_resendCode".localized()
                }
            }
        }.bind(to: timeLabel.rx.text).disposed(by: disBag)
    }
    
    private func handleWithVoiceCode(show:Bool) {
        self.voiceButton.isHidden = !show
        if show {
            self.codeButton.setTitle("login_action_sms".localized(), for: .normal)
        }else {
            self.codeButton.setTitle("otc_action_sendmsg".localized(), for: .normal)
        }
    }
    
    private func tapActionTap(voice: Bool) {
        self.isVoice = voice
        self.continueCount(seconds: countDownSeconds)
        self.startFire()
        self.resendCallback?(isVoice)
        if voiceButton.isHidden {
            self.codeButton.setTitle("login_action_resendCode".localized(), for: .normal)
        }else {
            self.codeButton.setTitle("login_action_sms".localized(), for: .normal)
        }
    }
    
    private func startFire() {
        self.disposable?.dispose()
        self.disposable =
        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (element) in
                guard let self else { return }
                self.countDownSeconds -= 1
                self.leftTime.onNext(self.countDownSeconds)
                if self.countDownSeconds <= 0 {
                    self.disposable?.dispose()
                    self.countDownStopped.accept(true)
                }
            })
    }
    
    public func justFire() {
        self.codeButton.sendActions(for: .touchUpInside)
    }
    
    public func continueCount(seconds:Int) {
        countDownSeconds = seconds
        leftTime.onNext(countDownSeconds)
        countDownStopped.accept(false)
    }
    
    public func stopCountDown() {
        self.countDownStopped.accept(true)
    }
    
    deinit {
        self.disposable?.dispose()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
