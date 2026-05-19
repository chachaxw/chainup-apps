//
//  EXIncomeCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXIncomeCell: UITableViewCell {

    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var count: UILabel!
    func setCellData(enity:UserGainList)  {
        
        if enity.special != nil {
            
            self.time.font = UIFont.ThemeFont.MinimumRegular
            self.count.font = UIFont.ThemeFont.MinimumRegular
            self.time.textColor = UIColor.ThemeLabel.colorMedium
            self.count.textColor = UIColor.ThemeLabel.colorMedium
        }else {
            self.time.font = UIFont.ThemeFont.BodyRegular
            self.count.font = UIFont.ThemeFont.BodyRegular
            self.time.textColor = UIColor.ThemeLabel.colorLite
            self.count.textColor = UIColor.ThemeLabel.colorLite
        }
        
        self.time.text = enity.timeShow
        self.count.text = enity.gainAmount
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
