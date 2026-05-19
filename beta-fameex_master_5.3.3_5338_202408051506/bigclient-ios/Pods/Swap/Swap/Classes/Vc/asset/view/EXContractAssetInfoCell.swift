//
//  EXContractAssetInfoCell.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/7.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
enum ContractAssetInfoType{
    case TotalEquity //总权益 English: Total equity
    case walletBalance
    case canUse
    case unrealizedPNL

}
class EXContractAssetInfoCell: UITableViewCell {
    //MARK: fix 修改 English: MARK: fix modification
    var assetModel : EXContractAssetModel? {
        didSet {
            if assetModel != nil {
                let privacy = EXStoreData.assetPrivacyIsOn()
                var entity = "4"
                //改为合约保证金精度 English: Change to contract margin accuracy
                let contractItem = EXSwapPublicInfo.shared.getContractsModelWithMarginCoin(marginCoin: assetModel?.originalCoin ?? "")
                if let item = contractItem{
                    entity = item.coinResultVo.marginCoinPrecision
                }
                coinLabel.text = assetModel!.symbol //.aliasName()
                accountRights.bottomLabel.text =  !privacy ? (assetModel!.totalAmount).exs_formatAmountUseDecimal(entity) : String.privacyString()
                walletBalance.bottomLabel.text = !privacy ? (assetModel!.walletBalance).exs_formatAmountUseDecimal(entity) : String.privacyString()
                canUse.bottomLabel.text = !privacy ? (assetModel!.canUseAmount).exs_formatAmountUseDecimal(entity) : String.privacyString()
                
                var amount = assetModel!.unRealizedAmount.exs_formatAmountUseDecimal(entity)
                if amount.greaterThan("0"){
                    amount = "+" + amount
                }
                unrealizedPNL.bottomLabel.text = !privacy ? amount : String.privacyString()
                unrealizedPNL.bottomLabel.textColor = assetModel?.unRealizedAmount.getValueColor()
                
            }
        }
    }
    
    /// 币种 English: /Currency
    lazy var coinLabel: UILabel = {
        let label = UILabel(text: "USDT", font: UIFont.ThemeFont.HeadBold, textColor: UIColor.Ex.main4, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    /// 总权益 English: /Total equity
    lazy var accountRights: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.setTopText("cp_total_balance1".ex_localized())
        view.showDashline = true
        view.contentAlignment = .left
        view.clickMiddleBtnBlock = { [weak self] in
            self?.showAlertType(type: .TotalEquity)
        }
        return view
    }()
   
    
    /// 钱包余额 English: /Wallet balance
    lazy var walletBalance: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.setTopText("cp_wallet_balance1".ex_localized())
        view.showDashline = true
        view.contentAlignment = .right
        view.clickMiddleBtnBlock = { [weak self] in
            self?.showAlertType(type: .walletBalance)
        }
        return view
    }()
    

    lazy var canUse: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.setTopText("cp_assets_text10".ex_localized())
//        view.showDashline = true
        view.contentAlignment = .left
        view.clickMiddleBtnBlock = { [weak self] in
            self?.showAlertType(type: .canUse)
        }
        return view
    }()
    
    ///未实现盈亏 English: /Unrealized gains and losses
    lazy var unrealizedPNL: SLSwapVerDetailView = {
        let view = SLSwapVerDetailView()
        view.setTopText("cl_roi_6".ex_localized())
        view.showDashline = true
        view.contentAlignment = .right
        view.clickMiddleBtnBlock = { [weak self] in
            self?.showAlertType(type: .unrealizedPNL)
        }
        return view
    }()
    
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.ThemeView.seperator
        return line
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initLayout() {
        self.contentView.exs_addSubViews([coinLabel,
                                      accountRights,
                                      walletBalance,
                                      canUse,
                                      unrealizedPNL,lineView])
        ext_SetCell()
        coinLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(19)
        }
        let commomH:CGFloat = 36
        accountRights.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(coinLabel.snp.bottom).offset(15)
            make.height.equalTo(commomH)
            
        }

      
        walletBalance.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(accountRights.snp.top)
            make.height.equalTo(accountRights.snp.height)
            make.width.equalTo(accountRights.snp.width)
            make.left.equalTo(accountRights.snp.right)
        }
        canUse.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(accountRights.snp.bottom).offset(12)
            make.height.equalTo(commomH)
        }
        unrealizedPNL.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(canUse.snp.top)
            make.height.equalTo(accountRights.snp.height)
            make.width.equalTo(canUse.snp.width)
            make.left.equalTo(canUse.snp.right)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
    }
    
    
    func showAlertType(type: ContractAssetInfoType){
        var title = "cp_total_balance1".ex_localized()
        var msg: String? = "cp_total_balance2".ex_localized()
        switch type{
        case .canUse:
            return
        case .TotalEquity:
            break
        case .walletBalance:
            title = "cp_wallet_balance1".ex_localized()
            msg = "cp_wallet_balance2".ex_localized()
        case .unrealizedPNL:
            title = "cl_roi_6".ex_localized()
            msg = "cp_upnl_balance".ex_localized()
        }
        let alert = EXCommonAlert()
        alert.configAlert(title: title,message: msg,onlyOneBtnTitle: "cp_extra_text28".ex_localized(),bottomOnlyOneBtn: true) { _ in
            
        }
        EXAlert.showAlert(alertView: alert)
    }
}


