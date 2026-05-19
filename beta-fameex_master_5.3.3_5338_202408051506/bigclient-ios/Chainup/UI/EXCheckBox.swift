//
//  EXCheckBox.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

@IBDesignable

class EXCheckBox: UIControl {
    
    var checkEnabled:Bool = true
    var isChecked:Bool = false
    var text:String = ""
    var checkIcon:UIImageView = UIImageView()
    var fillColor:UIColor = UIColor.clear
    var borderColor:UIColor = UIColor.ThemeView.border
    var checkColor :UIColor = UIColor.ThemeView.highlight
    var checkLabel :UILabel = UILabel.init()
    let checkBoxLineWidth:CGFloat = 2
    var circleStyle:Bool = false
    
    typealias CheckBoxValueChanged = (Bool) -> ()
    var checkCallback : CheckBoxValueChanged?
    
    override var isSelected: Bool {
        didSet {
            self.checked(check: isSelected)
        }
    }
    
    func updateTilteColor(select: Bool){
        let color = select ? checkColor : UIColor.ThemeLabel.colorMedium
        self.checkLabel.textColor = color
    }
    
    func checked(check:Bool){
        isChecked = check
        if circleStyle {
            let selectedImg = UIImage.svgImage(named: "public_checked")
            let img = check ? selectedImg : UIImage.themeImageNamed(imageName:"quotes_unselected")
            checkIcon.image = img
        }else {
            let selectedImg = UIImage.svgImage(named: "public_selected_square")
            let img = check ? selectedImg : UIImage.themeImageNamed(imageName: "public_unselected_square")
            checkIcon.image = img
        }
        
        sendActions(for: .valueChanged)
    }
    
    func enabled(enable:Bool = true) {
        
    }
    
    func text(content:String) {
        checkLabel.text = content
        self.setNeedsDisplay()
    }
    
    func attributeText(content:NSAttributedString) {
        checkLabel.attributedText = content
        self.setNeedsDisplay()
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
        self.backgroundColor = UIColor.clear
        self.addSubview(checkLabel)
        self.addSubview(checkIcon)
        checkIcon.image = UIImage.themeImageNamed(imageName: "public_unselected_square")
        checkLabel.bodyRegular()
        checkLabel.textColor = UIColor.ThemeLabel.colorMedium
        checkLabel.snp.makeConstraints { (make ) in
            make.left.equalTo(checkIcon.snp.right).offset(4)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalTo(14)
        }
        
        checkIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    
    func updateInnerGap(_ gap:CGFloat) {
        checkLabel.snp.remakeConstraints { (make ) in
            make.left.equalTo(checkIcon.snp.right).offset(gap)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self .checked(check: !isChecked)
        checkCallback?(self.isChecked)
        sendActions(for: .valueChanged)
        return true
    }
    
    override func draw(_ rect: CGRect) {
//        fillColor .setFill()
//        borderColor .setStroke()
//        let width:CGFloat = 10
//        let boxBezier = UIBezierPath.init(roundedRect: CGRect(x: checkBoxLineWidth, y:(rect.height - width)/2, width: width, height: width), cornerRadius: 1.5)
//        boxBezier.lineWidth = checkBoxLineWidth
//        boxBezier .fill()
//        boxBezier .stroke()
//        if isChecked {
//            UIColor.ThemeView.highlight.setFill()
//            let checkBezier = UIBezierPath.init(rect: CGRect(x: 4, y: (rect.height - 6)/2, width: 6, height: 6))
//            checkBezier.fill()
//        }
    }
}


extension Reactive where Base: EXCheckBox {
    var checkState: ControlProperty<Bool> {
        return base.rx.controlProperty(editingEvents: UIControl.Event.valueChanged,
                                       getter: { customView in
                                        return  customView.isChecked},
                                       setter: { (customView, newValue) in
                                        customView.isChecked = newValue})
    }
    
}
