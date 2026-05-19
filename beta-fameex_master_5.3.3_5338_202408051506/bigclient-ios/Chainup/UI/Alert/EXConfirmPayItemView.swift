//
//  EXConfirmPayItemView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/1.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXConfirmPayItemView: NibBaseView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    typealias AlertCallback = (Int) -> ()
    var alertCallback : AlertCallback?
    
}
