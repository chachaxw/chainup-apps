//
//  EXPosIncomeCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/12.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPosIncomeCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var amount: UILabel!
    
    func setCellData(cellData:[String:String]) {
        
        time.text = cellData["time"]
        amount.text = cellData["amount"]
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
