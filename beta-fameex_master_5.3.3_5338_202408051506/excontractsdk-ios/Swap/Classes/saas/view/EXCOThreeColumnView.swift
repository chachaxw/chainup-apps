//
//  EXThreeColumnView.swift
//  Chainup
//
//  Created by liuxuan on 2023/4/4.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXNEWColumnAlignment {
    case left
    case right
    case center
}

class EXCOThreeColumnDataModel:NSObject {
    var title:String = ""
    var content:String = ""
    var logo:String = ""
    var style:EXCOThreeColumnStyle = EXCOThreeColumnStyle()
    var aliment :EXNEWColumnAlignment = .left
    var iconStatus:Bool = false
    override init() {
        super.init()
    }
    init(title:String) {
        super.init()
        self.title = title
    }
    
    class func getCommonStyle()->EXCOThreeColumnStyle {
        let style = EXCOThreeColumnStyle()
        style.topLabelFont = UIFont.ThemeFont.SecondaryMedium
        style.topLabelColor = UIColor.ThemeLabel.colorMedium
        style.bottomLabelFont = UIFont.ThemeFont.BodyMedium
        style.bottomLabelColor = UIColor.ThemeLabel.colorLite
        return style
    }
}


class EXCOThreeColumnStyle:NSObject {
    var topLabelFont:UIFont = UIFont.ThemeFont.MinimumRegular
    var topLabelColor:UIColor = UIColor.ThemeLabel.colorDark
    var bottomLabelFont:UIFont = UIFont.ThemeFont.BodyRegular
    var bottomLabelColor:UIColor = UIColor.ThemeLabel.colorMedium
    var bgColor:UIColor = UIColor.ThemeView.bg
}

class EXCOThreeColumnView: EXSNibBaseView {

    @IBOutlet var titleLeft: UILabel!
    @IBOutlet var bottomLeft: UILabel!
    @IBOutlet var titleMiddle: UILabel!
    @IBOutlet var bottomMiddle: UILabel!
    @IBOutlet var titleRight: UILabel!
    @IBOutlet var bottomRight: UILabel!
    @IBOutlet var middleView: UIView!
    @IBOutlet var middleBgView: UIView!
    @IBOutlet var rightBgView: UIView!
    @IBOutlet var bottomIcon: UIImageView!
    @IBOutlet weak var leftbgView: UIView!
    
    override func onCreate() {
        
    }
    
    func configStyle(with title:UILabel,bottom:UILabel,style:EXCOThreeColumnStyle ) {
        title.font = style.topLabelFont
        title.textColor = style.topLabelColor
        bottom.font = style.bottomLabelFont
        bottom.textColor = style.bottomLabelColor
    }
    
    func bindItems(with models:[EXCOThreeColumnDataModel],ignoreModelCount:Bool = true) {
        if models.count <= 0 || models.count > 3 {
            return
        }
        //忽略个数,默认就是3个 English: Ignoring the number, defaults to 3
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
                    if model.logo.count > 0 {
                        bottomIcon.yy_setImage(with: URL.init(string: model.logo))
                    }
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

