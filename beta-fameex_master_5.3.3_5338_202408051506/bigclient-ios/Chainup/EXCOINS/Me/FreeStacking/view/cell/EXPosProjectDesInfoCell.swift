//
//  EXPosProjectDesInfoCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXPosProjectDesInfoCell: UITableViewCell {

    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var porojectInfo: UILabel!
    @IBOutlet weak var rate: UILabel!
    
    
 func setCellData(enity:EXPosDetailProtocolEnity) {
    
        projectName.text = enity.name
        porojectInfo.text = enity.title
        rate.text = "\(enity.gainRate)\("%")"
    }
    
    func setCellData(enity:EXPosDetailPostionEnity){
        projectName.text = enity.name
        porojectInfo.text = enity.title
        rate.text = "\(enity.gainRate)\("%")"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
         self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
