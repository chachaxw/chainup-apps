//
//  EXThreeColumnView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
enum EXColumnAlignment {
    case left
    case right
    case center
}

class ExThreeColumnDataModel:NSObject {
    var title:String = ""
    var content:String = ""
    var style:ExThreeColumnStyle = ExThreeColumnStyle()
    var aliment :EXColumnAlignment = .left
    var iconStatus:Bool = false
    override init() {
        super.init()
    }
    init(title:String) {
        super.init()
        self.title = title
    }
    
    class func getCommonStyle()->ExThreeColumnStyle {
        let style = ExThreeColumnStyle()
        style.topLabelFont = UIFont.ThemeFont.SecondaryMedium
        style.topLabelColor = UIColor.ThemeLabel.colorMedium
        style.bottomLabelFont = UIFont.ThemeFont.BodyMedium
        style.bottomLabelColor = UIColor.ThemeLabel.colorLite
        return style
    }
}


class ExThreeColumnStyle:NSObject {
    var topLabelFont:UIFont = UIFont.ThemeFont.MinimumRegular
    var topLabelColor:UIColor = UIColor.ThemeLabel.colorDark
    var bottomLabelFont:UIFont = UIFont.ThemeFont.BodyRegular
    var bottomLabelColor:UIColor = UIColor.ThemeLabel.colorMedium
}

class EXThreeColumnView: NibBaseView {

    var btnClickBlock: EXComVoidBlock?
    @IBOutlet var titleLeft: UILabel!
    @IBOutlet var bottomLeft: UILabel!
    @IBOutlet var titleMiddle: UILabel!
    @IBOutlet var bottomMiddle: UILabel!
    @IBOutlet var titleRight: UILabel!
    @IBOutlet var bottomRight: UILabel!
    @IBOutlet var middleView: UIView!
    @IBOutlet var middleBgView: UIView!
    @IBOutlet var rightBgView: UIView!
    
    //confirm
    lazy var indicatorBtn : UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(clickAlertBtn), for: UIControl.Event.touchUpInside)
        btn.setImage(UIImage.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: CGSize(width: 12, height: 12)), for: .normal)
        btn.setTitle("", for: .normal)
        btn.isHidden = true
        return btn
    }()
    override func onCreate() {
        self.addSubview(indicatorBtn)
        indicatorBtn.snp.makeConstraints { make in
            make.left.equalTo(self.bottomLeft.snp_right).offset(8)
            make.height.width.equalTo(16)
            make.centerY.equalTo(self.bottomLeft)
        }
        
        indicatorBtn.setEnlargeEdgeWithTop(20, left: 20, bottom: 20, right: 20)
    }
    
    @objc func clickAlertBtn(){
        self.btnClickBlock?()
    }
    func configStyle(with title:UILabel,bottom:UILabel,style:ExThreeColumnStyle ) {
        title.font = style.topLabelFont
        title.textColor = style.topLabelColor
        bottom.font = style.bottomLabelFont
        bottom.textColor = style.bottomLabelColor
    }
    
    func bindItems(with models:[ExThreeColumnDataModel],ignoreModelCount:Bool = true) {
        if models.count <= 0 || models.count > 3 {
            return
        }
        //Ignore the number, default to 3
        if ignoreModelCount  {
            for(idx,model) in models.enumerated() {
                if idx == 0 {
                    titleLeft.text = model.title
                    bottomLeft.text = model.content
                    self.configStyle(with: titleLeft, bottom: bottomLeft, style: model.style)
                }else if idx == 1 {
                    titleMiddle.text = model.title
                    bottomMiddle.text = model.content
                    titleMiddle.textAlignment = .left
                    bottomMiddle.textAlignment = .left
                    self.configStyle(with: titleMiddle, bottom: bottomMiddle, style: model.style)
                }else if idx == 2 {
                    titleRight.text = model.title
                    bottomRight.text = model.content
                    self.configStyle(with: titleRight, bottom: bottomRight, style: model.style)
                }
            }
        }
        else {
            if models.count == 1 {
                middleBgView.isHidden = true
                rightBgView.isHidden = true
                let modelA = models[0]
                titleLeft.text = modelA.title
                bottomLeft.text = modelA.content
                self.configStyle(with: titleLeft, bottom: bottomLeft, style: modelA.style)
            }else if models.count == 2 {
                middleBgView.isHidden = true
                for(idx,model) in models.enumerated() {
                    if idx == 0 {
                        titleLeft.text = model.title
                        bottomLeft.text = model.content
                        self.configStyle(with: titleLeft, bottom: bottomLeft, style: model.style)
                    }else if idx == 1 {
                        titleRight.text = model.title
                        bottomRight.text = model.content
                        self.configStyle(with: titleRight, bottom: bottomRight, style: model.style)
                    }
                }
            }else {
                for(idx,model) in models.enumerated() {
                    if idx == 0 {
                        titleLeft.text = model.title
                        bottomLeft.text = model.content
                        self.configStyle(with: titleLeft, bottom: bottomLeft, style: model.style)
                    }else if idx == 1 {
                        titleMiddle.text = model.title
                        bottomMiddle.text = model.content
                        titleMiddle.textAlignment = .left
                        bottomMiddle.textAlignment = .left
                        self.configStyle(with: titleMiddle, bottom: bottomMiddle, style: model.style)
                    }else if idx == 2 {
                        titleRight.text = model.title
                        bottomRight.text = model.content
                        self.configStyle(with: titleRight, bottom: bottomRight, style: model.style)
                    }
                }
            }
        }
    }
}

