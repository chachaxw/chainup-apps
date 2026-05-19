//
//  EXAssetsPieChartActionSectionView.swift
//  Chainup
//
//  Created by wangdong on 2023/9/9.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit
class EXAssetsPieChartActionView: NibBaseView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    var didTapAction: (() -> ())?
    
    var selected: Bool = false {
        didSet {
            updateStye()
        }
    }
    
    func updateStye() {
        mainView.layer.borderColor = selected ? UIColor.ThemeView.highlight.cgColor : UIColor.ThemeView.seperator.cgColor
    }
    
    override func onCreate() {
        selected = false
    }

    
    @IBAction func onTapAction(_ sender: Any) {
        didTapAction?()
    }
    
}
