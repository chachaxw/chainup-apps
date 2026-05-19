//
//  EXToDoListView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXToDoListView: NibBaseView {
    @IBOutlet var icon: UIImageView!
    @IBOutlet var title: UILabel!
    var isDone:Bool = false {
        didSet {
            self.udpateState()
        }
    }
    
    override func onCreate() {

    }
    
    func udpateState() {
        if isDone {
            icon.image = EXKitBundle.svgImage(named: "public_checked")
        }else {
            icon.image = UIImage.themeImageNamed(imageName: "fiat_unfinished")
        }
    }


}
