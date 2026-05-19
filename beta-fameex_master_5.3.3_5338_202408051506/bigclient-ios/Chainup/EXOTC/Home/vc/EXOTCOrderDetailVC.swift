//
//  EXOTCOrderNewVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import EXKit

class EXOTCOrderDetailVC: BaseVC,NavigationPlugin,StoryBoardLoadable {
    
    @IBOutlet var orderDetailTable: UITableView!
    @IBOutlet var countDownFooter: EXCountDownBtnFooter!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    var disposable: Disposable? = nil
    var isFromOrderList = false
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: orderDetailTable, presenter: self,customHandleBack:true)
        nav.backView.backgroundColor = .clear
        nav.backgroundColor = .clear
        return nav
    }()
    
    let gapView:UIView = UIView()
    var sequenceId:String?
    var orderDetailModel :EXOTCOrderDetailModel?
    var sections : [[OTCOrderInfoModel]] = []
    var tradeType:OTCTradeType = .none
    var orderVm:EXOTCVm = EXOTCVm()
    var currentPaymentIdx:Int = 0

    var rx_orderStatus = BehaviorRelay<EXOTCOrderDetailStatus?>(value:nil)

    var orderStatus :EXOTCOrderDetailStatus? {
        get {
            return rx_orderStatus.value
        }
        set {
            rx_orderStatus.accept(newValue)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let detailModel = self.orderDetailModel else {
            return
        }

        if detailModel.orderComplete() == false {
            updateOrderDetail()
        }
    }
    
    
    func handleBack() {
        if self.isFromOrderList{
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        if let navList = navigationController?.viewControllers {
            for vc in navList{
                if vc.isKind(of: EXOTCHomeContainerVc.self){
                    navigationController?.popToViewController(vc, animated: true)
                    return
                }
            }
            navigationController?.popViewController(animated: true)
        }
//            if navList.count > 2 {
//                let vc = navList[navList.count - 2]
//                if vc .isMember(of: EXOTCCreateOrderVC.self) {
//                    navigationController?.popToRootViewController(animated: true)
//                }
//            }
//            navigationController?.popViewController(animated: true)
//        }else {
//            navigationController?.popViewController(animated: true)
//        }
    }
    
    func configNav() {
        self.navigation.setdefaultType(type: .normal)
        self.navigation.backgroundColor = .clear
        self.navigation.backView.backgroundColor = .clear
        
        navigation.customBackCallback = {[weak self] in
            self?.handleBack()
        }
        self.navigation.rightItemCallback = {[weak self] idx in
            self?.handleChat()
        }
    }
    
    func handleChat(){
        guard let model = self.orderDetailModel else {
            return
        }
        let vc = OTCTalkVC()
        if model.status == EXOTCOrderDetailStatus.orderComplain.rawValue,model.isComplainUser == "1" {
            vc.type = .service
            vc.complainId = model.complainId
        }else {
            vc.type = .user
        }
        vc.detailEntity = model
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func configUI() {
        orderDetailTable.estimatedRowHeight = 35
        orderDetailTable.rowHeight = UITableView.automaticDimension
        self.configNav()
        countDownFooter.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        orderDetailTable.adjustBehaviorDisable()
        self.orderDetailTable.register(UINib.init(nibName: "EXOTCOrderInfoCell", bundle: nil),
                                       forCellReuseIdentifier: "EXOTCOrderInfoCell")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configUI()
        self.updateOrderDetail()
        countDownFooter.countDownStopped.asObservable()
            .subscribe(onNext:{[weak self] stopped in
                if stopped {
                    self?.updateOrderDetail()
                }
            }).disposed(by: self.disposeBag)

        _ = NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .takeUntil(self.rx.deallocated) //Page destruction automatic removal notification listening
            .subscribe(onNext: {[weak self] noti in
                self?.updateOrderDetail()
            })
    }
    
    func updateOrderDetail () {

        guard let orderId = sequenceId else {
            return
        }
        otcApi.rx.request(.otcOrderDetail(sequence: orderId))
            .MJObjectMap(EXOTCOrderDetailModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.handleDetail(model: model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }

    func handleDetail(model:EXOTCOrderDetailModel) {
        self.orderDetailModel = model
        self.handleOrderDetailInfos()
    }

    func bindSectionModels() {
        guard let detailModel = self.orderDetailModel else {
            return
        }
        self.sections.removeAll()

        let topModels = self.orderVm.orderInfoSections(model: detailModel)
        let payinfoModels = self.orderVm.paymentsInfoSections(model: detailModel,
                                                              paymentTypeIdx: currentPaymentIdx)
        if topModels.count > 0 {
            self.sections.append(topModels)
        }
        if payinfoModels.count > 0 {
            self.sections.append(payinfoModels)
        }
        self.orderDetailTable.reloadData()
    }

    func handleOrderDetailInfos() {
        guard let detailModel = self.orderDetailModel else {
            return
        }
        self.orderStatus = EXOTCOrderDetailStatus(rawValue: detailModel.status)
//        self.navigation.isLastNavigationStyle = detailModel.orderComplete()
        self.navigation.setTitle(title: detailModel.getStatusTitle())
        self.navigation.configRightItems(detailModel.isOrderDuringReview() ? [] : ["personal_messagecenter"])
        bindSectionModels()

        let tipMsg = self.orderVm.orderTipMessage(detailModel)
        if let msg = tipMsg {
            let msgfooter = EXOTCOrderDetailMsgFooter()
            let msgHeight = msg.textSizeWithFont(UIFont.ThemeFont.SecondaryRegular, width: SCREEN_WIDTH - 30).height + 30
            msgfooter.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: msgHeight)
            msgfooter.msgLabel.text = msg
            self.orderDetailTable.tableFooterView = msgfooter
        }else {
            self.orderDetailTable.tableFooterView = nil
        }

        if self.orderVm.shouldShowFooterBar(withStatus: detailModel.status) {
            self.orderDetailTable.contentInset.bottom = 74
            countDownFooter.isHidden = false
            self.handleFooterBar()
        }else {
            countDownFooter.isHidden = true
        }
    
        if let isSeller = detailModel.isSeller() {
            if isSeller {
                if detailModel.status == EXOTCOrderDetailStatus.orderPay.rawValue ||
                    detailModel.status == EXOTCOrderDetailStatus.orderDidPay.rawValue {
                    startFire()
                }else {
                    self.disposable?.dispose()
                }
            }else {
                if detailModel.status == EXOTCOrderDetailStatus.orderPending.rawValue ||
                    detailModel.status == EXOTCOrderDetailStatus.orderDidPay.rawValue {
                    startFire()
                }else {
                    self.disposable?.dispose()
                }
            }
        }else {
            self.disposable?.dispose()
        }
    }
    
    private func startFire() {
        self.disposable?.dispose()
        self.disposable =
        Observable<Int>.interval(.seconds(30), scheduler: MainScheduler.instance)
                .subscribe(onNext: { [weak self] (element) in
                    guard let `self` = self else { return }
                    self.updateOrderDetail()
                })
    }

    func handleFooterBar() {
        guard let model = self.orderDetailModel else {
            return
        }

        if model.status == EXOTCOrderDetailStatus.orderPay.rawValue {
            let time = Int(model.limitTime) ?? 60
            countDownFooter.countTime = time
            countDownFooter.leftTime.onNext(time)
        }

        self.orderVm.handleFooterBarStyle(withTradeType: self.tradeType,
                                          detailModel: model,
                                          bindFooterBar: countDownFooter)

        countDownFooter.leftBtnCallback = { [weak self] in
            guard let `self` = self else { return }
            self.handleFooterLeftAction()
        }

        countDownFooter.rightBtnCallback = { [weak self] in
            guard let `self` = self else { return }
            self.handleFooterRightAction()
        }

    }

    func handleFooterLeftAction() {
        guard let model = self.orderDetailModel else {
            return
        }
        let action = self.orderVm.getFooterBarActionType(tradeType: self.tradeType,
                                                         detailModel:model ,
                                                         isLeftBtn: true)
        switch action {
        case .actionCancel:
            self.handleCancleAction()
            break
        case .actionToComplain:
            self.handleComplain()
            break
        case .actionCancelComplain:
            self.handleComplainCancel()
            break
        default:
            break
        }

    }

    func handleFooterRightAction() {
        guard let model = self.orderDetailModel else {
            return
        }
        let action = self.orderVm.getFooterBarActionType(tradeType: self.tradeType,
                                                         detailModel:model ,
                                                         isLeftBtn: false)
        switch action {
        case .actionDidPay,
             .actionDidReceive:
            self.handleConfirmAction()
            break
        case .actionRefresh:
            updateOrderDetail()
        default:
            break
        }
    }
    
    func handleConfirmAction() {
        guard let model = self.orderDetailModel else {
            return
        }
        //Pop up confirmation, payment made/currency placed after confirmation
        if let isBuy = model.isBuyer() {
            if isBuy {
                let payConfirmAlert = EXConfirmPayAlert()
                payConfirmAlert.configAlert(title: "otc_text_didPayConfirm".localized(),
                                            message:"otc_tip_remindBuyerClickDidPay".localized(),
                                            confirmPayInfo: self.orderDetailModel?.getPayConfirmAlertInfo(idx:currentPaymentIdx) ?? [])
                payConfirmAlert.alertCallback = { [weak self] idx in
                    guard let `self` = self else { return }
                    if idx == 0 {
                        self.confirmOrder()
                    }
                }
                EXAlert.showAlert(alertView: payConfirmAlert)
            }else {
                confirmSellOrderStepOne()
            }
        }
    }
    
    func handleCancleAction() {

        let reconfirm = EXReconfirmAlertView()
        reconfirm.configAlert(title: "otc_action_cancel".localized(),
                              message: String(format: "oct_tip_buyerCancel".localized(), OTCPulbicManager.sharedInstance.getCancelMaxNum()) ,
                              confirmCondition: "otc_tip_buyerCancelConfirm".localized(),
                              passiveBtnTitle: "common_action_thinkAgain".localized(),
                              positiveBtnTitle:  "common_text_btnConfirm".localized())

        reconfirm.alertCallback = { [weak self] idx in
            guard let `self` = self else { return }
            if idx == 0 {
                self.cancelOrder()
            }
        }
        EXAlert.showAlert(alertView: reconfirm)
    }

    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }

    func handleComplain(){
        if let model = self.orderDetailModel {
            if model.payTime.count > 0 {
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let orderTime = fmt.date(from: model.payTime) {
                    let now : Date = Date()
                    let interval = now.timeIntervalSince(orderTime)
                    if interval > 5*60 {
                        complainOrderCreate()
                    }else {
                        EXAlert.showFail(msg: "otc_tip_appealTimeLimit".localized())
                    }
                }else {
                    complainOrderCreate()
                }
            }else {
                complainOrderCreate()
            }
        }
    }

    func complainOrderCreate() {

        let vc = EXOTCOrderAppealVc.instanceFromStoryboard(name: StoryBoardNameOTC)
        if let model = self.orderDetailModel {
            vc.orderDetailModel = model
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func handleComplainCancel() {
        let normal = EXNormalAlert()
        normal.configAlert(title: "common_text_tip".localized(),
                           message:"otc_tip_cancleAppealConfirm".localized())
        normal.alertCallback = {[weak self] tag in
            if tag == 0 {
                self?.cancelComplain()
            }
        }
        EXAlert.showAlert(alertView: normal)
    }

    func cancelComplain() {
        guard let sId = self.sequenceId else {return}
        otcApi.rx.request(.otcComplainCancel(sequence: sId))
            .MJObjectMap(EXVoidModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(_):
                    self?.updateOrderDetail()
                    break
                case .failure(_):
                    self?.updateOrderDetail()
                    break
                }
            }.disposed(by: self.disposeBag)
    }

    func cancelOrder(){
        guard let sId = self.sequenceId else {return}
        otcApi.rx.request(.orderCancel(sequenceId: sId))
            .MJObjectMap(EXVoidModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(_):
                    self?.updateOrderDetail()
                    break
                case .failure(_):
                    self?.updateOrderDetail()
                    break
                }
            }.disposed(by: self.disposeBag)
    }

    func confirmOrder(){
        guard let sId = self.sequenceId else {return}

        if let isBuyer = self.orderDetailModel?.isBuyer() {
            if isBuyer {
                var paymentKey = ""
                if let payment = self.orderDetailModel?.payment {
                    if payment.count > currentPaymentIdx {
                        let model = payment[currentPaymentIdx]
                        paymentKey = model.payment
                    }
                }
                //Confirm payment
                otcApi.rx.request(.orderPayed(sequenceId: sId, payment: paymentKey))
                    .MJObjectMap(EXVoidModel.self)
                    .subscribe{[weak self] event in
                        switch event {
                        case .success(_):
                            self?.updateOrderDetail()
                            break
                        case .failure:
                            break
                        }
                    }.disposed(by: self.disposeBag)


            }
        }
    }

//    func handleInputValue(_ info:[String:String]) {
//        guard let sId = self.sequenceId else {return}
//        guard let userInput = info["capitalPword"] else {
//            return
//        }
//        //Confirm Coining
//        otcApi.rx.request(.otcConfirmOrder(sequence: sId, capitalPwd: userInput))
//            .MJObjectMap(EXVoidModel.self,false)
//            .subscribe{[weak self] event in
//                switch event {
//                case .success(_):
//                    self?.confirmSuccess()
//                    break
//                case .failure(let err):
//                    self?.handleErr(err)
//                    break
//                }
//            }.disposed(by: self.disposeBag)
//    }

    
    func submitSellOrder(result: EXCodeResult) {
        if let isBuyer = self.orderDetailModel?.isBuyer() {
            if isBuyer {
                return
            }
        }
        guard let sId = self.sequenceId else {return}
        
        //Confirm Coining
        otcApi.rx.request(.otcConfirmOrder(
            sequence: sId,
            capitalPwd: result.fundPassWord,
            smsAuthCode: result.phoneCode,
            googleCode: result.googleCode)
        )
            .MJObjectMap(EXVoidModel.self,false)
            .subscribe{[weak self] event in
                switch event {
                case .success(_):
                    self?.confirmSuccess()
                    break
                case .failure(let err):
                    self?.handleErr(err)
                    break
                }
            }.disposed(by: self.disposeBag)
    }
    func confirmSuccess() {
        EXAlert.showSuccess(msg: "otc_tip_sendCoinSuccess".localized())
        updateOrderDetail()
    }

    func handleErr(_ err:Error) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            EXAlert.showFail(msg: err.localizedDescription)
        }
    }

    func changePayType() {
        if let model = self.orderDetailModel {
            //No need for non orderpay
            if model.status != EXOTCOrderDetailStatus.orderPay.rawValue {
                return
            }

            if model.payment.count > 1 {
                var payname:[String] = []
                for payitem in model.payment {
                    if let pmodel = OTCPulbicManager.sharedInstance.getOtcPaymentModel(payitem.payment) {
                        payname.append(pmodel.title)
                    }
                }
                let sheet = EXOldActionSheetView()
                sheet.configButtonTitles(buttons:payname,selectedIdx: currentPaymentIdx)
                sheet.actionIdxCallback = {[weak self] tag in
                    self?.updatePayment(tag)
                }
                EXAlert.showSheet(sheetView:sheet)
            }
        }
    }

    func updatePayment(_ selectIdx:Int) {
        currentPaymentIdx = selectIdx
        bindSectionModels()
    }
}

