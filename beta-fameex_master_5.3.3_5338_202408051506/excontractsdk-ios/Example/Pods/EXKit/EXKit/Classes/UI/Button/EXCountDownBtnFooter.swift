//
//  EXCountDownBtnFooter.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/28.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class EXCountDownBtnFooter: NibBaseView {
    @IBOutlet public var leftBtnWidth: NSLayoutConstraint!
    @IBOutlet public var leftBtn: EXButton!
    @IBOutlet public var rightBtn: EXButton!
    @IBOutlet public var btnStackView: UIStackView!
    
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
    
    public func setSingleBtnStyle() {
        btnStackView.removeArrangedSubview(leftBtn)
    }
    
    public func setSigleBtn(title:String,titleColor:UIColor = UIColor.ThemeLabel.white) {
        rightBtn.setTitle(title, for: .normal)
    }

    public override func onCreate() {
        leftBtn.color = UIColor.ThemeView.bgTab
        leftBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        leftTime.map{ timeInterval in
            let date = DateTools.stringToHourMinSec("\(timeInterval)")
            return "oct_action_autoCancelDesc".localized() + " " + "\(date.1)'" + "\(date.2)''"
            }
        .bind(to: leftBtn.rx.title(for: .normal))
        .disposed(by: disBag)
//        self.startFire()
        rightBtn.rx.tap.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.rightBtnCallback?()
            }).disposed(by: disBag)
        
        leftBtn.rx.tap.asObservable()
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.leftBtnCallback?()
            }).disposed(by: disBag)
    }
    
    public func setTitle(left:String,right:String) {
        leftBtn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        rightBtn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        leftBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .disabled)
        leftBtn.setTitle(left, for: .normal)
        rightBtn.setTitle(right, for: .normal)
    }
    
    public func startFire() {
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
    
    public func stopCounting() {
        self.disposable?.dispose()
    }


}
