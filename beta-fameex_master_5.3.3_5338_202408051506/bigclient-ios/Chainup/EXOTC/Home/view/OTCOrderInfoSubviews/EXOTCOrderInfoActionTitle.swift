//
//  EXOTCOrderInfoActionTitle.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/28.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXOTCOrderInfoActionTitle: NibBaseView {
    
    @IBOutlet var titleIcon: UIImageView!
    @IBOutlet var titlelabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var valueIcon: UIImageView!
    
    @IBOutlet var gapHeight: NSLayoutConstraint!
    
    @IBOutlet var titleLeading: NSLayoutConstraint!
    
    var titleModel:OTCOrderInfoModel?
    typealias TitleActionCallback = () -> ()
    var tapActionCallback:TitleActionCallback?
    
    var showTopGap:Bool = false {
        didSet {
            gapHeight.constant = showTopGap ? 10 : 0
        }
    }
    
    var showTitleIcon:Bool = true {
        didSet {
            titleIcon.isHidden = !showTitleIcon
            titleLeading.constant = showTitleIcon ? 10 : -16
        }
    }
    
    override func onCreate() {
        self.showTopGap = false
    }

    
    func bindModel(model:OTCOrderInfoModel?) {
        guard let detailModel = model else {
            return
        }
        self.titleModel = detailModel
        titlelabel.text = detailModel.title
        valueLabel.text = detailModel.value
        titleIcon.yy_setImage(with: URL.init(string: detailModel.titleIcon), placeholder: nil)
        valueIcon.image = UIImage.themeImageNamed(imageName: detailModel.valueIcon)
    }
    
    @IBAction func actionBtnClick(_ sender: Any) {
        tapActionCallback?()
    }
}
