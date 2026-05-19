//
//  EXTwoByTwoContainer.swift
//  Chainup
//
//  Created by liuxuan on 2023/5/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSTwoByTwoItemModel:NSObject {
    var ltitle:String = ""
    var lcontent:String = ""
    var rtitle:String = ""
    var rcontent:String = ""
    
    var ltitleColor:UIColor = UIColor.ThemeLabel.colorDark
    var lcontentColor:UIColor = UIColor.ThemeLabel.colorMedium
    var rtitleColor:UIColor = UIColor.ThemeLabel.colorDark
    var rcontentColor:UIColor = UIColor.ThemeLabel.colorMedium
    var lcontentFont:UIFont = UIFont.ThemeFont.BodyBold
    var rcontentFont:UIFont = UIFont.ThemeFont.BodyBold

    var rightAlignment:NSTextAlignment = .right
}

class EXSTwoByTwoContainer: UIView {
    
    var containers:[EXSTwoByTwoView] = []
    
    func bindContainers(_ items:[EXSTwoByTwoItemModel],addBlock:Bool = false ) {
        if containers.count > 0 {
            for item in containers {
                item.removeFromSuperview()
            }
            containers.removeAll()
        }
        var lastItem:EXSTwoByTwoView? = nil
        
        for (_,item) in items.enumerated() {
            let twoByTwoView = EXSTwoByTwoView()
            if addBlock == true {
                twoByTwoView.enableLeftRightTaps()
            }
            twoByTwoView.backgroundColor = UIColor.ThemeView.bg
            twoByTwoView.leftBottomLabel.font = item.lcontentFont
            twoByTwoView.rightBottomLabel.font = item.rcontentFont

            twoByTwoView.bindModel(item)
            containers.append(twoByTwoView)
            self.addSubview(twoByTwoView)
            containers.append(twoByTwoView)
            if let lastView = lastItem {
                twoByTwoView.snp.makeConstraints { (make) in
                    make.top.equalTo(lastView.snp.bottom).offset(15)
                    make.width.equalToSuperview()
                    make.left.equalToSuperview()
                    make.height.equalTo(38)
                }
            }else {
                twoByTwoView.snp.makeConstraints { (make) in
                    make.top.equalToSuperview()
                    make.width.equalToSuperview()
                    make.left.equalToSuperview()
                    make.height.equalTo(38)
                }
            }
            lastItem = twoByTwoView
        }
        
    }
}
