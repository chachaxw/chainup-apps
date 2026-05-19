//
//  EXChangeMarginView.swift
//  EXSwapSDK
//
//  Created by ZYJ on 2023/4/28.
//

import UIKit
import EXKit
//更改逐仓和全仓 English: Change warehouse by warehouse and full warehouse
class EXChangeMarginView: UIView {
    var clickMarginTypeBlock:((SLMarginMode)->())?
    var currentID:Int64 = 0
    var currentMarginStatus:SLMarginMode = .cross {
        didSet {
            fixedButton.isSelected = false
            crossButton.isSelected = false
            switch currentMarginStatus {
            case .cross:
                crossButton.isSelected = true
            case .fixed:
                fixedButton.isSelected = true
            }
        }
    }
    // 在currentMarginStatus 之后   调用 English: Called after currentMarginStatus
    var marginModeCanChange:Bool = true {
        didSet {
            fixedButton.isEnabled = marginModeCanChange
            crossButton.isEnabled = marginModeCanChange
            surebtn.isEnabled = marginModeCanChange
            if marginModeCanChange {
                unableTipContainerView.isHidden = true
                showTipTopMagrin.snp.remakeConstraints { make in
                    make.height.equalTo(32)
                }
                fixedButton.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
                crossButton.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
                surebtn.setTitleColor(.Ex.text4, for: .normal)
            }else{ //不可用的状态 English: Unavailable state
                unableTipContainerView.isHidden = false
                tipTopSpace.snp.remakeConstraints { make in
                    make.height.equalTo(32)
                }
                buttonTopSpace.snp.remakeConstraints { make in
                    make.height.equalTo(13)
                }
                fixedButton.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
                crossButton.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
                surebtn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
//                configBtnCannotUse(btn: fixedButton)
//                configBtnCannotUse(btn: crossButton)
            }
         
        }
    }
    //MARK: lazy
    ///名称 English: /Name
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"cp_extra_text173".ex_localized(), font: UIFont.ThemeFont.HeadMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    //取消按钮 English: Cancel button
    lazy var cancel: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.ThemeFont.BodyMedium
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.addTarget(self, action: #selector(cancelClick), for: UIControl.Event.touchUpInside)
        btn.setTitle("cp_overview_text56".ex_localized(), for: .normal)
        return btn
    }()
    
    lazy var containerView:UIStackView = {
       let v = UIStackView()
        v.axis = .vertical
        return v
    }()
    
    lazy var buttonsView = UIView()
    //占位间距 English: Space between occupying spaces
    lazy var buttonTopSpace: UIView = {
        let v = UIView()
        return v
    }()
    //逐仓 English: Warehouse by warehouse
    lazy var fixedButton: EXCheckButton = {
        let button = EXCheckButton()
        button.setTitle("cp_contract_setting_text2".ex_localized(), for: .normal)
        button.tapClickBlock = { [weak self] btn in
            self?.clickPositionTypeButton(sender: btn)
        }
        return button
    }()
 
    /// 全仓 English: /Full warehouse
    lazy var crossButton: EXCheckButton = {
        let button = EXCheckButton()
        button.setTitle("cp_contract_setting_text1".ex_localized(), for: .normal)
        button.tapClickBlock = { [weak self] btn in
            self?.clickPositionTypeButton(sender: btn)
        }
        return button
    }()
    
    
    
    lazy var unableTipImage : UIImageView = {
        let arrowImmg = UIImageView()
        arrowImmg.contentMode = .scaleAspectFit
        arrowImmg.image = UIImage.exs_themeImageNamed(imageName: "public_prompt")
        return arrowImmg
    }()
    //不可用提示 English: Unavailable prompt
    lazy var unableTipContainerView:UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()
    
    /// 不可改变仓位提示 English: /Cannot change position prompt
    lazy var unableTip: UILabel = {
        let ret = UILabel()
        ret.text = "cp_contract_setting_text7".ex_localized()
        ret.textColor = UIColor.ThemeState.warning
        ret.font = UIFont.ThemeFont.SecondaryRegular
        ret.textAlignment = .left
        ret.numberOfLines = 0
        return ret
    }()
   
