//
//  EXCountDownBtnFooter.swift
//  Chainup
//
//  Created by liuxuan on2020/3/28.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class EXCountDownBtnFooter: UIView {
    
    public let disBag = DisposeBag()
    
    public var disposable: Disposable? = nil
    
    public let countDownStopped = BehaviorRelay<Bool>(value:false)
    
    public let leftTime :PublishSubject<Int> = PublishSubject.init()
    
    public typealias RightBtnDidTapCallback = () -> ()
    
    public var rightBtnCallback : RightBtnDidTapCallback?
    
    public typealias LeftBtnDidTapCallback = () -> ()
    
    public var leftBtnCallback : LeftBtnDidTapCallback?
    
    public var countTime:Int = 60 {
        didSet {
            countDownSeconds = countTime
        }
    }
    
    private var countDownSeconds:Int = 60
    
    public lazy var leftBtn: EXButton = {
        let v = EXButton(type: .custom)
        v.setTitleColor(.Ex.text1, for: .normal)
        v.color = UIColor.ThemeView.bgTab
        v.titleLabel?.font = .Ex.medium(14)
        return v
    }()
    
    public lazy var rightBtn: EXButton = {
        let v = EXButton(type: .custom)
        v.titleLabel?.font = .Ex.medium(14)
        v.setTitleColor(.Ex.text2, for: .disabled)
        return v
    }()
    
    public lazy var btnStackView: EXStackView = {
        let v = EXStackView()
        v.separatorConfiguration = nil
        v.spacing = 12
        v.axis = .horizontal
        v.distribution = .fillEqually
        return v
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
        onBindViewModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
        onBindViewModel()
    }
    
    func onCreate() {
        addSubViews([btnStackView])
        btnStackView.addArrangedSubviews([leftBtn, rightBtn])
        ///
        btnStackView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    func onBindViewModel() {
        leftTime.map{ timeInterval in
            let date = DateTools.stringToHourMinSec("\(timeInterval)")
            return "\(date.0 * 60 * 60 + date.1 * 60 + date.2)s" + " " + "oct_action_autoCancelDesc".localized()
        }
        .bind(to: leftBtn.rx.title(for: .normal))
        .disposed(by: disBag)
        
        rightBtn.rx.tap.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.rightBtnCallback?()
            }).disposed(by: disBag)
        
        leftBtn.rx.tap.asObservable().throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.leftBtnCallback?()
            }).disposed(by: disBag)
    }
    
    public func setSingleBtnStyle() {
        btnStackView.removeArrangedSubview(leftBtn)
    }
    
    public func setSigleBtn(title:String,titleColor:UIColor = .Ex.text2) {
        rightBtn.setTitle(title, for: .normal)
    }
    
    public func setTitle(left:String,right:String) {
        leftBtn.setTitle(left, for: .normal)
        rightBtn.setTitle(right, for: .normal)
    }
    
    public func startFire() {
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
    
    public func stopCounting() {
        self.disposable?.dispose()
    }
    
    public func resetCountSeconds(seconds: Int = 60) {
        countDownSeconds = seconds
    }
    
    
}
