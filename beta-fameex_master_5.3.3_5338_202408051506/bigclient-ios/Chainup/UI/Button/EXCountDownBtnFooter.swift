//
//  EXCountDownBtnFooter.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit



class EXCountDownBtnFooter: NibBaseView {
    
    @IBOutlet var leftBtnWidth: NSLayoutConstraint!
    @IBOutlet var leftBtn: EXButton!
    @IBOutlet var rightBtn: EXButton!
    @IBOutlet var btnStackView: UIStackView!
    let disBag = DisposeBag()
    var disposable: Disposable? = nil
    
    let countDownStopped = BehaviorRelay<Bool>(value:false)
    let leftTime :PublishSubject<Int> = PublishSubject.init()
    
    typealias RightBtnDidTapCallback = () -> ()
    var rightBtnCallback : RightBtnDidTapCallback?
    typealias LeftBtnDidTapCallback = () -> ()
    var leftBtnCallback : LeftBtnDidTapCallback?
    
    var countTime:Int = 60 {
        didSet {
            countDownSeconds = countTime
        }
    }
    
    private var countDownSeconds:Int = 60
    
    func setSingleBtnStyle() {
        btnStackView.removeArrangedSubview(leftBtn)
    }
    
    func setSigleBtn(title:String,titleColor:UIColor = UIColor.ThemeLabel.white) {
        rightBtn.setTitle(title, for: .normal)
    }

    override func onCreate() {
        leftBtn.color = UIColor.ThemeView.bgTab
        leftBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        leftTime.map{ timeInterval in
            let date = DateTools.stringToHourMinSec("\(timeInterval)")
            if date.1 > 0 {
                return "\(date.1)'" + "\(date.2)''" + "oct_action_autoCancelDesc".localized()

            }else{
                return  "\(date.2)s " + "oct_action_autoCancelDesc".localized()
            }
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
    
    func setTitle(left:String,right:String) {
        leftBtn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        rightBtn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        leftBtn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .disabled)
        leftBtn.setTitle(left, for: .normal)
        rightBtn.setTitle(right, for: .normal)
    }
    
    func startFire() {
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
    
    func stopCounting() {
        self.disposable?.dispose()
    }


}
