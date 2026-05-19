//
//  EXNaviDrawerView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/24.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXNaviDrawerView: NibBaseView {
    @IBOutlet var verticalLine: UIView!
    @IBOutlet var iconBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tapBtn: UIButton!
    lazy var tagView :EXTagView = {
        let view = EXTagView.commonTagView()
        view.isHidden = true
        return view
    }()
    
    override func onCreate() {
        self.backgroundColor = UIColor.ThemeView.bg 
        iconBtn.setImage(UIImage.themeImageNamed(imageName: "trade_icon_switchcurrency"), for: .normal)
        iconBtn.setTitle("", for: .normal)
        titleLabel.font = UIFont.ThemeFont.H3Bold
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        self.addSubview(tagView)
    }
    
    func showTag(_ originTitle:String) {
        let symbol = EXAppMarketManager.sharedInstance.getMarketLeft(originTitle)
        let marketTag = EXAppMarketManager.sharedInstance.getCoinMarketTag(symbol)
        if marketTag.isEmpty {
            tagView.isHidden = true
        }else {
            tagView.isHidden = false
            tagView.text = marketTag
//            tagView.setTitle(marketTag, for: .normal)
            tagView.snp.remakeConstraints { (make) in
                make.left.equalTo(titleLabel.snp.right).offset(5)
                make.centerY.equalTo(titleLabel)
                make.width.equalTo(10)
                make.height.equalTo(10)
            }
            tagView.titleResizeSize()
        }
    }
    
    func bind(_ title:String) {
        titleLabel.text = title
    }
    
}
