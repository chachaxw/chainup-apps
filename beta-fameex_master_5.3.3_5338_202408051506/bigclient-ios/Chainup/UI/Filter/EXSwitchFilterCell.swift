//
//  EXSwitchFilterCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/2.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXSwitchFilterCell: UITableViewCell {

    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var exSwitch: EXSwitch!
    typealias SwitchCallback = (Bool) -> ()
    var itemDidSwitchBlock : SwitchCallback?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.backgroundColor = UIColor.ThemeView.bg
        self.selectionStyle = .none
        exSwitch.onValueChangeCallback = {[weak self] isON in
            self?.swtichValueChanged(isON)
        }
        // Initialization code
    }
    
    func bindModel(_ model:EXFilterDataModel,lastValue:String?) {
        if let lastSetting = lastValue {
            exSwitch.setOn(isOn: (lastSetting == "1"))
        }else {
            exSwitch.setOn(isOn: false)
        }
        cellTitle.text = model.title
    }
    
    func swtichValueChanged(_ isOn: Bool) {
        itemDidSwitchBlock?(isOn)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func getHeight() -> CGFloat{
        return 48
    }
    
}
