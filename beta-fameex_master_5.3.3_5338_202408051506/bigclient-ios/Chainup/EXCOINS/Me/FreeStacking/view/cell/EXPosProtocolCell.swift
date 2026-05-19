//
//  EXPosProtocolCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXPosProtocolCell: UITableViewCell {

    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var state: UILabel!

    @IBOutlet weak var flageIcon: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var lockDay: UILabel!
    @IBOutlet weak var progress: UILabel!
    
    func setCellData(_ cellData:EXPosHomeProjectEntity) {
        
        self.coinName.text = cellData.baseCoin
        self.date.text = cellData.name
        if let url = URL.init(string: cellData.logo){
            self.icon.yy_setImage(with: url, placeholder: EXKitBundle.svgImage(named: "task_coin"))
        }
        self.state.text = EXPosInfoServer.handProgectStatus(type: cellData.projectType,status: cellData.status)
        if(cellData.status == 1){
            self.state.textColor = UIColor.ThemeLabel.colorHighlight
        }else{
            self.state.textColor = UIColor.ThemeLabel.colorMedium
        }
        self.lockDay.text = String(cellData.lockDay)
        self.rate.text = "\(cellData.gainRate)\("%")"
        self.progress.text = cellData.progress
        
        if cellData.status < 2 {
            self.flageIcon.image = EXPosInfoServer.handerFlagImage(status: cellData.labelType)
        }
        
    }
    
    override func prepareForReuse() {
        
        self.flageIcon.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.backgroundColor = UIColor.ThemeView.bg
        self.icon.image = EXKitBundle.svgImage(named: "task_coin")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
