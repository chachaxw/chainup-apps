//
//  EXLeverTradeVC.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/26.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXLeverTradeVC: EXTradeBaseVc {
    
    var leverBalanceModel:EXLeverFinanceBalanceModel = EXLeverFinanceBalanceModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EXTracking.shared.trackPage(name: .leverage, isEnter: true)
        getRisk()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        EXTracking.shared.trackPage(name: .leverage, isEnter: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handlePanelActions()
    }
    
    func handlePanelActions() {
        self.tradeHeaderV.onLeverPanelCallback = {[weak self] in
            self?.showPanel()
        }
        
        self.tradeHeaderH.onLeverPanelCallback = {[weak self] in
            self?.showPanel()
        }
    }
    
    func showPanel() {
        //If not logged in, do not request
        if XUserDefault.isOffLine(){
            BusinessTools.modalLoginVC()
            return
        }
        let panel = EXLeverDropDownPanel.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 366))
        panel.bindWithBalanceModel(self.leverBalanceModel)
        panel.borrowBlock = {[weak self] in
            self?.handlePanelAction(action: .leverBorrow)
        }
        panel.returnBlock = {[weak self] in
            self?.handlePanelAction(action: .leverReturn)
        }
        panel.transferBlock = {[weak self] in
            self?.handlePanelAction(action: .transfer)
        }
        
//        let test = UIView.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 366))
//        test.backgroundColor = UIColor.doraemon_random()
        EXAlert.showDropView(view: panel)
    }
    
    func handlePanelAction(action:EXBouncedModelAction) {
        EXAlert.dismiss()
        if action == .leverReturn {
            //This old class is called 'borrow', but it's about returning content
            let vc = EXCoinBorrowRecordVc.init(nibName: "EXCoinBorrowRecordVc", bundle: nil)
            let model = EXLeverageCoinMapItem()
            model.name = self.entity.name
            vc.model = model
            self.navigationController?.pushViewController(vc, animated: true)
        }else if action == .leverBorrow {
            //This old class is called a return, but it is a loan content
            let vc = EXLeverageReturnVc.init(nibName: "EXLeverageReturnVc", bundle: nil)
            vc.type = .leverageBorrow
            vc.currentCoinName = self.entity.name
            self.navigationController?.pushViewController(vc, animated: true)
        }else if action == .transfer {
            let transfer = EXAccountTransferVc.instanceFromStoryboard(name: StoryBoardNameAsset)
            transfer.isPopRoot = false
            transfer.transferFlow = .leverageToExchagne
            transfer.coinMapName = self.entity.name
            self.navigationController?.pushViewController(transfer, animated: true)
        }
    }
    
    override func gotoCurrentEntrust() {
        if XUserDefault.getToken() == nil{
            BusinessTools.modalLoginVC()
            return
        }
        let vc = EXLeverEntrustVC()
        vc.entity = self.entity
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func heartBeats() {
        
        self.getRisk()
        self.getCurrentEntrust()
    }
    
    //Obtain risk rate
    func getRisk(){
        //If not logged in, do not request
        if XUserDefault.isOffLine(){
            self.transactionTable.mj_header.endRefreshing()
            return
        }
        if self.entity.symbol.isEmpty {
            self.transactionTable.mj_header.endRefreshing()
            return
        }
        
        appApi.hideAutoLoading()
        appApi.rx.request(.getLeverBalance(symbol: entity.symbol))
            .MJObjectMap(EXLeverFinanceBalanceModel.self)
            .subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                mySelf.handleLeverBar(model: model)
                mySelf.transactionTable.mj_header.endRefreshing()
        }) { [weak self] (error) in
                guard let mySelf = self else{return}
                mySelf.transactionTable.mj_header.endRefreshing()
        }.disposed(by: disposeBag)
    }
    
    func handleLeverBar(model:EXLeverFinanceBalanceModel) {
        self.leverBalanceModel = model
        self.tradeHeaderH.udpateHLeverModel(model: model)
        self.tradeHeaderV.udpateLeverModel(model: model)
    }
    
    //Query current order
    func getCurrentEntrust(){
        //If not logged in, do not request
        if XUserDefault.getToken() == nil{
            if rowDatas.count > 0{
                rowDatas.removeAll()
                transactionTable.reloadData()
            }
            if currentOrderIds.count > 0 {
                self.clearPankouOrders()
            }
            self.transactionTable.mj_header.endRefreshing()
            return
        }
        if self.entity.symbol.isEmpty {
            self.transactionTable.mj_header.endRefreshing()
            return
        }
        
//        print("new leverVc, orderlistnew,  \(self.entity.symbol)")
        appApi.hideAutoLoading()
        appApi.rx.request(.getLeverOrderCurrent(symbol: self.entity.symbol,
                                                pageSize: "50",
                                                page: "1"))
            .MJObjectMap(EXCurrentEntrustArr.self)
            .subscribe(onSuccess: {[weak self] (entity) in
                guard let mySelf = self else{return}
                if mySelf.entity.symbol == entity.symbol {
                    mySelf.handleOrderList(entity: entity)
                }
                mySelf.transactionTable.mj_header.endRefreshing()
            }).disposed(by: disposeBag)
    }
    
    override func createOrderAction(element: OrderCreateElement) {
        self.handler.createOrder(side: element.side, type: element.type, volume: element.volume, price: element.price, entity: self.entity,isLever: true)
        handler.onCreateSuccessCallback = {[weak self] entity in
            self?.refreshOrders(entity: entity)
            self?.clearInputFields()
        }
        handler.onErrorCallback = {[weak self] in
            self?.clearInputFields()
        }
    }
    
    func refreshOrders(entity:EXCurrentEntrustEntity) {
        getCurrentEntrust()
        if entity.id.isEmpty {
            return
        }
        if rowDatas.count > 0 {
            rowDatas.insert(entity, at: 0)
        }else {
            rowDatas.append(entity)
        }
        self.transactionTable.reloadData()
    }
    
    override func cancelOrderAction(entity: EXCurrentEntrustEntity) {
        handler.cancelOrder(entity: entity,isLever: true)
        handler.onCancelSuccessCallback = {[weak self] entity in
            self?.refreshDeleteOrders(entity: entity)
            self?.clearInputFields()
        }
        handler.onErrorCallback = {[weak self] in
            self?.clearInputFields()
        }
    }
    
    func refreshDeleteOrders(entity:EXCurrentEntrustEntity) {
        var delIdx:Int?
        for (idx,item) in rowDatas.enumerated() {
            if item.id == entity.id {
                delIdx = idx
            }
        }
        guard let rmIdx = delIdx else { return }
        getCurrentEntrust()
        rowDatas.remove(at:rmIdx)
        self.transactionTable.reloadData()
    }
    
    override func entityDidRefreshed() {
        self.heartBeats()
    }
    
    //Click on the lever details buy and sell button
    func clickTrading(_ str : String , entity : CoinMapEntity){
        if str == "leverBuy"{
            tradeHeaderV.orderArea.orderBuyBtn.sendActions(for: .touchUpInside)
        }else{
            tradeHeaderV.orderArea.orderSellBtn.sendActions(for: .touchUpInside)
        }
    }

}


