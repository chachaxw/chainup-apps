//
//  EXCharSetAlert.swift
//  Chainup
//
//  Created by cwd on 2022/11/6.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit
//import Lottie

class EXCharSetAlert: EXCOCustomBaseView {
    var clickBlock: EXComVoidBlock?
    override func setSubView() {
        configSubView()
    }
    deinit{
        self.clickBlock?()
    }
    override func setData(){
        let can = EXStoreData.storeBool(forKey: contract_chart_open)
        switchBtn.isSelected = can
        topItem.canUse = can
        bottomItem.canUse = can
        if can{
            let top = EXStoreData.storeBool(forKey: contract_chart_top)
            topItem.selected = top
            bottomItem.selected = !top
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.exs_roundCorners(corners: [.topLeft,.topRight], radius: 10)
        topItem.extSetCornerRadius(4)
        bottomItem.extSetCornerRadius(4)
    }
    
    
    //MARK: lazy
    ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"cp_trading_area_chart_title".ex_localized(), font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    //开关 English: switch
    lazy var switchBtn :RepeatButton = {
        let btn = RepeatButton()
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "trade_switch_close"), for: .normal)
        btn.setImage(UIImage.svg_themeImageNamed(imageName: "trade_switch_open"), for: .selected)
        btn.addTarget(self, action: #selector(clickBtn), for: UIControl.Event.touchUpInside)
        btn.isSelected = true
        return btn
    }()
    
    lazy var cancelBtn : EXButton = {
        let btn = EXButton()
        btn.selectStyle = .clearBlueColor
        btn.addTarget(self, action: #selector(cancelBtnClick), for: UIControl.Event.touchUpInside)
        btn.ext_SetTitle("cp_overview_text56".ex_localized(), 14, UIColor.ThemeLabel.colorMedium, .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        return btn
    }()
    
    lazy var topItem: CharSetItemView = {
       let v = CharSetItemView()
        v.titleLabel.text = ContactChartLocation.top.display
        v.mainImg.image = UIImage.exs_themeImageNamed(imageName: "public_klineontop")
        v.clickBlock = {  [weak self] in
            self?.bottomItem.selected = false
            EXStoreData.setStoreObjectAndKey(true, key: contract_chart_top)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                EXAlert.dismiss()
            }
        }
       return v
    }()
    
    lazy var bottomItem: CharSetItemView = {
       let v = CharSetItemView()
        v.mainImg.image = UIImage.exs_themeImageNamed(imageName: "public_klineondown")
        v.titleLabel.text = ContactChartLocation.bottom.display
        v.clickBlock = { [weak self] in
            self?.topItem.selected = false
            EXStoreData.setStoreObjectAndKey(false, key: contract_chart_top)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                EXAlert.dismiss()
            }
        }
       return v
    }()
    
}
extension EXCharSetAlert{
    //MARK: action
    @objc func clickBtn(){
        switchBtn.isSelected = !switchBtn.isSelected
        let open = switchBtn.isSelected
        EXStoreData.setStoreObjectAndKey(open, key: contract_chart_open)
        EXStoreData.setStoreObjectAndKey(true, key: contract_chart_hasSeted)
        setData()
//        topItem.canUse = open
//        bottomItem.canUse = open
//        if open{
//            setData()
//        }
       
    }
    
    @objc func cancelBtnClick(){
        EXAlert.dismiss()
    }
    
    
    func configSubView(){
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubViews([
            titleLabel,switchBtn,cancelBtn,
            topItem,bottomItem
        ])
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }
        switchBtn.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(8)
            make.centerY.equalTo(titleLabel)
            //            make.width.equalTo(26)
            //            make.height.equalTo(15)
        }
        cancelBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(45)
            make.height.equalTo(18)
            make.centerY.equalTo(titleLabel)
        }
        var btnw = cancelBtn.titleResizeSize().width
        let maxW = Device_W * 0.5
        if btnw > maxW{
            btnw = maxW
        }
        cancelBtn.snp.updateConstraints { make in
            make.width.equalTo(btnw)
        }
        
        
       // let w:CGFloat  = (Device_W - (16 * 3)~)*0.5
        let h: CGFloat = 213~
        let w: CGFloat = 145~
        topItem.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(30~)
            make.height.equalTo(h)
            make.width.equalTo(w)
        }
        bottomItem.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
//            make.left.equalTo(topItem.snp.right).offset(16~)
            make.right.equalToSuperview().offset(-30~)
            make.height.equalTo(h)
            make.width.equalTo(topItem)
        }
    }
}

class CharSetItemView: EXCOCustomBaseView{
    var clickBlock: EXComVoidBlock?
    var canUse = true {
        didSet{
            if canUse{ //可用 English: available
                topMaskView.isHidden = true
                checkImg.isHidden = false
            }else{//禁用 English: Disabled
                topMaskView.isHidden = false
                checkImg.isHidden = true
            }
            self.mainImg.layer.borderWidth = 0
        }
    }
    
    var selected = false{
        didSet{
            if selected{
                checkImg.isHidden = false
                mainImg.layer.borderWidth = 2
                mainImg.layer.cornerRadius = 4
                mainImg.layer.borderColor = UIColor.ThemeView.highlight.cgColor
            }else{
                checkImg.isHidden = true
                mainImg.layer.borderWidth = 0
                mainImg.layer.cornerRadius = 0
          }
        }
    }
    
    override class var viewHeight: CGFloat{
        return 213
    }
    
    
    override func setSubView(){
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.ThemeView.alertBg
        self.addSubViews([mainImg, titleLabel,topMaskView])
        mainImg.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(mainImg.snp.bottom).offset(12)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        topMaskView.snp.makeConstraints { make in
            make.edges.equalTo(mainImg)
        }
        mainImg.addSubview(checkImg)
        checkImg.snp.makeConstraints { make in
            make.right.top.equalToSuperview() //.offset(-2)
            make.width.height.equalTo(24)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mainImg.exs_roundCorners(corners: .allCorners, radius: 4)
        topMaskView.exs_roundCorners(corners: .allCorners, radius: 4)
    }
    
    @objc func click(){
        if self.canUse == false{
            return
        }
        self.selected = true
        EXStoreData.setStoreObjectAndKey(true, key: contract_chart_hasSeted)
        self.clickBlock?()
    }
    
    
    //MARK: lazy
    lazy var mainImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFill
        arrowImmg.clipsToBounds = true
//        arrowImmg.backgroundColor = .yellow
//        arrowImmg.image = UIImage(named: "")
        return arrowImmg
    }()
    
    lazy var checkImg : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.svg_themeImageNamed(imageName: "public_selecteds")
        return arrowImmg
    }()
    
    ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var topMaskView: UIView = {
       let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        v.isHidden = true
        return v
    }()
    
}


