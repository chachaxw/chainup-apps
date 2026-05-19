//
//  EXJournalAccountListCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXJournalAccountListCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    var containerView: EXTwoByTwoContainer = EXTwoByTwoContainer()
    @IBOutlet weak var attentionButton: UIButton!
    
    var handleAttentionAction: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.ThemeFont.HeadMedium
        containerView.backgroundColor = UIColor.ThemeView.bg
        self.contentView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        attentionButton.setImage(.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: CGSize(width: 12, height: 12)), for: .normal)
        
        attentionButton.setEnlargeEdgeWithTop(30, left: 30, bottom: 30, right: 30)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bindContainerModel(_ model:FinanceItem,_ scene:EXAccountType, _ transactionScene:String? = nil ) {
        if scene == .coin {
            if let title = transactionScene {
                titleLabel.text = title
            }else {
                titleLabel.text = model.transactionScene
            }
        }else if scene == .b2c {
            if let title = transactionScene {
                titleLabel.text = title
            }else {
                titleLabel.text = model.transactionScene
            }
        }else if scene == .otc {
            titleLabel.text = "assets_action_transfer".localized()
        }
        let modelA = EXTwoByTwoItemModel()
        modelA.lcontentFont = self.themeHNFont(size: 14)
        modelA.lcontentColor = UIColor.ThemeLabel.colorMedium
        
        modelA.rcontentFont = self.themeHNMediumFont(size: 14)
        modelA.rcontentColor = UIColor.ThemeLabel.colorLite
        modelA.ltitle = "charge_text_date".localized()
        modelA.rtitle = "charge_text_volume".localized()
        modelA.lcontent = model.createdAtTime
        modelA.rcontent = model.amount + " " + model.coinSymbol.aliasName()
        containerView.bindContainers([modelA])
    }
    
    func bindContractModel(_ model:ContractTransactionItem) {
        titleLabel.text = model.sceneStr
        let modelA = EXTwoByTwoItemModel()
        modelA.ltitle = "charge_text_date".localized()
        modelA.rtitle = "charge_text_volume".localized()
        modelA.lcontent = model.ctimeL.fmtTimeStr()
        modelA.rcontent = model.amountStr + " " + model.quoteSymbol
        modelA.rcontentColor = UIColor.ThemeLabel.colorLite

        let modelB = EXTwoByTwoItemModel()
        modelB.ltitle = "journalAccount_text_contract".localized()
        modelB.rtitle = "journalAccount_text_contractBalance".localized()
        modelB.lcontent = model.address
        modelB.rcontent = model.fmtAccountBalance() + " " + model.quoteSymbol
        
        containerView.bindContainers([modelA,modelB])
    }
    
