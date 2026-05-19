//
//  EXCoinSelectorView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXCoinSelectorView: NibBaseView {

    @IBOutlet var coinName: UILabel!
    @IBOutlet var selectDescLabel: UILabel!
    @IBOutlet var tapBtn: UIButton!
    @IBOutlet var arrowicon: UIImageView!
    
    typealias TappedCallback = () -> ()
    var tapCallback:TappedCallback?
    
    override func onCreate() {
        arrowicon.image = UIImage.exs_themeImageNamed(imageName: "public_icon_arrow_down")
        arrowicon.contentMode = .scaleAspectFit
        coinName.textColor = .Ex.text1
        coinName.font = .Ex.medium(14)
        selectDescLabel.font = .Ex.medium(12)
        selectDescLabel.textColor = .Ex.text2
        selectDescLabel.text = "charge_action_selectCoin".localized()
        backgroundColor = .Ex.special2
    }
    
    @IBAction func tapBtn(_ sender: Any) {
        tapCallback?()
    }
}
