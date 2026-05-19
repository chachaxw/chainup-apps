//
//  SkeletonViewController.swift
//  EXKit_Example
//
//  Created by youbin on 2023/6/19.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import EXKit



class SkeletonViewController: UIViewController {
    
    lazy var homeV: EXSkeletonHomeView = {
        let v = EXSkeletonHomeView()
        v.isHidden = false
        v.isAux2 = true
        return v
    }()
    
    lazy var marketV: EXSkeletonMarketView = {
        let v = EXSkeletonMarketView()
        v.isHidden = true
        return v
    }()
    
    lazy var tradingV: EXSkeletonTradingView = {
        let v = EXSkeletonTradingView()
        v.isHidden = true
        return v
    }()
    
    lazy var contractV: EXSkeletonContractView = {
        let v = EXSkeletonContractView()
        v.isHidden = true
        return v
    }()
    
    lazy var profileV: EXSkeletonProfileView = {
        let v = EXSkeletonProfileView()
        v.isHidden = true
        return v
    }()
    
    lazy var assetsV: EXSkeletonAssetsView = {
        let v = EXSkeletonAssetsView()
        v.isHidden = true
        return v
    }()
    
    lazy var assetsVFive: EXSkeletonAssetsViewFive = {
        let v = EXSkeletonAssetsViewFive()
        v.isHidden = true
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = .Ex.fill1
        
        // Do any additional setup after loading the view.
        
        createUI()
        buttonsUI()
    }
    
    
    
    
    func createUI() {
        
        home()

        market()

        trading()

        contract()

        assets()
        
        profile()
        
    }
    
    
    func buttonsUI() {
        ///
        let home = EXButton(buttonType: .custom, title: "home", titleFont: .Ex.Harmony(size: 10, weight: .medium), titleColor: .Ex.text1)
        view.addSubview(home)
        home.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(128)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        home.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.homeV.isHidden = false
            self.marketV.isHidden = true
            self.tradingV.isHidden = true
            self.contractV.isHidden = true
            self.assetsV.isHidden = true
            self.assetsVFive.isHidden = true
            self.profileV.isHidden = true
        }).disposed(by: disposeBag)
        
        ///
        let market = EXButton(buttonType: .custom, title: "market", titleFont: .Ex.Harmony(size: 10, weight: .medium), titleColor: .Ex.text1)
        view.addSubview(market)
        market.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(home.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        market.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.homeV.isHidden = true
            self.marketV.isHidden = false
            self.tradingV.isHidden = true
            self.contractV.isHidden = true
            self.assetsV.isHidden = true
            self.assetsVFive.isHidden = true
            self.profileV.isHidden = true
        }).disposed(by: disposeBag)
        
        ///
        let trading = EXButton(buttonType: .custom, title: "trading", titleFont: .Ex.Harmony(size: 10, weight: .medium), titleColor: .Ex.text1)
        view.addSubview(trading)
        trading.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(market.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        trading.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.homeV.isHidden = true
            self.marketV.isHidden = true
            self.tradingV.isHidden = false
            self.contractV.isHidden = true
            self.assetsV.isHidden = true
            self.assetsVFive.isHidden = true
            self.profileV.isHidden = true
        }).disposed(by: disposeBag)
        
        ///
        let contract = EXButton(buttonType: .custom, title: "contract", titleFont: .Ex.Harmony(size: 10, weight: .medium), titleColor: .Ex.text1)
        view.addSubview(contract)
        contract.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(trading.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        contract.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.homeV.isHidden = true
            self.marketV.isHidden = true
            self.tradingV.isHidden = true
            self.contractV.isHidden = false
            self.assetsV.isHidden = true
            self.assetsVFive.isHidden = true
            self.profileV.isHidden = true
        }).disposed(by: disposeBag)
        
        ///
        let profile = EXButton(buttonType: .custom, title: "profile", titleFont: .Ex.Harmony(size: 10, weight: .medium), titleColor: .Ex.text1)
        view.addSubview(profile)
        profile.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(contract.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        profile.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.homeV.isHidden = true
            self.marketV.isHidden = true
            self.tradingV.isHidden = true
            self.contractV.isHidden = true
            self.assetsV.isHidden = true
            self.assetsVFive.isHidden = true
            self.profileV.isHidden = false
        }).disposed(by: disposeBag)
         
        ///
        let assets = EXButton(buttonType: .custom, title: "assets", titleFont: .Ex.Harmony(size: 10, weight: .medium), titleColor: .Ex.text1)
        view.addSubview(assets)
        assets.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(profile.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        assets.rx.controlEvent(.touchUpInside).subscribe(onNext: {[weak self] _ in
            guard let self = self else { return }
            self.homeV.isHidden = true
            self.marketV.isHidden = true
            self.tradingV.isHidden = true
            self.contractV.isHidden = true
            self.assetsV.isHidden = false
            self.assetsVFive.isHidden = false
            self.profileV.isHidden = true
        }).disposed(by: disposeBag)
        
    
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension SkeletonViewController {
    
    func home() {
        let v = self.homeV
        view.addSubview(v)
        v.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func market() {
        let v = self.marketV
        view.addSubview(v)
        v.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(88)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    
    func trading() {
        let v = self.tradingV
        view.addSubview(v)
        v.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(88)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func contract() {
        let v = self.contractV
        view.addSubview(v)
        v.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func assets() {
//        let v = self.assetsV
        let v = self.assetsVFive;
        view.addSubview(v)
        v.snp.makeConstraints { make in
            make.top.top.equalToSuperview().offset(88)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func profile() {
        let v = self.profileV
        view.addSubview(v)
        v.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(88)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    
}




