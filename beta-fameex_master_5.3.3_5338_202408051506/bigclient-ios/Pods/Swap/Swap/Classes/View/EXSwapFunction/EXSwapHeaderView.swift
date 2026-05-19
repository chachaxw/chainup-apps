//
//  EXSwapHeaderView.swift
//  Chainup
//
//  Created by ZYJ on 2023/10/11.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
private let kAnimationDuration = 0.1

class EXSwapHeaderView: EXCOCustomBaseView {
    override class var viewHeight: CGFloat{
        return 46
    }
    var clickMarginTypeBlock:((SLMarginMode)->())?
    var rateClick: EXComVoidBlock?
    private var isShow: Bool = false
    //用户配置 English: User Configuration
    var currentUserConfig = SLUserConfig()

    var firstButtonWillClick:EXComVoidBlock?
    var leverButtonClick:EXComVoidBlock?

    lazy var firstButton: EXSDirectionButton = {
        let b = EXSDirectionButton()
        b.container.backgroundColor = UIColor.ThemeView.bgIcon
        b.arrowAnimator = false
        b.spaceBetweenImageAndTitle = 22
        return b
    }()
    lazy var secondButton: EXSDirectionButton = {
        let b = EXSDirectionButton()
        b.container.backgroundColor = UIColor.ThemeView.bgIcon
        b.spaceBetweenImageAndTitle = 15
        b.arrowAnimator = false
        return b
    }()
    
    lazy var rateTitleLabel: UILabel = {
        let v = UILabel() //需要下滑线点击资金费率的弹框 English: Need to click on the funding rate pop-up box with a sliding line
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(rateInfo))
        v.addGestureRecognizer(tap)
        v.isUserInteractionEnabled = true
        return v
    }()
    lazy var line: UILabel = {
        let v = UILabel()
        return v
    }()
    lazy var rateLabel: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.ThemekLine.up
        v.text = "0"
        return v
    }()
    
  
    
    
    override func setSubView() {
        
        configSubView()
//        setupBtn()
        setLabel(label: rateLabel)
        setLabel(label: rateTitleLabel)
        setButton(btn: firstButton)
        setButton(btn: secondButton)

        rateTitleLabel.text = "cp_overview_text26".ex_localized()

        firstButton.text(content: "cp_contract_setting_text1".ex_localized())
        firstButton.alighment = .marginCenter
        secondButton.text(content: "20X")
        firstButton.rx.controlEvent(.touchUpInside)
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe { [weak self] (_) in
                self?.firstButtonWillClick?()
        }.disposed(by: self.exs_disposeBag)
                
        secondButton.rx.controlEvent(.touchUpInside)
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe { (_) in
            self.backTapped()
            self.leverButtonClick?()
            self.secondButton.normalStyle()
        }.disposed(by: self.exs_disposeBag)
        
       
    }
    
    
    func configSubView(){
        
        self.addSubViews([firstButton,secondButton,rateTitleLabel,line,rateLabel])
        firstButton.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(70~)
            make.top.equalToSuperview().offset(12)
        }
        secondButton.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.left.equalTo(firstButton.snp.right).offset(12)
            make.width.equalTo(56~)
            make.top.equalToSuperview().offset(12)
        }
        
        rateTitleLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(14)
            make.top.equalToSuperview().offset(12)
        }
        
        line.snp.makeConstraints { make in
            make.left.right.equalTo(rateTitleLabel)
            make.top.equalTo(rateTitleLabel.snp.bottom).offset(1)
            make.height.equalTo(1)
        }
        rateLabel.snp.makeConstraints { make in
            make.top.equalTo(rateTitleLabel.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(14)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        firstButton.roundCorners(corners: .allCorners, radius: 4)
        secondButton.roundCorners(corners: .allCorners, radius: 4)
        line.drawDashLine()
    }

    func setRate(rateText:String) {
        
        rateLabel.text = rateText
    }
    func headerBgColor() -> UIColor {
        return UIColor.ThemeTab.bg
    }
    
    @objc func backTapped() -> Void {
        self.firstButton.normalStyle()
        isShow = false
    }
    private func setButton(btn:EXSDirectionButton) {
        btn.titleLabel.font = UIFont.ThemeFont.SecondaryMedium
        btn.titleLabel.textColor = UIColor.ThemeLabel.colorLite
    }
    private func setLabel(label:UILabel) {
        label.font = UIFont.ThemeFont.SecondaryMedium
        label.textColor = UIColor.ThemeLabel.colorMedium
    }
    
    func setUserData(marginMode:String, leverage:String) {
     
        firstButton.text(content: marginMode)
        secondButton.text(content: leverage)
    }

    func alertMarginView(){
        let v = EXChangeMarginView(frame: CGRect.zero)
        v.currentMarginStatus = self.currentUserConfig.marginMode()
        v.marginModeCanChange = self.currentUserConfig.marginModeCanChange()
        
        v.clickMarginTypeBlock = {[weak self] mode in
            self?.backTapped()
            self?.clickMarginTypeBlock?(mode)
        }
        EXAlert.showSheet(sheetView: v)
        
    }
    //资金费率弹框 English: Fund rate pop-up
    @objc func rateInfo(){
        self.rateClick?()
    }
}

