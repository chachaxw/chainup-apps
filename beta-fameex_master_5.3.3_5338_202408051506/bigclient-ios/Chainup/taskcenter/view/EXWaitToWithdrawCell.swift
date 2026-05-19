//
//  EXWaitToWithdrawCell.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXWaitToWithdrawCell: EXBaseCell {
    
    var item :EXUnWithdrawalItem? {
        didSet{
            guard let item = item else { return }
            coinLabel.text = item.coin
            coinAmountLabel.text = item.unWithdrawAmount
            rmbAmountLabel.text = item.usdtAmount + " " + "USDT"
            let result = EXAppConfigManager.sharedInstance.configVm.cfgModel.findCoin(coin: item.coin)
            img.yy_setImage(with: URL(string: result.coinImageUrl), placeholder: UIImage.svg_themeImageNamed(imageName: "task_coin"))
            coinShowNameLabel.text = result.showName
            
        }
    }
    //MARK: UI
    override func setUpView() {
        self.contentView.addSubViews([img,coinLabel,coinAmountLabel,coinShowNameLabel,rmbAmountLabel,timeLabel])
        img.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        coinLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(44)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(19)
        }
        coinShowNameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(44)
            make.top.equalTo(coinLabel.snp.bottom).offset(2)
            make.height.equalTo(14)
        }
        
        coinAmountLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(19)
        }
        rmbAmountLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(coinAmountLabel.snp.bottom).offset(2)
        }
        
    }
    
    
    //MARK: lazy
    lazy var img : UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var coinLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var coinAmountLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var coinShowNameLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text3, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var rmbAmountLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text2, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var timeLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text2, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        label.isHidden = true
        return label
    }()
    
    
}

//tixianjilu
class EXWithdrawRecoadCell: EXWaitToWithdrawCell{
    
    var withdraw:  EXWithdrawalItem? {
        didSet{
            guard let withdraw  = withdraw  else { return }
            coinLabel.text = withdraw.coin
            coinAmountLabel.text = withdraw.amount
            
            let interval = TimeInterval.init(withdraw.withdrawTime.bigDiv("1000")) ?? 0
            timeLabel.text  = DateTools.dateToString(interval)
            rmbAmountLabel.text = withdraw.usdtAmount + " " + "USDT"
            let result = EXAppConfigManager.sharedInstance.configVm.cfgModel.findCoin(coin: withdraw.coin)
            img.yy_setImage(with: URL(string: result.coinImageUrl),placeholder: UIImage.svg_themeImageNamed(imageName: "task_coin"))
            coinShowNameLabel.text = result.showName
            
        }
    }
    override func setUpView() {
        super.setUpView()
        timeLabel.isHidden = false
        timeLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(44)
            make.top.equalTo(coinLabel.snp.bottom).offset(2)
            make.height.equalTo(14)
        }
        coinShowNameLabel.snp.remakeConstraints { make in
            make.left.equalTo(coinLabel.snp.right).offset(2)
            make.bottom.equalTo(coinLabel.snp.bottom)
            make.height.equalTo(14)
        }
    }
}