extension EXOTCOrderDetailVC : UITableViewDelegate {

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let rowItems = self.sections[indexPath.section]
//        if rowItems.count == 1 {
//            return 37
//        }else {
//            if indexPath.row == 0 {
//                return 34
//            }else if indexPath.row == rowItems.count - 1 {
//                return 34
//            }else {
//                return 31
//            }
//        }
//    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 47
        }else {
            return 57
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let displayHeader = EXOTCOrderInfoDisplayTitle.init()
            displayHeader.bindModel(model:self.orderDetailModel?.getCurrentTitleModelForDisplay())
            displayHeader.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 47)
            return displayHeader
        }else {

            var showIcon = true
            if let status = self.orderDetailModel?.status {
                if status == EXOTCOrderDetailStatus.orderComplete.rawValue ||
                    status == EXOTCOrderDetailStatus.orderCanceled.rawValue ||
                    status == EXOTCOrderDetailStatus.orderDidPay.rawValue ||
                    status == EXOTCOrderDetailStatus.orderComplainDone.rawValue ||
                    status == EXOTCOrderDetailStatus.orderAppealCancel.rawValue ||
                    status == EXOTCOrderDetailStatus.orderComplain.rawValue
                {
                    showIcon = false
                }
            }

            let actionHeader = EXOTCOrderInfoActionTitle.init()
            actionHeader.bindModel(model:self.orderDetailModel?.getCurrentTitleModelForPayTitle(currentPaymentIdx))
            actionHeader.showTopGap = true
            actionHeader.showTitleIcon = showIcon
            actionHeader.tapActionCallback = {[weak self] in
                self?.changePayType()
            }
            actionHeader.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 47)
            return actionHeader
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

}

