//
//  xController.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EXKit
class EXQuickBuyCoinViewController: NavCustomVC {
//    deinit{
//Print ("====Destroyed ---")
//    }
    var vm = EXCreditCardViewModel()
    //MARK: lazy
    lazy var mainView: EXQuickBuyCoinVIew = {
        let view = EXQuickBuyCoinVIew(viewModel: vm)
        view.buyBlock = { [weak self] in
            guard let strong = self else{
                return
            }
            //If not logged in, do not redirect
            if XUserDefault.getToken() == nil{
                BusinessTools.modalLoginVC()
                return
            }
            let v = EXPayListViewController()
            v.vm = strong.vm
            strong.navigationController?.pushViewController(v, animated: true)
        }
        view.midlleImg.changeCallBack = { [weak self] in
            guard let `self` = self else { return }
            
            if self.vm.isBuy { //go sell
                if let configSellData = self.vm.configSellData,configSellData.open == false{
                    self.quickTradeCloseTip(isBuy: false)
                    return
                }
            }else{//go buy
                if let configBuyData = self.vm.configBuyData,configBuyData.open == false{
                    self.quickTradeCloseTip(isBuy: true)
                    return
                }
            }
                
            self.mainView.buyBtn.isEnabled = false
            if let configBuyData = self.vm.configBuyData,configBuyData.open == false{
                self.vm.isBuy = !self.vm.isBuy
                self.vm.setCoinData(isBuy: false)
                self.mainView.reloadView()
            }else{
                self.vm.changeBuySell()
            }
            self.vm.getAavialAmount()
            self.showLoading()
            self.vm.getRateList()
        }
        view.send.actionblock = { [weak self] in
            guard let `self` = self else { return }
            self.goToSelectCoin(isFait: self.vm.isBuy,topSend: true)
        }
        view.recieve.actionblock = { [weak self] in
            guard let `self` = self else { return }
            self.goToSelectCoin(isFait: !self.vm.isBuy,topSend: false)
        }
        return view
    }()
    
    //button
    lazy var refreshBtn : RepeatButton = {
        let btn = RepeatButton()
        btn.ext_UseAutoLayout()
        btn.setTitle("order_records".localized(), for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.addTarget(self, action: #selector(goOrderList), for: .touchUpInside)
        return btn
    }()
    
     //MARK: lifecycle
    override func setNavCustomV() {
        navtype = .listtitle
        self.lastVC = false
        self.setTitle("creditCard_text0".localized())
        self.navCustomView.setRightModule([refreshBtn], rightSize :(80,19),alignPopBtn: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    
    func configUI(){
        self.view.backgroundColor = .Ex.fill2
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM)
            make.left.right.equalToSuperview()
        }
    }
    
    func configData(){
        if XUserDefault.isOffLine() == false{
            self.showLoading()
            self.vm.getHomeData()
        }
        
        vm.requestEnd.subscribe(onNext: { [weak self] status in
            guard let `self` = self else { return }
            DispatchQueue.main.async { [self] in
                self.dismissLoading()
                
                if self.vm.isBuy {
                    if let configBuyData = self.vm.configBuyData,configBuyData.open == false{
                            self.quickTradeCloseTip(isBuy: true)
                        }
                    }
                }
                
            
        }).disposed(by: self.disposeBag)
    }
    
    
    
    func quickTradeCloseTip(isBuy: Bool){
        let content = isBuy ? "quick_buy_no_buy".localized() : "quick_buy_no_sell".localized()
        let alert = EXCommonAlert()
        alert.configAlert(title:"dialog_tip_title".localized(), message:content,
                          onlyOneBtnTitle: "guide_3".localized(), bottomOnlyOneBtn: true) { _ in
            EXAlert.dismiss()
        }
        EXAlert.showAlert(alertView: alert)
    }
    
    
    //MARK: customMethod
    func goOrderList(){
        let vc = EXCrditCardPayHistoryViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func goToSelectCoin(isFait: Bool, topSend: Bool) {
        let v = EXSelectCoinViewController()
        
        self.view.endEditing(true)
        let coinList = self.vm.isBuy ? vm.configBuyData?.coin_list : vm.configSellData?.coin_list
        let faitList = self.vm.isBuy ? vm.configBuyData?.fiat_list : vm.configSellData?.fiat_list
        guard coinList != nil else{
            return
        }
        let list = isFait ? faitList : coinList
        v.coinList = list
        v.selectCoinBlock = { [weak self] coin in
            guard let `self` = self else { return }
            var newCoin = coin
            newCoin.isFiat = isFait
            if topSend {
                self.vm.payCoin = newCoin
            }else{
                self.vm.recieveCoin = newCoin
            }
            self.vm.clearData()
            self.mainView.reloadView()
            self.vm.getAavialAmount()
            self.showLoading()
            self.vm.getRateList()
        }
        self.navigationController?.pushViewController(v, animated: true)
    }
}

