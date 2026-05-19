//
//  HiDebugColorCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/5.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class HiDebugColorCell: UITableViewCell {

    @IBOutlet var colorName: UILabel!
    @IBOutlet var colorView: UIView!
    @IBOutlet var colorValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
