//
//  EXBouncedView.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/6.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit

enum EXSBouncedModelAction:Equatable {
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
    case like //收藏 English: collection
    case indicator //警示 English: Warning
}
class EXSBouncedModel : NSObject{
    var img = ""
    var name = ""
    var tag = -1
    var action:EXSBouncedModelAction = .none
    var showSeperator:Bool = false
    var showArrow:Bool = false
    var alignment:NSTextAlignment = .center
    var selectedColor:UIColor = UIColor.ThemeView.card1
    var bgColor = UIColor.ThemeView.alertBg
    var titleColor:UIColor = UIColor.ThemeLabel.colorLite
    var openType: EXOpenOrderType = .qty
    
    static func getContractMenulist() -> [EXSBouncedModel]{
        var models = [EXSBouncedModel]()

        let model3 = EXSBouncedModel()
        model3.img = "contract_icon_morefunctions_fundstransfer"
        model3.name = "cp_extra_text142".ex_localized()
        models.append(model3) // 资金划转 English: Fund transfer
        model3.action = .contractTransfer
        
        let model5 = EXSBouncedModel()
        model5.img = "contract_icon_morefunctions_moneyflowing"
        model5.name = "cp_extra_text143".ex_localized()
        models.append(model5) // 资金流水 English: Capital flow
        model5.action = .contractRecord
        
        let model = EXSBouncedModel()
        model.img = "contract_icon_morefunctions_preference"
        model.name = "cp_contract_setting_text13".ex_localized()
        model.action = .contractSetting
        models.append(model) // 合约设置 English: Contract settings
        
        let model2 = EXSBouncedModel()
        model2.img = "contract_icon_morefunctions_calculator"
        model2.name = "cp_calculator_text1".ex_localized()
        model2.action = .contractCaculator
        models.append(model2) // 合约计算器 English: Contract Calculator
        
        let model4 = EXSBouncedModel()
        model4.img = "contract_icon_morefunctions_infomation"
        model4.name = "cp_contract_info_text1".ex_localized()
        model4.action = .contractSwapInfo
        models.append(model4) // 合约信息 English: Contract information
       
        let model6 = EXSBouncedModel()
        model6.img = "contract_icon_morefunctions_contractguide"
        model6.name = "cp_extra_text144".ex_localized()
        model6.action = .contractGuideLine
        models.append(model6) // 合约指南 English: Contract Guidelines
        
        for model in models {
            model.showSeperator = true
        }
        return models
    }
    
}

class EXSBouncedView: UIView {
    
    typealias ClickViewBlock = (EXSBouncedModelAction) -> ()
    var clickViewBlock : ClickViewBlock?
    var clickViewIndexBlock : ((NSInteger) -> ())?

    lazy var struckView : UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.backgroundColor = UIColor.ThemeView.bg
        view.layer.cornerRadius = 4
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
    
    func setData(_ models : [EXSBouncedModel],cellHeight:CGFloat = 50){
        let bottomH: CGFloat = 12
//        struckView.removeAllArrangedSubviews()
        for index in 0..<models.count{
            let model = models[index]
            model.tag = 1000 + index
            let view = EXSBouncedDetailView.init(bouncedModel: model)
            view.setView(model)
            view.clickViewBlock = {[weak self]str in
                self?.clickViewBlock?(model.action)
                self?.clickViewIndexBlock?(model.tag - 1000)
            }
            view.clickViewActionBlock = { [weak self] action in
                self?.clickViewBlock?(action)
            }
            struckView.addArrangedSubview(view)
            view.snp.makeConstraints { (make) in
                make.height.equalTo(cellHeight)
            }
        }
        let bottomSpace = UIView()
        struckView.addArrangedSubview(bottomSpace)
        bottomSpace.snp.makeConstraints { (make) in
            make.height.equalTo(12)
        }
        
        self.height = cellHeight * CGFloat(models.count) + bottomH
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

class EXSBouncedDetailView: UIView {
    typealias ClickViewActionBlock = (EXSBouncedModelAction) -> ()
    var action:EXSBouncedModelAction = .none
    typealias ClickViewBlock = (String) -> ()
    var clickViewBlock : ClickViewBlock?
    var clickViewActionBlock : ClickViewActionBlock?
    var bounceModel:EXSBouncedModel
        
    lazy var bgBtn : UIButton = {
        let v = UIButton()
        v.backgroundColor = UIColor.ThemeView.bg
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
        imgV.contentMode = .scaleAspectFill
        imgV.image = UIImage.exs_themeImageNamed(imageName: "transaction_enter")
        return imgV
    }()
    
    lazy var imgV : UIImageView = {
        let imgV = UIImageView()
        
        imgV.layoutIfNeeded()
        imgV.contentMode = .center
        return imgV
    }()
    
    lazy var label : UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyMedium
        label.textAlignment = .center
        return label
    }()
    
    ///带 English: /With
    lazy var container: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fill
        stack.spacing = 0
        stack.axis = .horizontal
        stack.alignment = .fill
        return stack
    }()
    
    //确认 English: confirm
    lazy var indicatorBtn : UIButton = {
        let btn = UIButton()
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_instructions"), for: .normal)
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.exs_setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 50)
        return btn
    }()
    
    @objc func clickBtn(){
        self.clickViewActionBlock?(.indicator)
    }
    
    
    required init(bouncedModel:EXSBouncedModel){
        self.bounceModel = bouncedModel
        super.init(frame: .zero)
        self.backgroundColor = UIColor.ThemeView.bg
        onCreate()
    }
    
    func onCreate() {
        
        bgBtn.ext_setBackgroundColor(backgroundColor: UIColor.ThemeView.bgTab, state: .highlighted)
        exs_addSubViews([bgBtn,seprator,imgV,label,arrowIcon])
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
        
       
        if bounceModel.openType == .value { //需要警示弹框 English: Warning frame needed
            self.addSubview(container)
            container.snp.makeConstraints { make in
                make.height.equalTo(20)
                make.center.equalToSuperview()
            }
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickView))
            label.addGestureRecognizer(tap)
            label.isUserInteractionEnabled = true
            container.addArrangedSubviews([label,indicatorBtn])
            indicatorBtn.snp.makeConstraints { make in
                make.height.width.equalTo(20)
            }
        }else{
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
        }
    }
    
    @objc func clickView(){
        self.clickViewBlock?(self.label.text ?? "")
    }
    
    func setView(_ model : EXSBouncedModel){
        self.action = model.action
        imgV.image = UIImage.exs_themeImageNamed(imageName: model.img)
        label.text = model.name
        label.textAlignment = model.alignment
        tag = model.tag
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

