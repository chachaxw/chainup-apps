//
//  EXOTCOrderNewVc.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/28.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit


class EXOTCOrderDetailVC: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var footerToolBar: EXCountDownBtnFooter!
    var orderInfoCard: EXOTCOrderInfoCard = EXOTCOrderInfoCard()
    var payInfoCard: EXOTCPayInfoCard = EXOTCPayInfoCard()
    let gapView:UIView = UIView()
    let modelConfiger = EXOrderInfoModelFactory()
    
    func configOrderSubviews(){
        scrollView.addSubview(orderInfoCard)
        gapView.backgroundColor = UIColor.ThemeView.bgGap
        scrollView.addSubview(gapView)
        scrollView.addSubview(payInfoCard)
        orderInfoCard.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(200)
        }
        gapView.snp.makeConstraints { (make) in
            make.top.equalTo(orderInfoCard.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(10)
        }
        
        payInfoCard.snp.makeConstraints { (make) in
            make.top.equalTo(gapView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(155)
            make.bottom.greaterThanOrEqualTo(-74)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configOrderSubviews()
        self.handleOrderNewInfos()
        self.handleFooterBar()
    }
    
    func handleOrderNewInfos() {
        let infoModels = modelConfiger.getDefaultInfoModels(currency: "CNY", coinSymbol: "USDT")
        let payinfoModels = modelConfiger.getPayInfoModels(byPayType: .UnionPay)

        let fullHeight = EXOTCOrderInfoCard.fullHeightWithModels(models: infoModels)
        let payHeight = EXOTCOrderInfoCard.fullHeightWithModels(models: payinfoModels)

        orderInfoCard.snp.updateConstraints { (make) in
            make.height.equalTo(fullHeight)
        }
        payInfoCard.snp.updateConstraints { (make) in
            make.height.equalTo(payHeight)
        }
        orderInfoCard.updateInfos(models:infoModels)
        payInfoCard.updateInfos(models: payinfoModels)
    }
    
    func handleFooterBar() {
        footerToolBar.rightBtnCallback = { [weak self] in
            guard let `self` = self else { return }
            self.handleFooterConfirmAction()
        }
    }

    func handleFooterConfirmAction() {
        //Pop up confirmation, payment made/currency placed after confirmation
        
    }
}