    lazy var showTipTopMagrin: UIView = {
        let v = UIView()
        //什么是全仓和逐仓 顶部的间隙 English: What is the gap between the entire warehouse and the top of each warehouse
        return v
    }()
    //详细文案 English: Detailed copy
    lazy var showTipButtonContainer : UIView = {
        let v = UIView()
        let label = UILabel(text:"cp_content_text6".ex_localized(), font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        v.addSubview(label)
        v.addSubview(showTipButton)
        showTipButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-2)
            make.height.equalTo(10)
            make.width.equalTo(10)
        }
        label.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(btnclick))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return v
    }()
    
    //叠按钮 -展开收起 English: Stacking Button - Expand and Collapse
    lazy var showTipButton:UIButton = {
        let retBtn = UIButton(type: .custom)
        retBtn.setTitle("", for: .normal)
        retBtn.setImage(EXKitBundle.image(named: "public_arrow_down"), for: .normal)
        retBtn.exs_setEnlargeEdgeWithTop(0, left: 30, bottom: 0, right: 0)
        retBtn.rx.tap.subscribe { [weak self] (_) in
            self?.btnclick()
        }.disposed(by: self.exs_disposeBag)
        return retBtn
    }()
    
    //具体的内容头部间距 English: Specific content header spacing
    lazy var tipTopSpace: UIView = {
        let v = UIView()
        return v
    }()
    // 具体的内容 English: Specific content
    lazy var tipLabel: UILabel = {
        let text = "cp_contract_setting_text3".ex_localized() + "\n\n" + "cp_contract_setting_text4".ex_localized()
        let label = UILabel(text: text, font: UIFont.systemFont(ofSize: 14), textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    //具体的内容底部间距 English: Specific content bottom spacing
    lazy var tipBottomSpace: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()
    //确认按钮 English: confirm button
    lazy var surebtn:UIButton = {
        let btn = EXSButton()
        btn.extUseAutoLayout()
        btn.extSetCornerRadius(4)
        btn.backgroundColor = .Ex.main1
        btn.setTitleColor(.Ex.text4, for:.normal)
        btn.setTitle("cp_calculator_text16".ex_localized(), for: .normal)
        btn.titleLabel?.font = .Ex.medium(16)
        btn.extSetAddTarget(self, #selector(sure))
        return btn
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        //各个部分已处理顶部间距,使用时只处理其显示 English: The top spacing of each section has been processed, and only its display will be processed when used
        backgroundColor = UIColor.ThemeView.alertBg
        unableTipContainerView.addSubViews([unableTipImage,unableTip])
        unableTip.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview()
        }
        unableTipImage.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.left.equalToSuperview()
            make.centerY.equalTo(unableTip)
        }
        //按钮处理 English: Button processing
        buttonsView.exs_addSubViews([fixedButton,crossButton])
        crossButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        fixedButton.snp.makeConstraints { (make) in
            make.left.equalTo(crossButton.snp.right).offset(10)
            make.right.equalToSuperview()
            make.top.width.height.equalTo(crossButton)
        }
        
        self.addSubViews([
            titleLabel,cancel,
            containerView,
            surebtn
        ])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(20)
        }
        cancel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(60)
            make.height.equalTo(18)
            make.bottom.equalTo(titleLabel.snp.bottom)
        }
        cancel.newTitleResizeSize()
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom) //.offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        surebtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(containerView.snp.bottom) //.offset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-40)
        }
        containerView.addArrangedSubview(unableTipContainerView)
        containerView.addArrangedSubview(buttonTopSpace)
        containerView.addArrangedSubview(buttonsView)
        containerView.addArrangedSubview(showTipTopMagrin)
        containerView.addArrangedSubview(showTipButtonContainer)
        containerView.addArrangedSubview(tipTopSpace)
        containerView.addArrangedSubview(tipLabel)
        containerView.addArrangedSubview(tipBottomSpace)
        buttonTopSpace.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        showTipTopMagrin.snp.makeConstraints { make in
            make.height.equalTo(16)
        }
        tipTopSpace.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        tipBottomSpace.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }
    override func layoutSubviews(){
        super.layoutSubviews()
        self.roundCorners(corners: [.topLeft,.topRight], radius: 10)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension EXChangeMarginView{
    
    @objc func cancelClick(){
        EXAlert.dismiss()
    }
    
    @objc func sure(){
        cancelClick()
        clickMarginTypeBlock?(selectMarginMode())
    }
    
    func changeUIForCurrentSelectButton(sender : UIButton) {
        sender.isSelected = true
        if sender == self.fixedButton {
            self.crossButton.isSelected = false
        } else {

            self.fixedButton.isSelected = false
        }
    }

    func configBtnCannotUse(btn: EXCheckButton){
        btn.layer.borderColor = UIColor.ThemeBtn.disable.cgColor
        btn.backgroundColor = UIColor.ThemeBtn.disable
        if btn.isSelected{
            btn.checkImage.image = UIImage.svg_themeImageNamed(imageName: "public_selecteds_not")
        }
    }
    @objc func clickPositionTypeButton(sender : UIButton) {
        changeUIForCurrentSelectButton(sender: sender)
    }
  
    func selectMarginMode() -> SLMarginMode {
        if self.crossButton.isSelected {
            return .cross
        }
        if self.fixedButton.isSelected {
            return .fixed
        }
        return .cross
    }
    func reset(){
        //MARK: 恢复折叠状态 English: MARK: Restore folded state
        if self.showTipButton.isSelected {
            btnclick()
        }
            
    }
    @objc func btnclick(){
        self.showTipButton.isSelected = !self.showTipButton.isSelected
        if self.showTipButton.isSelected {
            self.showTipButton.imageView?.layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        }else {
            self.showTipButton.imageView?.layer.transform = CATransform3DIdentity
        }
        self.tipLabel.isHidden = !self.tipLabel.isHidden
        self.tipBottomSpace.isHidden = self.tipLabel.isHidden
    }
}

