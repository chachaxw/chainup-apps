//
//  EXPosPositionCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/8.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPosPositionCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var state: UILabel!
    @IBOutlet weak var flageIcon: UIImageView!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var date: UILabel!
    func setCellData(_ cellData:EXPosHomeProjectEntity) {
        
        self.name.text = cellData.baseCoin
        self.date.text = cellData.name
        if let url = URL.init(string: cellData.logo){
            self.icon.yy_setImage(with: url, placeholder: nil)
        }
        self.state.text = EXPosInfoServer.handProgectStatus(type: cellData.projectType,status: cellData.status)
        if(cellData.status == 2){
            self.state.textColor = UIColor.ThemeLabel.colorHighlight
        }else{
            self.state.textColor = UIColor.ThemeLabel.colorMedium
        }

        self.rate.text = "\(cellData.gainRate)\("%")"
        
        if cellData.status < 2{
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
