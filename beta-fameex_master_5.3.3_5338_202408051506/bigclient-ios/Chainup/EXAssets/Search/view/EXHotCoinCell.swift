//
//  EXHotCoinCell.swift
//  Chainup
//
//  Created by wangdong on 2023/11/2.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXHotCoinCell: NibBaseView {

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var middleButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    override func onCreate() {
        [leftButton,middleButton,rightButton].forEach({
            $0?.backgroundColor = .Ex.special2
            $0?.setTitleColor(.Ex.text2, for: .normal)
        })
    }
    func setData(_ dataArray: Array<String>) {
        leftButton.setTitle(dataArray.first, for: .normal)
        if dataArray.count == 2 {
            middleButton.setTitle(dataArray[1], for: .normal)
            rightButton.isHidden = true
        }
        else if dataArray.count == 1 {
            middleButton.isHidden = true
            rightButton.isHidden = true
        }
        else {
            middleButton.setTitle(dataArray[1], for: .normal)
            rightButton.setTitle(dataArray.last, for: .normal)
        }
    }
}
