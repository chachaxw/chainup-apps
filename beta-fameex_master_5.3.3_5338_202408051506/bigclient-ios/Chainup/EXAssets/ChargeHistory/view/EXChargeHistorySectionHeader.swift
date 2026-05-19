//
//  EXChargeHistorySectionHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/21.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXChargeHistorySectionHeader: NibBaseView {
    @IBOutlet var leftTitle: UILabel!
    @IBOutlet var middleTitle: UILabel!
    @IBOutlet var rightTitle: UILabel!
    
    override func onCreate() {
        
        leftTitle.textColor = UIColor.ThemeLabel.colorDark
        middleTitle.textColor = UIColor.ThemeLabel.colorDark
        rightTitle.textColor = UIColor.ThemeLabel.colorDark
    }
    
    func updateTitle(left:String,middle:String,right:String){
        leftTitle.text = left
        middleTitle.text = middle
        rightTitle.text = right
    }
    
}
