//
//  EXSelectionTriangleView.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

class EXSelectionTriangleView: UIView {
    private var isChecked:Bool = false
    var fillColor:UIColor = UIColor.ThemeView.bgIcon
    var icon:UIImageView = UIImageView.init()
    
    var iconImgs : [String] = ["transaction_triangle_down","transaction_triangle_down"]
    
    var useBig = false
    {
        didSet{
            if useBig == true{
//                iconImgs = ["dropdown","collapse"]
                icon.image = UIImage.themeImageNamed(imageName:iconImgs[0])
            }
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
    
    func config() {
        self.backgroundColor = UIColor.clear
        self.addSubview(icon)
        icon.image = UIImage.themeImageNamed(imageName:iconImgs[0])
        icon.contentMode = .scaleAspectFit
        NotificationCenter.default.addObserver(self, selector: #selector(normalStyle), name:  NSNotification.Name.init("EXSheetDissmissed"), object: nil)
    }
    
    
    @objc func normalStyle() {
        self.checked(check: false)
    }
    
    func checked(check:Bool){
        isChecked = check
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage.themeImageNamed(imageName: check ? iconImgs[1] : iconImgs[0])
//        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
//        let path = UIBezierPath()
//        self.backgroundColor = UIColor.clear
//        fillColor.setFill()
//        if isChecked {
//            let startX = rect.size.width/2
//            let startY = CGFloat(0)
//            path.move(to: CGPoint(x: startX, y: startY))
//            path.addLine(to: CGPoint(x: 0, y: rect.size.height))
//            path.addLine(to: CGPoint(x:rect.size.width, y: rect.size.height))
//        }else {
//            let startX = CGFloat(0)
//            let startY = CGFloat(0)
//            path.move(to: CGPoint(x: startX, y: startY))
//            path.addLine(to: CGPoint(x: startX + rect.size.width/2, y: rect.size.height))
//            path.addLine(to: CGPoint(x: startX + rect.size.width, y: 0))
//        }
//        path.close()
//        path.fill()
    }
}
