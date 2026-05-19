//
//  EXLeverageCoinSearchCell.swift
//  Chainup
//
//  Created by ljw on 2023/11/7.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXLeverageCoinSearchCell: UITableViewCell {

    @IBOutlet weak var coinName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        extSetCell(.clear, selStyle: .none, isRemoveSelectedBackgroundView: true)
        coinName.font = .Ex.medium(16)
        coinName.textColor = .Ex.text1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
