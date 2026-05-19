//
//  EXConfirmOrderSheet.swift
//  Chainup
//
//  Created by 劉軒 on 2023/10/18.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXInnerWithdrawOrderModel {
    var toSelectType: String = ""//
    var toSelectTypeShow: String = ""
    var toSelectContent: String = ""
    var amount: String = ""//
    var fee: String = ""//
    var coinSymbol: String = ""//
    var verifyParameters:[String:String]?
    ///
    var checkParameters:[String:String] {
        var parameters:[String:String] = [:]
        parameters["toSelectType"] = toSelectType
        parameters["toSelectContent"] = toSelectContent
        parameters["amount"] = amount
        parameters["fee"] = fee
        parameters["coinSymbol"] = coinSymbol
        return parameters
    }
    
    var commitOrderParameters:[String:String] {
        var parameters:[String:String] = checkParameters
        verifyParameters?.forEach { (key, value) in
            parameters[key] = value
        }
        return parameters
    }
}

class ConfirmWithDrawModel:EXBaseModel {
    var withDrawAmount:String = ""
    var address:String = ""
    var memo:String = ""
    var mainNet:String = ""
    var symbol:String = ""
    var totalAmount:String = ""
    var fee:String = ""
    var isTrusted:Bool = false
}

class ConfirmWithDrawFiatModel:EXBaseModel {
    var totalAmount:String = ""
    var withDrawAmount:String = ""
    var bankAccount:String = ""
    var bankCardNumber:String = ""
    var bankNameShow:String = ""
    var memo:String = ""
    var symbol:String = ""
    var fee:String = ""
}

class ConfirmHeaderV:UIView {
    
    lazy var titleLabel:UILabel = {
        let title:UILabel = UILabel()
        title.font = UIFont.ThemeFont.BodyMedium
        title.textColor = UIColor.ThemeLabel.colorMedium
        return title
    }()
    
    lazy var descLabel:UILabel = {
        let title:UILabel = UILabel()
        title.font = UIFont.ThemeFont.H3Medium
        title.textColor = UIColor.ThemeLabel.colorHighlight
        title.textAlignment = .left
        return title
    }()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        config()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config() {
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(titleLabel)
        self.addSubview(descLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(9)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(18)
        }
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
}

class ConfirmItemV:UIView {
    
    lazy var titleLabel:UILabel = {
        let title:UILabel = UILabel()
        title.font = UIFont.ThemeFont.BodyMedium
        title.textColor = UIColor.ThemeLabel.colorMedium
        return title
    }()
    
    lazy var descLabel:UILabel = {
        let title:UILabel = UILabel()
        title.font = UIFont.ThemeFont.BodyMedium
        title.textColor = UIColor.ThemeLabel.colorLite
        title.numberOfLines = 0
        title.textAlignment = .right
        return title
    }()
    
    lazy var trustedV:UIView = {
        let bg = UIView()
        bg.layer.cornerRadius = 2
        bg.layer.masksToBounds = true 
        bg.backgroundColor = UIColor.ThemeView.highlight15
        let label = UILabel()
        label.font = UIFont.ThemeFont.MinimumRegular
        label.textColor = UIColor.ThemeLabel.colorHighlight
        label.text = "common_text_already_trust".localized()
        bg.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
        }
        return bg
    }()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        config()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config() {
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(titleLabel)
        self.addSubview(descLabel)
        self.addSubview(trustedV)
        showTrustedLabel(false)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalToSuperview()
            make.right.lessThanOrEqualTo(descLabel.snp.left).offset(-45)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(45)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        trustedV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(descLabel.snp.left).offset(-8)
        }
    }
    
    func showTrustedLabel(_ show:Bool) {
        trustedV.isHidden = !show
    }
}

class EXConfirmOrderSheet: NibBaseView {
    @IBOutlet weak var confirmTitle: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var stacker: UIStackView!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    
    typealias ConfirmCallback = () -> ()
    var confirmCallback : ConfirmCallback?
    
    var confirmModel:ConfirmWithDrawModel = ConfirmWithDrawModel()
    var confirmFiatModel:ConfirmWithDrawFiatModel = ConfirmWithDrawFiatModel()

    override func onCreate() {
        configUI()
    }
    