//    func bindExchangeModel(_ model:EXAccountCoinMapItem, _ allbalanceSymbol:String) {
//        titleLabel.textColor = UIColor.ThemeLabel.colorHighlight
//        titleLabel.text = model.coinName.aliasName()
    func getAccountModels(_ itemModel:EXAccountCoinMapItem, _ allbalanceSymbol:String) -> [EXTwoByTwoItemModel] {
        let hasOverChargeModel = EXJournalAccountListCell.hasOverChargeAccount(symbol: itemModel.coinName)
        let privacy = XUserDefault.assetPrivacyIsOn()
        _ = EXAppMarketManager.sharedInstance.getCoinExchangeRate(itemModel.coinName)
        let unit = EXAppMarketManager.sharedInstance.getFiatCoinSymbol()
        var models:[EXTwoByTwoItemModel] = []
        
        let modelA = EXTwoByTwoItemModel()
        modelA.lcontentColor = UIColor.ThemeLabel.colorLite
        modelA.rcontentColor = UIColor.ThemeLabel.colorLite
        modelA.lcontentFont = self.themeHNMediumFont(size: 14)
        modelA.rcontentFont = self.themeHNMediumFont(size: 14)
        modelA.ltitle = "assets_text_available".localized()
        modelA.lcontent = !privacy ? itemModel.normal_balance.formatAmount(itemModel.coinName) : String.privacyString()
        
        let modelB = EXTwoByTwoItemModel()
        modelB.lcontentColor = UIColor.ThemeLabel.colorLite
        modelB.rcontentColor = UIColor.ThemeLabel.colorLite
        modelB.lcontentFont = self.themeHNMediumFont(size: 14)
        modelB.rcontentFont = self.themeHNMediumFont(size: 14)
        models.append(modelA)
        models.append(modelB)
        
        
        if hasOverChargeModel {
            modelA.rtitle = "common_text_limitAvailable".localized()
            modelA.rcontent = !privacy ? itemModel.overcharge_balance.formatAmount(itemModel.coinName) : String.privacyString()
            
            modelB.ltitle =  "assets_text_freeze".localized()
            modelB.lcontent = !privacy ? itemModel.lock_balance.formatAmount(itemModel.coinName) : String.privacyString()

            modelB.rtitle =  "assets_text_lockup".localized()
            modelB.rcontent = !privacy ? itemModel.lock_grant_divided_balance.formatAmount(itemModel.coinName) : String.privacyString()
            
            let modelC = EXTwoByTwoItemModel()
            modelC.lcontentColor = UIColor.ThemeLabel.colorLite
            modelC.rcontentColor = UIColor.ThemeLabel.colorLite
            modelC.lcontentFont = self.themeHNMediumFont(size: 14)
            modelC.rcontentFont = self.themeHNMediumFont(size: 14)
            modelC.ltitle =  "assets_text_equivalence".localized() + "(\(unit))"
            modelC.lcontent =  !privacy ? itemModel.allBtcValuatin.getCaculatePrice(forSymbol:allbalanceSymbol) : String.privacyString()
            models.append(modelC)
        }else {
            modelA.rtitle = "assets_text_freeze".localized()
            modelA.rcontent = !privacy ? itemModel.lock_balance.formatAmount(itemModel.coinName) : String.privacyString()
            modelB.ltitle = "assets_text_lockup".localized()
            modelB.rtitle =  "assets_text_equivalence".localized() + "(\(unit))"
            modelB.lcontent =  !privacy ? itemModel.lock_grant_divided_balance.formatAmount(itemModel.coinName) : String.privacyString()
            modelB.rcontent = !privacy ? itemModel.allBtcValuatin.getCaculatePrice(forSymbol:allbalanceSymbol) : String.privacyString()
        }
   
        return models
    }
    
    func bindExchangeModel(_ model:EXAccountCoinMapItem, _ allbalanceSymbol:String) {
        titleLabel.textColor = UIColor.Ex.main4
        titleLabel.text = model.coinName.aliasName()
//        let privacy = XUserDefault.assetPrivacyIsOn()
//        let currency = PublicInfoManager.sharedInstance.getCoinExchangeRate(model.coinName)
//
//        let modelA = EXTwoByTwoItemModel()
//        modelA.lcontentColor = UIColor.ThemeLabel.colorLite
//        modelA.rcontentColor = UIColor.ThemeLabel.colorLite
//        modelA.lcontentFont = self.themeHNMediumFont(size: 14)
//        modelA.rcontentFont = self.themeHNMediumFont(size: 14)
//
//        modelA.ltitle = "assets_text_available".localized()
//        modelA.rtitle = "assets_text_freeze".localized()
//        modelA.lcontent = !privacy ? model.normal_balance.formatAmount(model.coinName) : String.privacyString()
//        modelA.rcontent = !privacy ? model.lock_balance.formatAmount(model.coinName) : String.privacyString()
//
//        let modelB = EXTwoByTwoItemModel()
//        modelB.lcontentColor = UIColor.ThemeLabel.colorLite
//        modelB.rcontentColor = UIColor.ThemeLabel.colorLite
//        modelB.lcontentFont = self.themeHNMediumFont(size: 14)
//        modelB.rcontentFont = self.themeHNMediumFont(size: 14)
//
//        modelB.ltitle = "assets_text_lockup".localized()
//        modelB.rtitle =  "assets_text_equivalence".localized() + "(\(currency.0))"
//        modelB.lcontent =  !privacy ? model.lock_grant_divided_balance.formatAmount(model.coinName) : String.privacyString()
//        modelB.rcontent = !privacy ? model.allBtcValuatin.getCaculatePrice(forSymbol:allbalanceSymbol) : String.privacyString()
//        model.withdrawOpen
//        model.depositOpen
        
        var tips: String?
        attentionButton.isHidden = !(model.withdrawOpen == "0" || model.depositOpen == "0")
        
        if model.withdrawOpen == "0" && model.depositOpen == "0" {
            tips = model.coinName.aliasName() + " " + "assets_suspend_deposit_Withdraw".localized()
        }
        else if model.withdrawOpen == "0" {
            tips = model.coinName.aliasName() + " " + "assets_suspend_withdraw".localized()
        }
        else if model.depositOpen == "0" {
            tips = model.coinName.aliasName() + " " + "assets_suspend_deposit".localized()
        }
        
        var actionHandler: (() -> ())? = nil
        
        if let _ = tips {
            actionHandler = {
                let alert = EXAssetsAttectionAlert()
                alert.contentLabel.text = tips
                EXAlert.showAlert(alertView: alert, offset: 30)
            }
        }
        
        handleAttentionAction = actionHandler
        
        containerView.bindContainers(self.getAccountModels(model, allbalanceSymbol))

    }
    
    static func hasOverChargeAccount(symbol:String) ->Bool {
        return EXAppMarketManager.sharedInstance.getCoinEntity(symbol)?.isOvercharge == "1" 
    }
    
    @IBAction func onAttectionAction(_ sender: Any) {
        handleAttentionAction?()
    }
}





