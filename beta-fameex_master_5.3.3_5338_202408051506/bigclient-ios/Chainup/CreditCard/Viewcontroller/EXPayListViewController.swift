//
//  EXPayListViewController.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/28.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
class EXPayListViewController: NavCustomVC {
    var vm = EXCreditCardViewModel()
    var countDownSeconds: Int = 30
    var timer: Timer?
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    //button
    lazy var countDownBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.ext_UseAutoLayout()
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.setTitle("30S", for: .normal)
        btn.addTarget(self, action: #selector(restart), for: .touchUpInside)
        return btn
    }()
    
    //button
    lazy var refreshBtn :RepeatButton = {
        let btn = RepeatButton()
        btn.ext_UseAutoLayout()
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(UIImage.themeImageNamed(imageName:"public_reloads"), for: .normal)
        btn.addTarget(self, action: #selector(restart), for: .touchUpInside)
        return btn
    }()
    lazy var mainView: EXPaylistView = {
        let view = EXPaylistView()
        return view
    }()
    
    override func setNavCustomV() {
        navtype = .listtitle
        self.lastVC = false
        self.setTitle("creditCard_text4".localized())
        refreshBtn.exs_setEnlargeEdgeWithTop(20, left: 30, bottom: 20, right: 20)
        
        self.navCustomView.backView.addSubViews([countDownBtn,refreshBtn])
        refreshBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(16)
            make.height.equalTo(16)
            make.centerY.equalTo(countDownBtn)
        }
        countDownBtn.snp.makeConstraints { make in
            make.right.equalTo(refreshBtn.snp.left)
            make.width.equalTo(30)
            make.height.equalTo(25)
            make.top.equalTo(self.navCustomView.popBtn)
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
            make.left.right.equalToSuperview()
        }
        request()
    }
    func timerCountDown(){
        
        self.countDownSeconds -= 1
        if self.countDownSeconds == 0 {
            self.countDownSeconds = 30
            self.request()
        }
        self.countDownBtn.setTitle("\(self.countDownSeconds)S", for: .normal)
        
        
//        let _ = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler())
//            .subscribe(onNext: { [weak self] (state) in
//                print(state)
//                guard let strong = self else{
//                    return
//                }
//                strong.countDownSeconds -= 1
//                if strong.countDownSeconds == 0 {
//                    strong.countDownSeconds = 30
//                    strong.request()
//                }
//                strong.countDownBtn.setTitle("\(strong.countDownSeconds)S", for: .normal)
//            })
//            .disposed(by: disposeBag)
        
    }
    func request(){
        self.showLoading()
        vm.getServiceList(success: {
            [weak self]  in
            guard let `self` = self else { return }
            self.mainView.vm = self.vm
            
            DispatchQueue.main.async { [self] in
                if self.timer == nil{
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerCountDown), userInfo: nil, repeats: true)
                    self.timer?.fire()
                }
                self.dismissLoading()
            }
        }) {  [weak self]  in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                self.dismissLoading()
            }
        }
    }
    
    func restart(){
        self.countDownSeconds = 30
        self.countDownBtn.setTitle("\(self.countDownSeconds)S", for: .normal)
        request()
    }
}