extension EXOTCOrderDetailVC : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = self.sections[section].count
        return rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "EXOTCOrderInfoCell", for: indexPath)  as! EXOTCOrderInfoCell
        let rowItems = self.sections[indexPath.section]

//        if rowItems.count == 1 {
//            cell.cellPosition = .single
//        }else {
//            cell.cellPosition = .top
//            if indexPath.row == 0 {
//                cell.cellPosition = .top
//            }else if indexPath.row == rowItems.count - 1 {
//                cell.cellPosition = .bottom
//            }else {
//                cell.cellPosition = .middle
//            }
//        }
        let model = rowItems[indexPath.row]
        cell.updateInfo(model: model)
        cell.actionCallback = {[weak self] action in
            self?.actionCallback(type: action)
        }
        return cell
    }
    
    func actionCallback(type:OTCOrderInfoActionType) {
        guard let detailModel = self.orderDetailModel else {
            return
        }
        
        if detailModel.isTwoMin == "1" {
            let actionAlert = EXContactAlert()
            if let isBuyer = detailModel.isBuyer() {
                if isBuyer {
                    actionAlert.configAlert(phoneNumber:detailModel.seller?.mobileNumber ?? "",
                                            mail:detailModel.seller?.email ?? "")
                }else {
                    actionAlert.configAlert(phoneNumber:detailModel.buyer?.mobileNumber ?? "",
                                            mail:detailModel.buyer?.email ?? "")
                }
            }
            EXAlert.showAlert(alertView: actionAlert)
        }else if detailModel.isTwoMin == "0"{
            let cmAlert = EXNormalAlert()
            cmAlert.configSigleAlert(title: nil, message: "common_tip_showContactOTC".localized())
            EXAlert.showAlert(alertView: cmAlert)
        }
    }
    
}