class EXJournalAccountOtcListCell: UITableViewCell {
    
    lazy var titleL: UILabel = {
        let v = UILabel(text: "assets_action_transfer".localized(), font: .Ex.regular(16), textColor: .Ex.text1, alignment: .left)
        return v
    }()
    
    lazy var leftTopL: UILabel = {
        let v = UILabel(text: "charge_text_date".localized(), font: .Ex.regular(12), textColor: .Ex.text3, alignment: .left)
        return v
    }()
    
    lazy var middleTopL: UILabel = {
        let v = UILabel(text: "charge_text_volume".localized(), font: .Ex.regular(12), textColor: .Ex.text3, alignment: .center)
        return v
    }()
    
    lazy var rightTopL: UILabel = {
        let v = UILabel(text: "otc_state".localized(), font: .Ex.regular(12), textColor: .Ex.text3, alignment: .right)
        return v
    }()
    
    lazy var leftBottomL: UILabel = {
        let v = UILabel(text: "--", font: .Ex.regular(14), textColor: .Ex.text1, alignment: .left)
        v.numberOfLines = 2
        return v
    }()
    
    lazy var middleBottomL: UILabel = {
        let v = UILabel(text: "--", font: .Ex.regular(14), textColor: .Ex.text1, alignment: .center)
        v.numberOfLines = 2
        return v
    }()
    
    lazy var rightBottomL: UILabel = {
        let v = UILabel(text: "--", font: .Ex.regular(14), textColor: .Ex.text1, alignment: .right)
        v.numberOfLines = 2
        return v
    }()
    
    lazy var bottomLineV: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill5
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        onCreate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onCreate() {
        contentView.backgroundColor = UIColor.ThemeView.bg
        contentView.addSubViews([titleL, leftTopL, leftBottomL,
                                 middleTopL, middleBottomL, rightTopL, rightBottomL])
        titleL.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(16)
        }
        
        leftTopL.snp.makeConstraints { make in
            make.top.equalTo(titleL.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(16)
        }
        middleTopL.snp.makeConstraints { make in
            make.left.equalTo(leftTopL.snp.right)
            make.centerY.height.width.equalTo(leftTopL)
        }
        rightTopL.snp.makeConstraints { make in
            make.left.equalTo(middleTopL.snp.right)
            make.right.equalToSuperview().offset(-15)
            make.width.height.centerY.equalTo(middleTopL)
        }
        
        ///
        leftBottomL.snp.makeConstraints { make in
            make.left.equalTo(leftTopL)
            make.top.equalTo(leftTopL.snp.bottom).offset(5)
            make.width.equalTo(leftTopL)
            make.bottom.lessThanOrEqualToSuperview()
        }
        middleBottomL.snp.makeConstraints { make in
            make.top.equalTo(leftBottomL)
            make.width.centerX.equalTo(middleTopL)
            make.bottom.lessThanOrEqualToSuperview()
        }
        rightBottomL.snp.makeConstraints { make in
            make.top.equalTo(leftBottomL)
            make.centerX.width.equalTo(rightTopL)
            make.bottom.lessThanOrEqualToSuperview()
        }
      
    }
    
    func bindContainerModel(_ model:FinanceItem) {
        self.leftBottomL.text = model.createdAtTime
        self.middleBottomL.text = model.amount + " " + model.coinSymbol.aliasName()
        self.rightBottomL.text = model.status_text
    }
    
}
