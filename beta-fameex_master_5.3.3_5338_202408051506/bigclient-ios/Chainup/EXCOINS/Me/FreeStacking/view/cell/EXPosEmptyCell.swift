//
//  EXPosEmptyCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXPosEmptyCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var message: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//         view.setView(LanguageTools.getString(key: "common_tip_nodata"), imgStr: "Norecord-icon")
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        self.icon.image = UIImage.svgImage(named: "public_nocontentyet") ?? UIImage()
        self.message.text = "common_tip_nodata".localized()
        self.message.textColor = UIColor.ThemeLabel.colorMedium
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
