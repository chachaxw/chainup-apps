//
//  EXActionSheetButtonItem.swift
//  Chainup
//
//  Created by liuxuan on 2020/3/8.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit

class EXActionSheetButtonItem: NibBaseView {
    
    @IBOutlet var actionBtn: EXButton!
    @IBOutlet weak var lineView: UIView!
    
    override func onCreate() {
        self.configure()
    }
    
    func configure() {
        actionBtn.setFont(.ThemeFont.BodyMedium)
    }
}