    func configUI() {
        self.backgroundColor = UIColor.ThemeView.bg
        confirmBtn.backgroundColor = UIColor.ThemeView.highlight
        confirmTitle.font = UIFont.ThemeFont.HeadBold
        confirmTitle.text = "confirm_withdraw".localized()
        confirmTitle.textColor = UIColor.ThemeLabel.colorLite
        
        cancelBtn.setTitle("common_text_btnCancel".localized(), for: .normal)
        cancelBtn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        cancelBtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        cancelBtn.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
        stacker.backgroundColor = UIColor.ThemeView.bg
        confirmBtn.setTitle("common_text_btnConfirm".localized(), for: .normal)
        confirmBtn.setTitleColor(UIColor.white, for: .normal)
        confirmBtn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        tipLabel.font = UIFont.ThemeFont.SecondaryMedium
        tipLabel.textColor = UIColor.ThemeLabel.colorMedium
        tipLabel.text = "withdraw_confirm_tip".localized()
        confirmBtn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
    
    @objc func dismiss() {
        EXAlert.dismiss()
    }
    
    @objc func confirmBtnAction() {
        self.confirmCallback?()
    }
    
    func handleConfirmedInfo(_ model: ConfirmWithDrawModel) {
        self.confirmModel = model
        if self.stacker.arrangedSubviews.count == 0 {
            let header = ConfirmHeaderV()
            header.titleLabel.text = "withdraw_text_moneyWithoutFee".localized()
            header.descLabel.text = model.withDrawAmount + " \(model.symbol)"
            self.stacker.addArrangedSubview(header)
            let address = ConfirmItemV()
            address.titleLabel.text = "withdraw_text_address".localized()
            address.descLabel.text = model.address
            self.stacker.addArrangedSubview(address)
            if model.memo.count > 0 {
                let memo = ConfirmItemV()
                memo.titleLabel.text = "address_text_remark".localized()
                memo.descLabel.text = model.memo
                memo.showTrustedLabel(model.isTrusted)
                self.stacker.addArrangedSubview(memo)
            }
            
            let mainnet = ConfirmItemV()
            mainnet.titleLabel.text = "link_name".localized()
            mainnet.descLabel.text = model.mainNet
            self.stacker.addArrangedSubview(mainnet)
            let symbol = ConfirmItemV()
            symbol.titleLabel.text = "common_text_coinsymbol".localized()
            symbol.descLabel.text = model.symbol
            self.stacker.addArrangedSubview(symbol)
            let amount = ConfirmItemV()
            amount.titleLabel.text = "charge_text_volume".localized()
            amount.descLabel.text = model.totalAmount  + " \(model.symbol)"
            self.stacker.addArrangedSubview(amount)
            let fee = ConfirmItemV()
            fee.titleLabel.text = "withdraw_text_fee".localized()
            fee.descLabel.text = model.fee  + " \(model.symbol)"
            self.stacker.addArrangedSubview(fee)
            
            header.snp.makeConstraints { make in
                make.height.equalTo(70)
            }
        }
        
    }
    
    
    private(set) var innerWithdrawOrderModel:EXInnerWithdrawOrderModel = EXInnerWithdrawOrderModel()
    func bindInnerWithdrawOrder(_ model:EXInnerWithdrawOrderModel) {
        self.innerWithdrawOrderModel = model
        guard self.stacker.arrangedSubviews.isEmpty else { return }
        //
        let header = ConfirmHeaderV()
        header.titleLabel.text = "withdraw_text_moneyWithoutFee".localized()
        header.descLabel.text = model.amount + " \(model.coinSymbol)"
        stacker.addArrangedSubview(header)
        header.snp.makeConstraints { make in
            make.height.equalTo(70)
        }
        //
        let sendMode = ConfirmItemV()
        sendMode.titleLabel.text = "withdraw_inner_sendMode".localized()
        sendMode.descLabel.text = model.toSelectTypeShow
        stacker.addArrangedSubview(sendMode)
        //
        let toMode = ConfirmItemV()
        toMode.titleLabel.text = "transfer_text_to".localized()
        toMode.descLabel.text = model.toSelectContent
        stacker.addArrangedSubview(toMode)
        //
        let amountMode = ConfirmItemV()
        amountMode.titleLabel.text = "transaction_text_dealNum".localized()
        amountMode.descLabel.text = model.amount
        stacker.addArrangedSubview(amountMode)
        //
        let feeModel = ConfirmItemV()
        feeModel.titleLabel.text = "withdraw_text_fee".localized()
        feeModel.descLabel.text = model.fee
        stacker.addArrangedSubview(feeModel)
        
    }
    
    func handleConfirmedFiatInfo(_ model: ConfirmWithDrawFiatModel) {
        self.confirmFiatModel = model
        
        tipLabel.text = "otc_text_deposit_status_info_tips".localized()
        if self.stacker.arrangedSubviews.count == 0 {
            let header = ConfirmHeaderV()
            header.titleLabel.text = "withdraw_text_moneyWithoutFee".localized()
            header.descLabel.text = model.withDrawAmount + " \(model.symbol)"
            self.stacker.addArrangedSubview(header)
         
            let address = ConfirmItemV()
            address.titleLabel.text = "fiat_withdraw_yourBankName".localized()
            address.descLabel.text = model.bankAccount
            self.stacker.addArrangedSubview(address)

            let bankCardNumber = ConfirmItemV()
            bankCardNumber.titleLabel.text = "b2c_text_bankNo".localized()
            bankCardNumber.descLabel.text = model.bankCardNumber
            bankCardNumber.showTrustedLabel(false)
            self.stacker.addArrangedSubview(bankCardNumber)
            
            let memo = ConfirmItemV()
            memo.titleLabel.text = "fast_inr_bank_tips".localized()
            memo.descLabel.text = model.memo
            memo.showTrustedLabel(false)
            self.stacker.addArrangedSubview(memo)
      

            let mainnet = ConfirmItemV()
            mainnet.titleLabel.text = "otc_text_bankName".localized()
            mainnet.descLabel.text = model.bankNameShow
            self.stacker.addArrangedSubview(mainnet)
            
            let seperator = UIView()
            seperator.backgroundColor = UIColor.ThemeView.seperator
            self.stacker.addArrangedSubview(seperator)
            seperator.snp.makeConstraints { make in
                make.height.equalTo(1)
            }
  
            let amount = ConfirmItemV()
            amount.titleLabel.text = "charge_text_volume".localized()
            amount.descLabel.text = model.totalAmount  + " \(model.symbol)"
            self.stacker.addArrangedSubview(amount)
            

            if model.fee.isBiggerThan("0") {
                let fee = ConfirmItemV()
                fee.titleLabel.text = "withdraw_text_fee".localized()
                fee.descLabel.text = model.fee + " \(model.symbol)"
                self.stacker.addArrangedSubview(fee)
            }
            header.snp.makeConstraints { make in
                make.height.equalTo(70)
            }
        }
    }
    
    
}