// MARK: - Animation
private extension EXSwapHeaderView {
   
    func animateFor(indicator: CAShapeLayer = CAShapeLayer(), title: CATextLayer = CATextLayer(), show: Bool, complete: () -> Void) -> Void {

        animateFor(indicator: indicator, reverse: show) {
        }
        complete()
    }
    
    /// 指示符 English: /Indicator
    func animateFor(indicator: CAShapeLayer = CAShapeLayer(), reverse: Bool, complete: () -> Void) -> Void {
        if reverse {
            indicator.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        }else {
            indicator.transform = CATransform3DIdentity
        }
        complete()
    }
    
    func topTabbarController() -> UIViewController? {
        guard let appDelegate = UIApplication.shared.delegate else {
            return nil
        }
        if let tbC = appDelegate.window??.rootViewController{
            return tbC
        }
        return nil
        
    }
    var animateViewTopMargin:CGFloat {
    
        return EX_NAV_SCREEN_HEIGHT + 52
    }
}


///可用view English: /Available views
class EXAvailableView: EXCOCustomBaseView{

    var canTransfer: Bool = true{
        didSet{
            self.isUserInteractionEnabled = canTransfer
            self.availableAssetBtn.isEnabled = canTransfer
        }
    }
    var btnBlock: EXComVoidBlock?
    
    override class var viewHeight: CGFloat{
        return 32
    }
    override func setSubView() {
        configSubView()
        setupBtn()
        availableAssetBtn.setEnlargeEdgeWithTop(5, left: 60, bottom: 0, right: 0)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    func configSubView(){
        self.backgroundColor = UIColor.ThemeView.card1
        self.addSubViews([avivailTitleLabel,availableAssetLabel,availableAssetBtn])
        avivailTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        availableAssetBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.width.equalTo(14)
            make.height.equalTo(14)
            make.centerY.equalToSuperview()
        }
        
        availableAssetLabel.snp.makeConstraints { make in
            make.right.equalTo(availableAssetBtn.snp.left).offset(-4)
            make.centerY.equalToSuperview()
        }
    }
    
 
    
    
    
    lazy var avivailTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.ThemeFont.SecondaryBold
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.text = "cp_overview_text19".ex_localized()
        return label
    }()
    lazy var availableAssetLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.ThemeFont.SecondaryBold
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()

    //划转 English: Transfer
    lazy var availableAssetBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(click), for: UIControl.Event.touchUpInside)
        btn.setTitle("", for: .normal)
        return btn
    }()
    
    @objc func click(){
        self.btnBlock?()
    }
    
    
    
}
extension EXAvailableView{
    fileprivate func setupBtn() {
        availableAssetBtn.setImage(UIImage.svg_themeImageNamed(imageName: "public_transfer"), for: .normal)
        availableAssetBtn.setImage(UIImage.svg_themeImageNamed(imageName: "public_transfer_not"), for: .disabled)
        availableAssetBtn.setTitle("", for: .normal)
        availableAssetBtn.setTitle("", for: .disabled)
        setAsset(amount:"",unit: " ")
    }

    func setAsset(amount:String,unit:String) {
        availableAssetLabel.text = amount + unit
//        avivailTitleLabel.text = "cp_overview_text19".ex_localized()
    }
}


