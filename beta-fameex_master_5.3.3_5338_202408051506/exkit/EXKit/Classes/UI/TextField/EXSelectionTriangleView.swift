//
//  EXSelectionTriangleView.swift
//  Chainup
//
//  Created by liuxuan on2020/3/11.
//  Copyright ©2020 zewu wang. All rights reserved.
//

import UIKit

public class EXSelectionTriangleView: UIView {
    private var isChecked:Bool = false
    public var fillColor:UIColor = UIColor.ThemeView.bgIcon
    public var icon:UIImageView = UIImageView.init()
    // only use the first one
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
        icon.transform = check ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
    }
    
}
