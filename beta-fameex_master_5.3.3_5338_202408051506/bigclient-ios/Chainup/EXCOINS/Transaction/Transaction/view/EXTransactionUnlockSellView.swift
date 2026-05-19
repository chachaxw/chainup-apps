//
//  EXTransactionUnlockSellView.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXTransactionUnlockSellView: UIView {

    typealias ClickSellBtnBlock = () -> ()
    var clickSellBtnBlock : ClickSellBtnBlock?
    
    var entity = CoinMapEntity()
    
    var item = EXAccountCoinMapItem()
    
    //Recharge not unlocked
    lazy var rechargeLockView : EXTransactionUnlockSellDetailView = {
        let view = EXTransactionUnlockSellDetailView()
        view.extUseAutoLayout()
        view.setLeft("transaction_text_rechargeNoUnlocked".localized())
        return view
    }()
    
    //Quantity available for sale
    lazy var canSellView : EXTransactionUnlockSellDetailView = {
        let view = EXTransactionUnlockSellDetailView()
        view.extUseAutoLayout()
        view.setLeft("transaction_text_saleableQuantity".localized())
        return view
    }()
    
    //Mode Description
    lazy var modelView : EXTransactionModelSpecificationView = {
        let view = EXTransactionModelSpecificationView()
        view.extUseAutoLayout()
        return view
    }()
    
    //One click sell button
    lazy var sellBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.backgroundColor = UIColor.ThemekLine.down
        btn.extSetCornerRadius(4)
        btn.setTitle("transaction_text_unlockSell".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadBold
        btn.extSetAddTarget(self, #selector(clickSellBtn))
        return btn
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([rechargeLockView,canSellView,modelView,sellBtn,lineV])
        rechargeLockView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(17)
        }
        canSellView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(rechargeLockView.snp.bottom).offset(14)
            make.height.equalTo(17)
        }
        modelView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(canSellView.snp.bottom).offset(14)
            make.height.equalTo(123)
        }
        sellBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(lineV.snp.top).offset(-20)
            make.height.equalTo(44)
        }
        lineV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    func setView(){
        self.getAccountBlance()
        self.modelView.setTextView(entity.coinListEntity().getOverchargeMsg())
    }
    
    //Obtain account information
    func getAccountBlance(){
        EXAccountBalanceManager.manager.updateExchangeAccountBalance()
        EXAccountBalanceManager.manager.accountCallback = {[weak self] model in
            guard let mySelf = self else{return}
            self?.item = model.getItemWithCoinName(mySelf.entity.coinName)
            self?.setAccountView()
        }
    }
    
    func setAccountView(){
//        var precision = 8
//        if let precision1 = Int(entity.coinListEntity.showPrecision){
//            precision = precision1
//        }
        let overcharge = self.item.overcharge_balance == "" ? "0" : self.item.overcharge_balance
//        let overcharge_balance = (overcharge.decimalNumberWithDouble()  as NSString).decimalString(precision)
        canSellView.setRight(overcharge + " " + self.item.coinName.aliasName())

        let lock_position = self.item.lock_position_v2_amount == "" ? "0" : self.item.lock_position_v2_amount
//        let lock_position_v2_amount = (lock_position.decimalNumberWithDouble()  as NSString).decimalString(precision)
        rechargeLockView.setRight(lock_position + " " + self.item.coinName.aliasName())
    }
    
    //Click on the sell button
    @objc func clickSellBtn(){
        self.clickSellBtnBlock?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXTransactionUnlockSellDetailView : UIView{
    
    lazy var leftLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        label.layoutIfNeeded()
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([leftLabel,rightLabel])
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(17)
            make.right.equalTo(rightLabel.snp.left).offset(-5)
        }
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(17)
        }
    }
    
    func setLeft(_ str : String){
        leftLabel.text = str
    }
    
    func setRight(_ str : String){
        rightLabel.text = str
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXTransactionModelSpecificationView : UIView{
    
    lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.text = "transaction_text_modelSpecification".localized()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var textView : UITextView = {
        let view = UITextView()
        view.extUseAutoLayout()
        view.isEditable = false
        view.textColor = UIColor.ThemeLabel.colorLite
        view.font = UIFont.ThemeFont.BodyRegular
        view.showsVerticalScrollIndicator = false
        view.extSetBorderWidth(0.5, color: UIColor.ThemeView.seperator)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([titleLabel,textView])
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview()
            make.height.equalTo(17)
            make.right.equalToSuperview().offset(-15)
        }
        textView.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
    }
    
    func setTextView(_ str : String){
        textView.text = str
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

