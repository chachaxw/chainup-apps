//
//  EXSideBySideLabel.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/13.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXSideBySideLabel: NibBaseView {

    @IBOutlet var leftSideLabel: UILabel!
    @IBOutlet var rightSideLabel: UILabel!
    
    override func onCreate() {
        self.backgroundColor = UIColor.ThemekLine.navBg
        leftSideLabel.minimumRegular()
        rightSideLabel.minimumRegular()
    }
    
}
