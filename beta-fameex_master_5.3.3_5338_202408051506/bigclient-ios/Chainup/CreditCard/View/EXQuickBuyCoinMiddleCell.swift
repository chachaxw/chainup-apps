//
//  EXQuickBuyCoinMiddleCell.swift
//  Chainup
//
//  Created by 柴伟东 on 2022/2/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
import Swap


class EXQuickBuyCoinMiddleCell: EXCustomBaseView {

    var changeCallBack: EXComVoidBlock?
//    lazy var img : UIImageView = {
//        let arrowImmg = UIImageView()
//        arrowImmg.backgroundColor = .red
//        arrowImmg.contentMode = .scaleAspectFit
//        arrowImmg.image = UIImage.exs_themeImageNamed(imageName: "contract_icon_morefunctions_fundstransfer").yy_imageByRotateRight90()
//        return arrowImmg
//    }()
    
    lazy var transferBtn : RepeatButton = {
        let btn = RepeatButton()
        let img = UIImage.exs_themeImageNamed(imageName: "contract_icon_morefunctions_fundstransfer").yy_imageByRotateRight90()
        btn.setImage(img, for: .normal)
        btn.setImage(img, for: .selected)
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(change), for: .touchUpInside)
        return btn
    }()
    
    
    @objc func change(){
        changeCallBack?()
    }
    
    override func setSubView() {
        self.addSubViews([transferBtn])
        transferBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(38)
        }
    }
    
    

}
