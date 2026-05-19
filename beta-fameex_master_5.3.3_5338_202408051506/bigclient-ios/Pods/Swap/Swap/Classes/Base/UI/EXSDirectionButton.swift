//
//  EXDirectionButton.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

public enum EXSDirectionActionType:Int {
    case none = 0
    case ascending = 1 // a<b
    case descending = 2 // a>b
}

public enum EXSHorizontalMargin {
    case marginLeft
    case marginCenter
    case marginRight
}

public class EXSDirectionPassThroughView :UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

public class EXSDirectionButton: UIControl {
    var btnClickBlock: EXComVoidBlock?
    var container :EXSDirectionPassThroughView  = EXSDirectionPassThroughView.init()
    var titleLabel = UILabel()
    var alighment :EXSHorizontalMargin = .marginLeft
    var dirState :EXSDirectionActionType = .none
    var imageView = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "public_icon_arrow_down"))
    var spaceBetweenImageAndTitle :CGFloat = 8
    var imageW:CGFloat = 10
    var triangleWidth :CGFloat = 8
    var paddingleftRight: CGFloat = 6
    var isChecked:Bool = false
    var arrowAnimator = true  //箭头是否需要旋转动画 English: Do arrows require rotation animation
    var showIndcator: Bool = false{
        didSet{
            if showIndcator == true {
                indicatorBtn.isHidden = false
                titleLabel.snp.updateConstraints { make in
                    make.left.equalToSuperview().offset(20)
                }
                indicatorBtn.exs_setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 40)
                titleLabel.textAlignment = .center
            }
        }
    }
    
    //问号按钮 English: Question mark button
    lazy var indicatorBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(indicatorClick), for: UIControl.Event.touchUpInside)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_instructions"), for: .normal)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_instructions"), for: .selected)
        btn.exs_setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 20)
        btn.isHidden = true
        return btn
    }()
    

    func checked(check:Bool){
        isChecked = check
    }
    
    func text(content:String) -> CGFloat{
        titleLabel.text = content
        if self.alighment == .marginCenter{
            self.reloayTilteImage()
            return self.updateSubView()
        }
        self.setNeedsDisplay()
        return 50
    }
    
    func setAlighment(margin:EXSHorizontalMargin) {
        switch margin {
        case .marginLeft:
            container.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
            break
        case .marginRight:
            container.snp.remakeConstraints { (make) in
                make.width.lessThanOrEqualToSuperview()
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            break
        case .marginCenter:
            self.alighment = margin
            container.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.lessThanOrEqualToSuperview()
            }
            break
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
    
    func reset(idx:Int = 0) {
//        triangleView.isChecked = idx == 0 ? false : true
//        triangleView.highlightIdx = idx
    }
   
    func config(){
        self.alighment = .marginLeft
        self.addSubview(container)
        self.backgroundColor = UIColor.ThemeView.bg
        container.backgroundColor = UIColor.ThemeView.bg
        container.addSubview(indicatorBtn)
        container.addSubview(titleLabel)
        container.addSubview(imageView)
        titleLabel.secondaryRegular()
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        titleLabel.layoutIfNeeded()
        imageView.contentMode = .scaleAspectFit
        container.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        indicatorBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(15)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(self.paddingleftRight)
            make.centerY.equalToSuperview()
        }
        imageView.snp.remakeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right)
            make.right.equalToSuperview().offset(-self.paddingleftRight)
            make.height.width.equalTo(imageW)
            make.centerY.equalTo(titleLabel)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(normalStyle), name:  NSNotification.Name.init("EXSheetDissmissed"), object: nil)
    }
    func relayout()  {
        updateSubView()

    }
    
    func reloayTilteImage(){
        titleLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(self.paddingleftRight)
            make.centerY.equalToSuperview()
        }
        imageView.snp.remakeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(spaceBetweenImageAndTitle)
            make.height.width.equalTo(imageW)
            make.centerY.equalTo(titleLabel)
        }
        
    }
    
    func updateSubView() -> CGFloat{
        //左右间距图片 English: Left and right spacing image
        let titleLabelsize = titleLabel.text?.textSizeWithFont(titleLabel.font, width: Device_W)
        if  titleLabelsize == nil{
            return 50
        }
        let totalW = paddingleftRight * 2 + titleLabelsize!.width + spaceBetweenImageAndTitle  + imageW
        
        container.snp.remakeConstraints { (make) in
            make.width.equalTo(totalW)
            make.height.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        self.snp.updateConstraints { make in
            make.width.equalTo(totalW)
        }
        return totalW
    }
    @objc func normalStyle() {
        self.checked(check: false)
        UIView.animate(withDuration: 0.2) {
            self.imageView.layer.transform = CATransform3DIdentity
        }
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        click(check:!isChecked)
        return true
    }
    
    func click(check:Bool){
//        triangleView.isChecked = check
//        triangleView.setDoubleTriangleTapped()
//        dirState = EXSDirectionActionType(rawValue: triangleView.highlightIdx)!
        
        if arrowAnimator == false{
            return
        }
        UIView.animate(withDuration: 0.2) {
            if self.isChecked {
                self.imageView.layer.transform = CATransform3DIdentity
            }else {
                self.imageView.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
            }
        }
        isChecked = check
    }
    
    
    @objc func indicatorClick(){
        //
        self.btnClickBlock?()
    }
}


class EXDropImageView: EXCOCustomBaseView{
    
    var openBlock: EXComBoolBlock?
    var open:Bool = false 
    var imageView = UIImageView(image: UIImage.exs_themeImageNamed(imageName: "public_icon_arrow_down"))
    override func setSubView() {
        self.addSubview(imageView)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(10)
            make.center.equalToSuperview()
        }
    }
    
    @objc func click(){
        self.isUserInteractionEnabled = false
        self.open = !self.open
        UIView.animate(withDuration: 0.2) {
            if !self.open {
                self.imageView.layer.transform = CATransform3DIdentity
            }else {
                self.imageView.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
            }
            self.isUserInteractionEnabled = true
        }
        self.openBlock?(self.open)
    }
    
    func reset(){
        self.open = false
        self.imageView.layer.transform = CATransform3DIdentity
    }
   
}

