//
//  EXJournalDetailCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXJournalDetailCell: UITableViewCell {
    @IBOutlet var descTitle : UILabel!
    @IBOutlet var descConent : UILabel!
    @IBOutlet var actionBtn: UIButton!
    @IBOutlet var rightConstaint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        actionBtn.setImage(UIImage.themeImageNamed(imageName: "trade_compared"), for: UIControl.State.normal)
        // Initialization code
    }
    @IBAction func copyed(_ sender: Any) {
        if let value = descConent.text,value.count > 0 {
            UIPasteboard.general.string = value
            EXAlert.showSuccess(msg: "common_tip_copySuccess".localized())
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateTitle(_ title:String,_ desc:String, _ useCopy:Bool = false ) {
        descTitle.text = title
        descConent.text = desc
        actionBtn.isHidden = !useCopy
        rightConstaint.constant = useCopy ? 44 : 15
    }
    
}
