//
//  EXAssetsHistoryCell.swift
//  Chainup
//
//  Created by wangdong on 2023/10/29.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXAssetsHistoryCell: EXChargeHistoryCell {
    
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var middleItemView: UIView!
//    @IBOutlet weak var leftTitleLabel: UILabel!
//    @IBOutlet weak var middleTitleLabel: UILabel!
//    @IBOutlet weak var rightTitleLabel: UILabel!
//
//    @IBOutlet weak var leftValueLabel: UILabel!
//    @IBOutlet weak var middleValueLabel: UILabel!
//    @IBOutlet weak var rightValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setData() {
        leftTitleLabel.text = "charge_text_date".localized()
        middleTitleLabel.text = "charge_text_volume".localized()
        rightTitleLabel.text = "charge_text_state".localized()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindListData(_ fianceItem:FinanceItem, scene: EXJournalListSceneKey){

        if scene == .deposit || scene == .withdraw {
            leftValueLabel.text = fianceItem.createdAtTime
            middleValueLabel.text = fianceItem.amount.formatAmount(fianceItem.coinSymbol,holdZero: false)
            rightValueLabel.text = fianceItem.status_text
            
            if scene == .deposit {
                titleLabel.text = "assets_action_chargeCoin".localized()
            }
            else if scene == .withdraw {
                titleLabel.text = "assets_action_withdraw".localized()
            }
        }
        else if scene == .otctransfer {
            
            rightTitleLabel.text = "charge_text_volume".localized()
            
            middleTitleLabel.isHidden = true
            middleValueLabel.isHidden = true
            
            leftValueLabel.text = fianceItem.createdAtTime
            rightValueLabel.text = fianceItem.amount.formatAmount(fianceItem.coinSymbol,holdZero: false)
            titleLabel.text = fianceItem.status_text
        }
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
            titleLabel.text = model.status_text
        }
        leftValueLabel.text = model.createdAtTime
        middleTitleLabel.text = "charge_text_volume".localized() + " " + "(" + model.coinSymbol.aliasName() + ")"
        middleValueLabel.text = model.amount.formatAmount(model.coinSymbol,holdZero: false)
        rightValueLabel.text = model.status_text
    }
    
}
