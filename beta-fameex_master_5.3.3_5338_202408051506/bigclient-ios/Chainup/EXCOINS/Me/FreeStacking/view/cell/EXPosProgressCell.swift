//
//  EXPosProgressCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPosProgressCell: UITableViewCell {

    @IBOutlet weak var toutul: UILabel!
    @IBOutlet weak var progressString: UILabel!
    
    @IBOutlet weak var progress: UIProgressView!
    
    func setCellData(enity:EXPosDetailProtocolEnity){
        
        self.progressString.text = enity.progress
        
//        let number = "5%"
        progress.progress = Float(enity.progressNum / 100)
        
        let toutulString = String(enity.raiseAmount) + enity.shortName
        
        self.toutul.text = toutulString
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.progress.trackTintColor = UIColor.ThemePageControl.unselect
        self.progress.progressTintColor = UIColor.ThemeView.highlight
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
