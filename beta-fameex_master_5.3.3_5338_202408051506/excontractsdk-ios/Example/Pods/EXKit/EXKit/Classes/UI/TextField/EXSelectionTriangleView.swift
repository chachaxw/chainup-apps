//
//  EXSelectionTriangleView.swift
//  Chainup
//
//  Created by liuxuan on 2019/3/11.
//  Copyright © 2019 zewu wang. All rights reserved.
//

import UIKit

public class EXSelectionTriangleView: UIView {
    private var isChecked:Bool = false
    public var fillColor:UIColor = UIColor.ThemeView.bgIcon
    public var icon:UIImageView = UIImageView.init()
    
    public var iconImgs : [String] = ["dropdown_lightcolor_small","collapse_lightcolor_small"]
    
    public var useBig = false
    {
        didSet{
            if useBig == true{
                iconImgs = ["dropdown","collapse"]
                icon.image = UIImage.themeImageNamed(imageName:iconImgs[0])
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    public func config() {
        self.backgroundColor = UIColor.clear
        self.addSubview(icon)
        icon.image = UIImage.themeImageNamed(imageName:iconImgs[0])
        icon.layoutIfNeeded()
        icon.contentMode = .scaleAspectFit
        icon.snp.makeConstraints { make in
//            make.width.equalToSuperview()
//            make.height.equalToSuperview()
            make.right.top.equalToSuperview()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(normalStyle), name:  NSNotification.Name.init("EXSheetDissmissed"), object: nil)
    }
    
    
    @objc public func normalStyle() {
        self.checked(check: false)
    }
    
    public func checked(check:Bool){
        isChecked = check
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage.themeImageNamed(imageName: check ? iconImgs[1] : iconImgs[0])
//        self.setNeedsDisplay()
    }
    
    public override func draw(_ rect: CGRect) {
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
