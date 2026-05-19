//
//  EXBouncedView.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

enum EXBouncedModelAction:Equatable {
    case recharge
    case transfer
    case horizontal
    case vertical
    case changeCoinMap(String)
    case changeOrderType(String)
    case contractSetting
    case contractCaculator
    case contractGuideLine
    case contractTransfer
    case contractRecord
    case contractSwapInfo
    case contractProfitRecord
    case tradeOrderWayLimit
    case tradeOrderWayMarket
    case leverBorrow
    case leverReturn
    case none
}

class EXBouncedModel : NSObject{
    var img = ""
    var name = ""
    var tag = -1
    var action:EXBouncedModelAction = .none
    var showSeperator:Bool = false
    var showArrow:Bool = false
    var selectedColor:UIColor = UIColor.ThemeView.bg
    var titleColor:UIColor = UIColor.ThemeLabel.colorLite
}

class EXBouncedView: UIView {
    
    typealias ClickViewBlock = (EXBouncedModelAction) -> ()
    var clickViewBlock : ClickViewBlock?

    lazy var struckView : UIStackView = {
        let view = UIStackView()
        view.extUseAutoLayout()
        view.axis = .vertical
        view.extSetCornerRadius(4)
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(struckView)
        struckView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

    }
    
    func setData(_ models : [EXBouncedModel],cellHeight:CGFloat = 50){
        struckView.removeAllArrangedSubviews()
        for index in 0..<models.count{
            let model = models[index]
            model.tag = 1000 + index
            let view = EXBouncedDetailView.init(bouncedModel: model)
            view.setView(model)
            view.clickViewBlock = {[weak self]str in
                self?.clickViewBlock?(model.action)
            }
            struckView.addArrangedSubview(view)
            view.snp.makeConstraints { (make) in
                make.height.equalTo(cellHeight)
            }
        }
    }
    
    func show(){
        guard let appDelegate  = UIApplication.shared.delegate else {
            return
        }
        if appDelegate.window != nil   {
            appDelegate.window??.rootViewController?.view.addSubview(self)
            appDelegate.window??.rootViewController?.view.bringSubviewToFront(self)
            self.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EXBouncedDetailView: UIView {
    
    var action:EXBouncedModelAction = .none
    typealias ClickViewBlock = (String) -> ()
    var clickViewBlock : ClickViewBlock?
    var bounceModel:EXBouncedModel
        
    lazy var bgBtn : UIButton = {
        let v = UIButton()
        v.addTarget(self, action: #selector(clickView), for: .touchUpInside)
        return v
    }()
    
    lazy var seprator : UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.ThemeView.seperator
        return v
    }()
    
    lazy var arrowIcon : UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFit
        imgV.image = EXKitBundle.image(named: "public_positions_arrow_right")
        return imgV
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.layoutIfNeeded()
        imgV.contentMode = .center
        return imgV
    }()
    
    lazy var label : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyMedium
        label.textAlignment = .center
        return label
    }()
    
    
    required init(bouncedModel:EXBouncedModel){
        self.bounceModel = bouncedModel
        super.init(frame: .zero)
        onCreate()
    }
    
    func onCreate() {
        bgBtn.extsetBackgroundColor(backgroundColor: UIColor.ThemeView.bgTab, state: .highlighted)
        addSubViews([bgBtn,seprator,imgV,label,arrowIcon])
        seprator.isHidden = !bounceModel.showSeperator
        arrowIcon.isHidden = !bounceModel.showArrow
//        bgBtn.backgroundColor = bounceModel.selectedColor
        label.textColor = bounceModel.titleColor
        bgBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        seprator.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(7)
            make.height.equalTo(9)
            make.centerY.equalTo(label)
        }
        
        if bounceModel.img.count > 0 {
            imgV.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16)
                make.centerY.equalTo(label)
                make.width.equalTo(20)
            }
            label.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(45)
                make.width.lessThanOrEqualTo(100)
                make.right.equalToSuperview().offset(-10)
                make.centerY.equalToSuperview()
                make.height.equalTo(20)
            }
        }else {
            label.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(12)
                make.right.equalToSuperview().offset(-10)

                make.centerY.equalToSuperview()
                make.height.equalTo(20)
            }
        }
//
//        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickView))
//        self.addGestureRecognizer(tap)
    }
    
    @objc func clickView(){
        self.clickViewBlock?(self.label.text ?? "")
    }
    
    func setView(_ model : EXBouncedModel){
        self.action = model.action
        imgV.image = UIImage.themeImageNamed(imageName: model.img)
        label.text = model.name
        tag = model.tag
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