extension EXOTCOrderDetailVC{
    func confirmSellOrderStepOne() {
        //Find the other party's payment method
        let paymentKey = self.orderDetailModel?.payKey
        if let paykey = paymentKey {
            if let payment = self.orderDetailModel?.payment {
                if payment.count > 0 {
                    for (idx,payModel) in payment.enumerated() {
                        if payModel.payment == paykey {
                            currentPaymentIdx = idx
                            break
                        }
                    }
                }
            }
        }
        let payConfirmAlert = EXConfirmPayAlert()
        payConfirmAlert.configAlert(title: "otc_action_confirmSendCoinTitle".localized(),
                                    message:"otc_tip_remindSellerSendCoin".localized(),
                                    confirmPayInfo: self.orderDetailModel?.getPayConfirmAlertInfo(idx: currentPaymentIdx) ?? [],
                                    positiveBtnTitle:"otc_action_confirmSendCoin".localized())
        payConfirmAlert.alertCallback = { [weak self] idx in
            guard let `self` = self else { return }
            if idx == 0 {
                EXAlert.dismissEnd {
                    self.confirmSellOrderStepTwo()
                }
            }
        }
        EXAlert.showAlert(alertView: payConfirmAlert)
        
    }

    func confirmSellOrderStepTwo(){
        guard let sId = self.sequenceId else {return}
        
        let manger = EXComSafeVaildManger()
        manger.safeCheck = .coinReleaseOrderVerification
        manger.startSafeAlert()
        manger.resultCallBack = { result in
            self.submitSellOrder(result: result)
        }
    }
    
}
