//
//  EXLeverageTransferRecordCell.swift
//  Chainup
//
//  Created by ljw on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXLeverageTransferRecordCell: UITableViewCell {

    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var amountLab: UILabel!
    
    @IBOutlet weak var typeLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.ThemeView.bg
    }
    func setModel(model : EXLeveTransferListModel) {
        timeLab.text = DateTools.strToTimeString(model.createTime, dateFormat: "yyyy-MM-dd HH:mm:ss")
        amountLab.text = model.amount.formatAmount(model.coinSymbol,isLeverage: true)
        if model.transferType == "1" {
            typeLab.text = "coin_to_leverage".localized()
        }else if model.transferType == "2"{
            typeLab.text = "leverage_to_coin".localized()
        }
        
    }
    
    func setSwapModel(model : SLSwapTransferListModel) {
        timeLab.text = model.createTime
        amountLab.text = model.amount.formatAmount(model.coinSymbol)
//        if model.status == "1" {
//            typeLab.text = "contract_bb_transfer_to_contract".localized()
//        }else if model.status == "2"{
//            typeLab.text = "contract_contract_transfer_to_bb".localized()
//        }
        typeLab.text = model.status_text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
