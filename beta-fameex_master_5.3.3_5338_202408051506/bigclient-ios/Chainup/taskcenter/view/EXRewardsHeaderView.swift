//
//  EXRewardsHeaderView.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import Swap
class EXRewardsHeaderView: EXView {
    var taskHome: EXTaskHomeModel?
    var unWithdrawal: EXUserUnWithdrawalData? {
        didSet{
            refershHeader()
        }
       
    }
    var withDrawInfo: EXWithdrawRewardinfo? {
        didSet{
//            guard let item  = withDrawInfo else { return }
         refershHeader()
        }
    }
    
    func refershHeader(){
        let text = "myReward_text4".localized()
        let amount = withDrawInfo?.leftWithdrawPendingUsdt ?? "0"
        let amountText  = amount + " USDT"
        let showText = String(format: text, amount, "assets_text_exchange".localized())
        let attr = showText.attributeString(specalSubStr: amountText, specailAttri:[
            NSAttributedString.Key.font: UIFont.Ex.medium(12),
            NSAttributedString.Key.foregroundColor: UIColor.Ex.text1],
             commonAttri: [
                 NSAttributedString.Key.font: UIFont.Ex.regular(12),
                 NSAttributedString.Key.foregroundColor:UIColor.Ex.text2
             ])
        desLabel.attributedText = attr
        
        
        let totalAmout = (self.unWithdrawal?.usdtAmount ?? "0")
        let totalAmoutStr = totalAmout + " USDT"

        var totalAmoutTextColor: UIColor = .Ex.text2
        if totalAmout.greaterThan("0") {
            totalAmoutTextColor = .Ex.main1
        }
        
        let attr2 = totalAmoutStr.attributeString(specalSubStr: totalAmout, specailAttri:[
            NSAttributedString.Key.font: UIFont.Ex.medium(28),
            NSAttributedString.Key.foregroundColor: totalAmoutTextColor],
             commonAttri: [
                 NSAttributedString.Key.font: UIFont.Ex.regular(16),
                 NSAttributedString.Key.foregroundColor:UIColor.Ex.text1
             ])
        
        amountLabel.attributedText = attr2
         
        desLabel.isHidden = true
        withdrawBtn.isEnabled = false
        let switchOpen = (self.taskHome?.withdrawSwitch ?? 0) == 1
        if switchOpen  {
            if amount.lessThanOrEqual("0") || amount.isEmpty{
                withdrawBtn.isEnabled = true
            }
        }
        if amount.greaterThan("0") {
            desLabel.isHidden = false
        }
    }
    
   var doWithdrawCallback:  EXComVoidBlock?
   static func getTotalHeightShowDesLabel(show: Bool) -> CGFloat{
        var total: CGFloat = 135
        if show == false {
            total -= (8 + 18)
        }
        return total
    }
    
    override func setupView() {
        self.addSubViews([titleLabel,amountLabel,withdrawBtn,desLabel])
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(32)
            make.height.equalTo(16)
        }
        amountLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.height.equalTo(33)
        }
       
        withdrawBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(43)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
            make.width.equalTo(87)
        }
        
        desLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(18)
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"myReward_text3".localized(), font: .Ex.medium(14), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(16), textColor: .Ex.main1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var usdtLabel: UILabel = {
        let label = UILabel(text:"USDT", font: .Ex.medium(14), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var desLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(14), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var withdrawBtn: EXButton = {
        let btn = EXButton()
        btn.setTitle("myReward_text6".localized(), for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(clickBtn(btn:)), for: UIControl.Event.touchUpInside)
        btn.isEnabled = false
        btn.selectStyle = .blueColor
        return btn
    }()
    
    
    @objc func clickBtn(btn:EXButton){
//        print("提现")
        let alert = EXCommonAlert()
        alert.configAlert(tipImage:true, title: "myReward_text6".localized(), message:  "myReward_text8".localized(),cancelBtnTitle: "common_text_btnCancel".localized(), sureBtnTitle: "common_text_btnConfirm".localized(), btnLayoutStyle: .horizontal, alertCallBack: { type in
            if type == .sure {
                self.doWithdrawCallback?()
            }
        })
        EXAlert.showAlert(alertView: alert)
    }
}
