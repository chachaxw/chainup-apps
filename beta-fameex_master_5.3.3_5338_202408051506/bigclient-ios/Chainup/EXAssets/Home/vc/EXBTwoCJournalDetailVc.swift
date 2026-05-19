//
//  EXBTwoCJournalDetailVc.swift
//  Chainup
//
//  Created by ljw on 2023/10/23.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXBTwoCJournalDetailVc: BaseVC,NavigationPlugin {

    @IBOutlet weak var topCon: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var financeItem:FinanceItem = FinanceItem()
    var sceneKey = ""
    typealias CancelWithdrawCallback = () -> ()
    var onCancelSuccessCallback:CancelWithdrawCallback?
    var dataArr = [EXCellDataModel]()
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.tableView, presenter: self)
        return nav
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.ThemeView.bg
        self.tableView.backgroundColor =  UIColor.ThemeView.bg
        getData()
        configFooter()
        configNavigation()
        configTableView()
    }
    func getData() {
        var titlesArr = [String]()
        var rightStrArr = [String]()
        if self.sceneKey == EXJournalListSceneKey.withdraw.rawValue {//Withdrawal
            titlesArr = ["b2c_Withdrawal_Time".localized(),"common_text_coinsymbol".localized(),"b2c_Arrive_Time".localized(),"withdraw_text_fee".localized(),"charge_text_state".localized(),"b2c_Deal_Time".localized(),"noun_order_paymentTerm".localized(),"otc_text_payee".localized()]
            rightStrArr = [financeItem.createdAtTime.count > 0 ? financeItem.createdAtTime : "--" ,financeItem.coinSymbol.aliasName(),financeItem.amount.formatAmount(financeItem.coinSymbol),financeItem.fee.formatAmount(financeItem.coinSymbol),financeItem.status_text,financeItem.updateTime.count > 0 ? financeItem.updateTime : "--","otc_text_bankCard".localized(),financeItem.userName]
            if financeItem.transferVoucher.count > 0 {
                titlesArr.append("b2c_Transfer_Vouchers".localized())
                rightStrArr.append("otc_text_adLook".localized())
            }
            for i in 0..<titlesArr.count {
                let model = EXCellDataModel()
                model.leftStr = titlesArr[i]
                model.rightStr = rightStrArr[i]
                if financeItem.transferVoucher.count > 0 {
                    if i == titlesArr.count - 1 {
                        model.isNeedAction = true
                    }
                }
                dataArr.append(model)
            }
        }else {//Recharge
            titlesArr = ["b2c_Recharge_Time".localized(),"common_text_coinsymbol".localized(),"b2c_Application_Amount".localized(),"withdraw_text_moneyWithoutFee".localized(),"charge_text_state".localized(),"b2c_Deal_Time".localized(),"noun_order_paymentTerm".localized(),"otc_text_payee".localized()]
            rightStrArr = [financeItem.createdAtTime.count > 0 ? financeItem.createdAtTime : "--",financeItem.coinSymbol,financeItem.amount.formatAmount(financeItem.coinSymbol),financeItem.settledAmount.formatAmount(financeItem.coinSymbol),financeItem.status_text,financeItem.updateTime.count > 0 ? financeItem.updateTime : "--","otc_text_bankCard".localized(),financeItem.userName]
            if financeItem.transferVoucher.count > 0 {
                titlesArr.append("b2c_Transfer_Vouchers".localized())
                rightStrArr.append("otc_text_adLook".localized())
            }
            for i in 0..<titlesArr.count {
                let model = EXCellDataModel()
                model.leftStr = titlesArr[i]
                model.rightStr = rightStrArr[i]
                if financeItem.transferVoucher.count > 0 {
                    if i == titlesArr.count - 1 {
                        model.isNeedAction = true
                    }
                }
                dataArr.append(model)
            }
        }
    }
    func largeTitleValueChanged(height: CGFloat) {
        topCon.constant = height
    }
}
extension EXBTwoCJournalDetailVc {
    func configNavigation(){
            self.navigation.isLastNavigationStyle = true
            self.navigation.setdefaultType(type: .list)
            self.navigation.setTitle(title: "journalAccount_text_detail".localized())
        }
        
        func configTableView() {
            self.tableView.register(UINib.init(nibName: "EXBTwoCJournalDetailCell", bundle: nil), forCellReuseIdentifier: "EXBTwoCJournalDetailCell")
        }
        
        func configFooter () {
            if self.financeItem.status == EXWithDrawVerifyStep.notStated.rawValue {//self.sceneKey == EXJournalListSceneKey.withdraw.rawValue
                let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 0))
                footerView.backgroundColor = self.view.backgroundColor
                
                let cancleBtn = UIButton.init(frame: CGRect.init(x: 15, y: 30, width: SCREEN_WIDTH - 30, height: 44))
                footerView.height = cancleBtn.ext_bottom() + 30
                cancleBtn.backgroundColor = UIColor.ThemeView.highlight
                cancleBtn.setTitle(LanguageTools.getString(key: "common_action_orderCancel"), for: UIControl.State.normal)
                cancleBtn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
                cancleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                cancleBtn.extSetAddTarget(self, #selector(handleWithdrawRevocation))
                footerView.addSubview(cancleBtn)
                tableView.tableFooterView = footerView
            }
        }
        
}
extension EXBTwoCJournalDetailVc {
   @objc func handleWithdrawRevocation() {
        let normalAlert = EXNormalAlert()
        normalAlert.configAlert(title: "common_text_tip".localized(), message: "withdraw_tip_confirmCancelWithdraw".localized())
        normalAlert.alertCallback = {[weak self] tag in
            if tag == 0 {
                self?.doRevocation()
            }
        }
        EXAlert.showAlert(alertView: normalAlert)
    }
    
    func doRevocation() {
        let withdrawId = self.financeItem.id
        if self.sceneKey == EXJournalListSceneKey.withdraw.rawValue {
            appApi.rx.request(.withdrawCancelWithDraw(withDrawId: withdrawId))
           .MJObjectMap(EXVoidModel.self)
           .subscribe{[weak self] event in
               switch event {
               case .success(_):
                   self?.cancelWithdrawSuccess()
                   break
               case .failure(_):
                   break
               }
           }.disposed(by: self.disposeBag)
        }else {
            appApi.rx.request(.depositCancelWithDraw(withDrawId: withdrawId))
           .MJObjectMap(EXVoidModel.self)
           .subscribe{[weak self] event in
               switch event {
               case .success(_):
                   self?.cancelWithdrawSuccess()
                   break
               case .failure(_):
                   break
               }
           }.disposed(by: self.disposeBag)
        }
        
       
    }
    
    func cancelWithdrawSuccess() {
        self.onCancelSuccessCallback?()
        if self.sceneKey == EXJournalListSceneKey.withdraw.rawValue {
            EXAlert.showSuccess(msg: "withdraw_tip_didCancelWithdraw".localized())
        }else {
             EXAlert.showSuccess(msg: "deposit_tip_didCancelDeposit".localized())
        }
       
        self.navigationController?.popViewController(animated:true)
    }
}
extension EXBTwoCJournalDetailVc : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXBTwoCJournalDetailCell", for: indexPath) as! EXBTwoCJournalDetailCell
        cell.cellBlock = { [weak self]  in
            guard let mySelf = self else{return}
            if mySelf.financeItem.transferVoucher.count > 0 {
                EXAlert.showPhotoBrowser(urls: [mySelf.financeItem.transferVoucher])
            }
        }
        cell.model = self.dataArr[indexPath.row];
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 46
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

