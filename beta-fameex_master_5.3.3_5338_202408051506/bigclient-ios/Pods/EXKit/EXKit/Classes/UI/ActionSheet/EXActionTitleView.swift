//
//  EXActionTitleView.swift
//  Chainup
//
//  Created by liuxuan on 2020/3/8.
//  Copyright © 2020 zewu wang. All rights reserved.
//

import UIKit

public class EXActionTitleView: UIView {
    
    public override func draw(_ rect: CGRect) {
        let path = UIBezierPath.init(roundedRect: rect,
                                     byRoundingCorners: [.topLeft,.topRight],
                                     cornerRadii: CGSize(width: 10, height: 10))

        UIColor.ThemeView.bgCard.setStroke()
        UIColor.ThemeView.bg.setFill()
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        path.fill()
    }

}
