//
//  EXMarketDetailRecordCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/30.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXMarketDetailRecordCell: UITableViewCell {
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var middleLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = UIColor.ThemekLine.viewBg
        extSetCell(UIColor.ThemekLine.viewBg)
        // Initialization code
    }
    
    func bindNames(leftTitle:String,middleTitle:String,rightTitle:String) {
        leftLabel.text = leftTitle
        middleLabel.text = middleTitle
        rightLabel.text = rightTitle
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
