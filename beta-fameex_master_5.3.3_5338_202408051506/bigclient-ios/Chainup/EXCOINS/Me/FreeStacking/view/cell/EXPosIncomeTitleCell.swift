//
//  EXPosIncomeTitleCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/17.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPosIncomeTitleCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var tail: UILabel!
    
    func setCellData(enity:UserGainList) {
        
        self.title.text = enity.timeShow
        self.tail.text = enity.gainAmount
    }
    
    func setCellConfig(config:[String:String]){
      
        self.title.text = config["title"]
        self.tail.text = config["tail"]
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
