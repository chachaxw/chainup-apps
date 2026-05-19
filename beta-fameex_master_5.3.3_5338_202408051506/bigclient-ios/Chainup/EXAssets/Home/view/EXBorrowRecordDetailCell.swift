//
//  EXBorrowRecordDetailCell.swift
//  Chainup
//
//  Created by ljw on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXBorrowRecordDetailCell: UITableViewCell {

    @IBOutlet weak var titleSymbolLab: UILabel!
    @IBOutlet weak var timeLab: UILabel!
    @IBOutlet weak var amountLab: UILabel!
    @IBOutlet weak var amountTitleLab: UILabel!
    @IBOutlet weak var typeTitleLab: UILabel!
    @IBOutlet weak var typeLab: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        amountTitleLab.text = "charge_text_volume".localized()
        typeTitleLab.text = "contract_text_type".localized()
    }
    func setModel(model : EXReturnInfoListModel) {
        titleSymbolLab.text = model.coin
        timeLab.text = DateTools.strToTimeString(model.repaymentTime, dateFormat: "yyyy-MM-dd HH:mm:ss")
        amountLab.text = model.returnMoney.formatAmount(model.coin,isLeverage: true)
        if model.type == "1" {
            typeLab.text = "leverage_principal".localized()
        }else if model.type == "2" {
            typeLab.text = "leverage_interest".localized()
        }else if model.type == "3" {
            typeLab.text = "leverage_principal_interest".localized()//change
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

