//
//  EXOTCAvailablePaymentVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXOTCAvailablePaymentVc: BaseVC,StoryBoardLoadable,NavigationPlugin {
    
    @IBOutlet var paymentTable: UITableView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    var allPayments:[EXOTCPaymentListModel] = []
    let smsService:EXSmsService = EXSmsService()
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.paymentTable, presenter: self)
        return nav
    }()
    
    
    
     //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTable()
        configNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestPaymentFind()
    }
    
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
//    var addnew : EXOTCPaymentAddNewVc?
    var addnew : EXOTCNewPaymentAddNewVC?

}

//MARK: request
extension EXOTCAvailablePaymentVc{
    func requestPaymentFind() {
        otcApi.rx.request(.paymentFind(isOpen: nil))
            .MJObjectMap(CommonAryModel.self,false)
            .subscribe{[weak self] event in
                switch event {
                case .success(let model):
                    self?.handelUserPayments(model)
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
}
extension EXOTCAvailablePaymentVc{
    func handelUserPayments(_ model:CommonAryModel) {
        allPayments.removeAll()
        for item in model.dictAry {
            if let paymentModel = EXOTCPaymentListModel.mj_object(withKeyValues: item) {
                allPayments.append(paymentModel)
            }
        }
        self.paymentTable.reloadData()
    }
    
    func configNavigation(){
        navigation.configRightItems(["payMethod_action_addnew".localized()], isImageName: false)
        self.navigation.setTitle(title: "noun_order_paymentTerm".localized())
        self.navigation.setdefaultType(type: .list)
        navigation.rightItemCallback = {[weak self] tag in
            self?.addNewPayment()
        }
    }
    
    func addNewPayment() {
        if EXOTCSafetyCheckVm.manager.checkOTCBasicRequire(self) {
            self.handleAddNewPayment()
        }
    }
    
    func handleAddNewPayment() {
        let listVc = EXOTCSupportPaymentMethodVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        listVc.hasPayment = self.allPayments
        self.navigationController?.pushViewController(listVc, animated: true)
    }
    
    func registerTable() {
        self.paymentTable.emptyDataSetSource = self
        self.paymentTable.emptyDataSetDelegate = self
        self.paymentTable.separatorStyle = .singleLine
        self.paymentTable.separatorColor = .Ex.fill5
        self.paymentTable.separatorInset = .zero
        self.paymentTable.register(EXAvailablePaymentCell.self, forCellReuseIdentifier: "EXAvailablePaymentCell")
    }
}
extension EXOTCAvailablePaymentVc : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didCell(indexPath.row,source : "self")
    }
    
    func didCell(_ index : Int ,source : String){
        let paymentModel = allPayments[index]
//        addnew =  EXOTCPaymentAddNewVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        
        addnew =  EXOTCNewPaymentAddNewVC()
        addnew?.tag = index + 1000
        addnew?.navTitle = paymentModel.title
        addnew?.payTypeKey = paymentModel.payment
        addnew?.oldPaymentModel = paymentModel
        addnew?.deleteCallback = {[weak self]tag in
            self?.deletePayment(tag)
        }
        if source == "self"{
            addnew?.canEdit = false
        }else{
            addnew?.canEdit = true
        }
        if addnew != nil{
            self.navigationController?.pushViewController(addnew!, animated: true)
        }
    }
    
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "address_action_delete".localized()
//    }
    
    func justHasLastOneActivePayment() -> Bool{
        let avalible = allPayments.filter { (model) -> Bool in
            return model.isOpen == "1"
        }
        return avalible.count == 1
    }
    
    func isLastOnePayment() -> Bool{
        return allPayments.count == 1
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == UITableViewCell.EditingStyle.delete {
//            deletePayment(indexPath.row)
//        }
//    }
    
    func deletePayment(_ index : Int){
        let paymentModel = allPayments[index]
        //There is only one payment method left
        if isLastOnePayment() {
            if paymentModel.isOpen == "1" {
                EXAlert.showFail(msg: "otc_tip_paymentLimitActiveError".localized())
            }else {
                EXAlert.showFail(msg: "otc_tip_paymentLimitError".localized())
            }
        }else {
            //Among multiple, only one has been activated, and this activated state cannot be deleted
            if justHasLastOneActivePayment() {
                if paymentModel.isOpen == "1" {
                    EXAlert.showFail(msg: "otc_tip_paymentLimitActiveError".localized())
                }else {
                    self.handleDeletePayment(paymentModel,index)
                }
            }else {
                self.handleDeletePayment(paymentModel,index)
            }
        }
    }
    
    func handleDeletePayment(_ paymentModel:EXOTCPaymentListModel,_ atRow:Int) {
        
        self.doDeletePayment(paymentModel,atRow)
    }
 
    func doDeletePayment(_ paymentModel:EXOTCPaymentListModel,_ atRow:Int) {
        self.verifiedSafety([:], paymentModel.id,atRow)
    }
    
    func updateRowDatas(_ deletedRow:Int) {
        if allPayments.count > deletedRow {
            addnew?.endDelete()//If it is not empty, the deletion is successful
            allPayments.remove(at: deletedRow)
            paymentTable.reloadData()
        }
    }
    
    func verifiedSafety(_ info:[String:String],_ key:String, _ index:Int) {
           otcApi.rx.request(.otcPaymentDelete(paymentID: key,
                                               smsAuthCode: info["smsAuthCode"],
                                               googleCode: info["googleCode"]))
            .MJObjectMap(EXVoidModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(_):
                    self?.updateRowDatas(index)
//                    EXAlert.showSuccess(msg: "otc_tip_paymentDeactiveSuccess".localized())
                    break
                case .failure(_):
                    break
                }
            }.disposed(by: self.disposeBag)
    }
}

extension EXOTCAvailablePaymentVc : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPayments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let paymentModel = allPayments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXAvailablePaymentCell", for: indexPath) as! EXAvailablePaymentCell
        cell.tag = 1000 + indexPath.row
        cell.bindPaymentData(paymentModel)
        cell.onChangeActiveCallback = {[weak self] isON in
            self?.handleActiveAction(paymentModel, isON, cell)
        }
        cell.editorPaymentCallback = {[weak self]tag in
            self?.didCell(tag, source: "cell")
        }
        cell.longCallBack = { [weak self]tag in
            self?.deletePayment(tag - 1000)
        }
        return cell
    }

