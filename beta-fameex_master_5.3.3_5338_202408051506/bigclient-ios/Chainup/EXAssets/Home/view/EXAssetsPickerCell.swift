//
//  EXAssetsPickerCell.swift
//  Chainup
//
//  Created by wangdong on 2023/9/11.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXAssetsPickerCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightTopLabel: UILabel!
    @IBOutlet weak var rightBottomLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
