//
//  EXSpeedClosePositionSheet.swift
//  Chainup
//
//  Created by ZYJ on 2023/5/6.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXSpeedClosePositionSheet: UIView {
    /// 平仓回调 English: /Closing callback
    var closePositionCallback: (() -> ())?
    
    var dissmiss: EXComVoidBlock?
    var positionModel : EXSwapPositionModel? {
        didSet{
            guard let positionModel = positionModel else {
                return
            }

            self.nameLabel.text = positionModel.ex_contractInfo?.showName() ?? ""
            self.contractTypeLabel.text = positionModel.position_type.introduce + "\(positionModel.leverageLevel)X"
            self.contractTypeLabel.titleResizeSize()
            self.volmnValueLabel.text = "cp_order_text50".ex_localized() + ": " + positionModel.curQtyVolume + (positionModel.ex_contractInfo?.volumeUnit ?? "")
            updateEstimated()
        }
    }
    

    func updateEstimated(){
        let volum = positionModel?.curQtyVolume ?? "0"//数量 English: quantity
        let coin = self.positionModel?.ex_contractInfo?.marginCoin ?? ""
        let result = self.positionModel?.calculateEstimatedProfitAndLoss(priceType:.marketPrice,colseVolum: volum)
        if result != nil {
            stopLPvalue.text = result! + coin
            stopLPvalue.set_TextColor(result!)
        }else{
            stopLPvalue.text = "-- " + coin
            stopLPvalue.textColor = UIColor.Ex.text2
        }
    }
    
    
    
    //MARK: lazy
    //取消按钮 English: Cancel button
    lazy var closeBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(clickCancelButton), for: UIControl.Event.touchUpInside)
        return btn
    }()
    lazy var containView: UIView = {
        let v = UIView()
        return v
    }()
    
    /// 标题 English: /Title
    let titleLabel: UILabel = {
        let label = UILabel(text: "cp_order_text18".ex_localized(), font: UIFont.ThemeFont.H3Bold, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    /// 合约名称 English: /Contract Name
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.H3Bold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    /// 取消 English: /Cancel
    lazy var cancelButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_overview_text56".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorMedium)
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    /// 多 空 类型 English: /Multiple empty type
    lazy var dealTypeLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.MinimumRegular, textColor: nil, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
    /// 全仓逐仓类型 English: /Full warehouse by warehouse type
    lazy var contractTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
    
    
    
    lazy var priceTitle: UILabel = {
        let label = UILabel(text:"cp_overview_text6".ex_localized(), font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var newPriceBottomTipTitle: UILabel = {
        let label = UILabel(text: "cp_order_text49".ex_localized(), font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .right)
        return label
    }()
   
    lazy var newPriceTopTipTitle: UILabel = {
        let label = UILabel(text:"cp_order_text48".ex_localized(), font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
  
    ///
    lazy var volmnTitle: UILabel = {
        let label = UILabel(text:"cp_overview_text8".ex_localized(), font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var volmnValueLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.BodyMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var stopLP: UILabel = {
        let label = UILabel(text:"cp_expected_profit_and_loss_simple".ex_localized(), font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var stopLPvalue: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    /// 平仓 English: /Closing position
    lazy var closePositionButton: EXSButton = {
        let button = EXSButton()
        button.setTitle("cp_content_text29".ex_localized(), for: .normal)
        button.titleLabel?.font = UIFont.ThemeFont.HeadBold
        button.addTarget(self, action: #selector(clickClosePositionButton), for: .touchUpInside)
        return button
    }()
    
    
    lazy var dashlineLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    let priceContainer = UIView()
    let volumContainer = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        confingSubView()
        priceContainer.layer.cornerRadius = 4
        priceContainer.layer.masksToBounds = true
        volumContainer.layer.cornerRadius = 4
        volumContainer.layer.masksToBounds = true
//        priceContainer.exs_roundCorners(corners: .allCorners, radius: 4)
//        volumContainer.exs_roundCorners(corners: .allCorners, radius: 4)
        containView.backgroundColor = UIColor.ThemeView.alertBg
        priceContainer.backgroundColor = UIColor.ThemeView.newbg
        volumContainer.backgroundColor = UIColor.ThemeView.newbg
        containView.exs_addSubViews([titleLabel,nameLabel,cancelButton])
        containView.exs_addSubViews([dealTypeLabel,contractTypeLabel])
        containView.exs_addSubViews([priceContainer,volumContainer])
        containView.exs_addSubViews([closePositionButton])
        containView.exs_addSubViews([dashlineLabel])
        let horMargin = 16
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(horMargin)
            make.top.equalTo(horMargin)
            make.height.equalTo(scaleHeight(28))
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(5)
            make.height.equalTo(scaleHeight(19))
            make.centerY.equalTo(titleLabel)
        }
        self.cancelButton.snp.makeConstraints { (make) in
            make.right.equalTo(-horMargin)
            make.bottom.height.equalTo(self.titleLabel)
        }
        
        dealTypeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(horMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(scaleHeight(16))
            make.width.equalTo(35)
        }
        
        contractTypeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(scaleHeight(18))
            make.centerY.equalTo(dealTypeLabel)
            make.width.equalTo(30)
            make.left.equalTo(dealTypeLabel.snp.right)//.offset(10)
        }
        priceContainer.snp.makeConstraints { make in
            make.top.equalTo(dealTypeLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(horMargin)
            make.right.equalToSuperview().offset(-horMargin)
            make.height.equalTo(64)
        }
        volumContainer.snp.makeConstraints { make in
            make.top.equalTo(priceContainer.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(horMargin)
            make.right.equalToSuperview().offset(-horMargin)
            make.height.equalTo(70)
        }
        
        priceContainer.addSubViews([priceTitle, newPriceBottomTipTitle,newPriceTopTipTitle])
        priceTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        newPriceBottomTipTitle.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-12)
        }
        newPriceTopTipTitle.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(12)
        }
        
        //        newPriceTopTipTitle.snp.makeConstraints { make in
        //            make.right.equalToSuperview().offset(-10)
        //            make.bottom.equalToSuperview().offset(-12)
        //        }
        
        volumContainer.addSubViews([volmnTitle,volmnValueLabel,stopLP,stopLPvalue])
        
        volmnTitle.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
        }
        
        volmnValueLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(volmnTitle)
        }
        
        stopLP.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        stopLPvalue.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(stopLP)
        }
        /// 必须加在父视图上 English: /Must be added to the parent view
        dashlineLabel.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalTo(volumContainer.snp.left).offset(10)
            make.width.equalTo(60)
            make.top.equalTo(volumContainer.snp.bottom).offset(-6)
            
        }
        self.closePositionButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(volumContainer.snp.bottom).offset(32)
            make.right.equalTo(-16)
            make.height.equalTo(42)
            make.bottom.equalToSuperview().offset(-37)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containView.exs_roundCorners(corners: [.topLeft, .topRight], radius: 10)
        self.dashlineLabel.drawDashLine()
    }
    
    func confingSubView(){
        let containH:CGFloat = 348
        self.addSubViews([closeBtn,containView])
        closeBtn.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(Device_H - containH)
        }
        containView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(containH)
            make.height.equalTo(containH)
        }
    }
    
    /// 点击取消 English: /Click to cancel
    @objc func clickCancelButton() {
        self.dismissSelf()
       
    }
    /// 点击平仓 English: /Click to close the position
    @objc func clickClosePositionButton() {

        EXNewTracking.shared.trackPage(name: .lightClose, isEnter:true)
        self.closePositionCallback?()
        //print("clickClosePositionButton=\(String(describing: self.closePositionCallback))")
    }
    
    
    //MARK: 预估盈亏弹窗 English: MARK: Estimated profit and loss pop-up window
    @objc func click(){
        let alert = EXCommonAlert()
        alert.configAlert(title: "cp_expected_profit_and_loss".ex_localized(), message: "cp_contract_quick_close_expected_profit_and_loss_msg".ex_localized(), bottomOnlyOneBtn: true) { [weak alert] type in
            alert?.removeFromSuperview()
            EXWindowAlert.shared.dissmiss()
        }
        EXWindowAlert.shared.show(view: alert)
        alert.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    
}
extension EXSpeedClosePositionSheet{
    //显示 English: display
    func show(){
        let mask = self.getWindowMask()
        mask?.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showInWindow()
            self.frame = self.window!.bounds
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.25) {[weak self] in
                mask?.alpha = 1
                guard let newSelf = self else{
                    return
                }
                newSelf.containView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(0)
                }
                newSelf.layoutIfNeeded()
            }
        }
    }
    
    func dismissSelf(){
        let mask = self.getWindowMask()
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            mask?.alpha = 0
            guard let `self` = self else{ return }
            self.containView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(360)
            }
            self.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let `self` = self else{ return }
            self.removeFromWindow()
            self.dissmiss?()
        })
    }
}