    func handleActiveAction(_ paymentModel:EXOTCPaymentListModel,_ isOn:Bool, _ cell:EXAvailablePaymentCell) {
        if justHasLastOneActivePayment() {
            if paymentModel.isOpen == "1",isOn == false {
                cell.activeCheckBox.checked(check:true)
                EXAlert.showFail(msg: "otc_tip_paymentDidExist".localized())
            }else {
                self.doRequestOTCPayment(paymentModel, isOn, cell)
            }
        }else {
            let avalible = allPayments.filter { (model) -> Bool in
                return model.isOpen == "1"
            }
            if avalible.count >= 3,isOn {
                cell.activeCheckBox.checked(check: false)
                EXAlert.showFail(msg: "otc_tip_paymentTypeMax".localized())
            }else {
                self.doRequestOTCPayment(paymentModel, isOn, cell)
            }
        }
    }
    
    func doRequestOTCPayment(_ paymentModel:EXOTCPaymentListModel,_ isOn:Bool, _ cell:EXAvailablePaymentCell) {
        if paymentModel.id.isEmpty {
            return
        }
        otcApi.rx.request(.otcPaymentActive(paymentID: paymentModel.id,
                                            active: isOn ? "1" : "0"))
            .MJObjectMap(EXVoidModel.self)
            .subscribe{[weak self] event in
                switch event {
                case .success(_):
                    paymentModel.isOpen = isOn ? "1" : "0"
                    cell.activeCheckBox.text(content: isOn ? "payMethod_text_active".localized() : "payMethod_text_inactive".localized())
                    break
                case .failure(_):
                    paymentModel.isOpen = isOn ? "0" : "1"
                    cell.activeCheckBox.text(content: isOn ? "payMethod_text_inactive".localized() : "payMethod_text_active".localized())
                    cell.activeCheckBox.checked(check: !isOn)
                    break
                }
            }.disposed(by: self.disposeBag)
    }
}

