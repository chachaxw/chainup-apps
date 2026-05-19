//
//  EXTriangleIndicator.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/21.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXTriangleIndicator: UIButton {
    
    var fillColor:UIColor = .Ex.text2
    var highlight:UIColor = UIColor.ThemeView.highlight
    
    var textNormalColor:UIColor = UIColor.ThemeLabel.colorMedium
    var textHighLightColor:UIColor = UIColor.ThemeLabel.colorLite
    
    var triangleWidth :CGFloat = 6
    var triangleHeight :CGFloat = 6
    
    var isChecked:Bool = false {
        didSet {
            titleLabel?.textColor = isChecked ? textHighLightColor : textNormalColor
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    func config(){
        self.backgroundColor = UIColor.ThemeView.bg
        self.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        self.setTitleColor(textNormalColor, for: .normal)
        self.setTitleColor(textHighLightColor, for: .selected)
    }
    
    func setTitle(content:String) {
        self.setTitle(content, for: .normal)
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        if isSelected {
            highlight.setFill()
        }else {
            fillColor.setFill()
        }
        var startX = rect.width
        var startY = rect.height
        if let labelRect = self.titleLabel?.frame , let point = self.titleLabel?.font.pointSize{
            startY = labelRect.minY + point
            startX = labelRect.maxX + triangleWidth
        }
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: startX, y: startY - triangleHeight))
        path.addLine(to: CGPoint(x: startX - triangleWidth, y: startY))
        path.close()
        path.fill()
    }
}
