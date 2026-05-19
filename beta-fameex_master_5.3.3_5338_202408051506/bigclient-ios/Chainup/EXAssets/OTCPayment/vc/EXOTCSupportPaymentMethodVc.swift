//
//  EXOTCSupportPaymentMethodVc.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXOTCSupportPaymentMethodVc: BaseVC,StoryBoardLoadable,NavigationPlugin{
    @IBOutlet var paymentTable: UITableView!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    var payments : [OTCPaymentModel] = []
    var hasPayment: [EXOTCPaymentListModel] = []
    var didAddPaymentKeys:[String] = []
    
    
    internal lazy var navigation : EXNavigation = {
        let nav =  EXNavigation.init(affectScroll: self.paymentTable, presenter: self)
        return nav
    }()
    
    func configNavigation() {
        self.navigation.setdefaultType(type: .list)
        self.navigation.setTitle(title: "noun_order_paymentTerm".localized())
    }
    
    func registerCells() {
        self.paymentTable.emptyDataSetSource = self
        self.paymentTable.emptyDataSetDelegate = self
        self.paymentTable.register(UINib.init(nibName: "EXPaymentTypeCell", bundle: nil), forCellReuseIdentifier:"EXPaymentTypeCell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        configNavigation()
        configPayments()
    }
    
    func configPayments() {
        self.payments = OTCPulbicManager.sharedInstance.getOtcPayments()
        for item in hasPayment {
            didAddPaymentKeys.append(item.payment)
        }
        self.paymentTable.reloadData()
    }
    
    func largeTitleValueChanged(height: CGFloat) {
        topConstraint.constant = height
    }
}

extension EXOTCSupportPaymentMethodVc : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let payment = self.payments[indexPath.row]
        if didAddPaymentKeys.contains(payment.key) {
            EXAlert.showFail(msg: "otc_tip_paymentLimitDeactiveError".localized())
            return
        }
        let addnew =  EXOTCNewPaymentAddNewVC()//EXOTCPaymentAddNewVc.instanceFromStoryboard(name: StoryBoardNameAsset)
        addnew.payTypeKey = payment.key
        addnew.navTitle = payment.title
        addnew.canEdit = true
        addnew.onPaymentSuccess = {[weak self] key in
            self?.didAddPaymentKeys.append(key)
        }
        self.navigationController?.pushViewController(addnew, animated: true)
    }
    
}

extension EXOTCSupportPaymentMethodVc : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.payments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let payment = self.payments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "EXPaymentTypeCell") as! EXPaymentTypeCell
        cell.updatePaymentinfo(payment)
        return cell
    }
}
