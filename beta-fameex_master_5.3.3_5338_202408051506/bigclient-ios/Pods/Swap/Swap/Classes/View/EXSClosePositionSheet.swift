//
//  EXSClosePositionSheet.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/10.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
import IQKeyboardManagerSwift
import RxSwift
/// close
func scaleHeight(_ height:CGFloat) -> CGFloat {
    return (Device_H / 812) * height
}
class EXSClosePositionSheet: UIView {
    deinit{
        //print("deinit")
        NotificationCenter.default.removeObserver(self)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }

    var dissmiss: EXComVoidBlock?
    var closePositionCallback: ((String,EXSwapMarketOrderPriceType, String, EXSwapPositionModel?) -> ())?
    var priceType:EXSwapMarketOrderPriceType = .limitPrice
    var positionM : EXSwapPositionModel? {
        didSet {
            if let p = positionM,let pf = positionM?.ex_contractInfo {
                if self.volumeTextField.total { //预期盈亏计算会 不断更新positionM  防止覆盖掉 手动切换百分比 English: Expected profit and loss calculation will continuously update positionM to prevent manual switching percentage from being overwritten
                    self.volumeTextField.input.text = positionM!.canCloseVolumeDisplay
                }
                let unit = p.ex_contractInfo?.volumeUnit ?? ""
                canCloseValueLabel.text = positionM!.canCloseVolumeDisplay + unit
                volumeTextField.maxValue = positionM?.canCloseVolumeDisplay ?? "0"
                volumeTextField.symbolLabel.text = unit
                volumeValid.decail = p.ex_contractInfo?.volumeDecial ?? "0.01"
                volumeTextField.decimal = String(volumeValid.limetValue)
                infoVaild.decail = p.ex_contractInfo?.px_unit ?? "0.01"
                priceInput.input.delegate = infoVaild
                volumeTextField.input.delegate = volumeValid
                volumeTextField.input.keyboardType = pf.isVolumeDecialOne ? .numberPad : .decimalPad
                self.updateEstimated()
            }
        }
    }
    var _currentPercent = ""
    let infoVaild :EXSInputLimitDelegate = EXSInputLimitDelegate()
    let volumeValid : EXSInputLimitDelegate = EXSInputLimitDelegate()
    
    //MARK: lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        confingSubView()
        configContianView()
        subKeyBoard()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    func subKeyBoard(){
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).takeUntil(self.rx.deallocated).subscribe {[weak self] (event) in
            guard let mySelf = self else{return}
            if let height = (event.element?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height{
//                //print("===keyboardWillShowNotification")
                mySelf.containView.snp.updateConstraints({ (make) in
                    make.bottom.equalToSuperview().offset(-(height-44))
                })
            }
        }.disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).takeUntil(self.rx.deallocated).subscribe {[weak self] (event) in
            guard let mySelf = self else{return}
//            //print("===keyboardWillHideNotification")
            mySelf.containView.snp.updateConstraints { make in
                make.bottom.equalToSuperview()
            }
            }.disposed(by: disposeBag)
    }
    func confingSubView(){
        self.addSubViews([closeBtn,containView])
        closeBtn.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(Device_H - 470)
        }
        containView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(470)
            make.height.equalTo(470)
        }
    }
    func configContianView(){
        containView.backgroundColor =  UIColor.ThemeView.alertBg
        containView.addSubview(volumeTextField)
        containView.exs_addSubViews([titleLabel,nameLabel,cancelButton])
        containView.exs_addSubViews([dealTypeLabel,contractTypeLabel])
        containView.exs_addSubViews([marketPriceButton,firstBestButton,lastBestButton])
        containView.exs_addSubViews([
            priceInput,
            canCloseLabel,canCloseValueLabel,
            stopLP,stopLPvalue,dashlineLabel,
            closePositionButton
        ]
        )
//        containView.exs_roundCorners(corners: [.topLeft, .topRight], radius: 10)
        self.initLayout()
        closePositionButton.isEnabled = true
    }
    
    
    func updateEstimated(){
        //print("id = \(self.positionM!.instrument_id)  direction\(self.positionM!.side)")
        let limitPrice = self.priceInput.input.text ?? "0"
        let volum = self.volumeTextField.input.text ?? "0"
        let coin = self.positionM?.ex_contractInfo?.marginCoin ?? ""
        let result = self.positionM?.calculateEstimatedProfitAndLoss(priceType:self.priceType,colseVolum: volum ,limitPrice: limitPrice)
        if result != nil {
            stopLPvalue.text = result! + coin
            stopLPvalue.set_TextColor(result!)
        }
        
    }
    
    func show(){
        let mask = getWindowMask()
        mask?.alpha = 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showInWindow()
            self.frame = self.window!.bounds
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.25) {[weak self] in
                guard let newSelf = self else{
                    return
                }
                mask?.alpha = 1
                newSelf.containView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(0)
                }
                newSelf.layoutIfNeeded()
            }
        }
    }
    
    //MARK: button
    //MARK:
    func subscribeBtnEnable(){
        let validP1 = volumeTextField.input.rx.text.orEmpty
        let validP2 = priceInput.input.rx.text.orEmpty
        Observable.combineLatest(validP1, validP2).map {[weak self] (volum,price) -> Bool in
            guard let newSelf = self else { return false}
            if volum.count == 0 {
                return false
            }
            if newSelf.priceType == .limitPrice {
                if price.count == 0 {
                    return false //Price limit must be entered as a price
                }
            }
            return true
        }.bind(to: closePositionButton.rx.isEnabled).disposed(by: self.exs_disposeBag)
    }
    //MARK: lazy
    

    lazy var closeBtn : UIButton = {
        let btn = UIButton(type: .custom)
        btn.addTarget(self, action: #selector(clickCancelButton), for: UIControl.Event.touchUpInside)
        return btn
    }()
    lazy var containView: UIView = {
        let v = UIView()
        return v
    }()
    

    let titleLabel: UILabel = {
        let label = UILabel(text: "cp_overview_text2".ex_localized(), font: UIFont.ThemeFont.H3Bold, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
 
    lazy var nameLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.H3Bold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_overview_text56".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorMedium)
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    
    lazy var dealTypeLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.ThemeFont.MinimumRegular, textColor: nil, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        label.backgroundColor = UIColor.Ex.main3
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        return label
    }()
    
  
    lazy var contractTypeLabel: UILabel = {
        let label = UILabel(text: nil, font: UIFont.ThemeFont.SecondaryBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.center)
        label.ext_UseAutoLayout()
        return label
    }()
   

    lazy var priceInput : EXSBorderField = {
        let textField = EXSBorderField()
        textField.titleTop = true
        textField.leftLabel.text = "cp_calculator_text3".ex_localized()
        textField.ext_UseAutoLayout()
        textField.input.textColor = UIColor.ThemeLabel.colorMedium
        textField.setPlaceHolder(placeHolder: "cp_overview_text6".ex_localized())
        textField.unitLabel.text = ""
        textField.unitLabel.textColor = UIColor.ThemeLabel.colorLite
        textField.layer.cornerRadius = 4
        textField.bgView.layer.cornerRadius = 4
        textField.maxLenth = 9
        textField.input.keyboardType = UIKeyboardType.decimalPad
        textField.textfieldValueChangeBlock = { [weak self] _ in
            self?.updateEstimated()
        }
        textField.customBgColor = UIColor.ThemeView.alertBg
        return textField
    }()
    

    lazy var volumeTextField : EXSPersentageField = {
        let textField = EXSPersentageField()
        textField.input.textColor = UIColor.ThemeLabel.colorMedium
        textField.fullSelect()
        textField.input.keyboardType = UIKeyboardType.decimalPad
        textField.maxValue = "0"//
        textField.setPlaceHolder(placeHolder: "cp_overview_text8".ex_localized())
        textField.symbolLabel.text = "cp_overview_text9".ex_localized()
        textField.input.rx.text.orEmpty.changed.asObservable().subscribe { [weak self] (event) in
            if let str = event.element{
                if str.count > 15{
                    let offsetIndex: String.Index = str.index(str.startIndex, offsetBy:15)
                    let afterRange = str.index(after:str.startIndex)..<offsetIndex
                    textField.input.text = String(str[afterRange])
                }
                //print("textField.input =\(textField.input.text)")
                if str.count > 0 {
                    self?.updateEstimated()
                }
            }
        }.disposed(by: self.exs_disposeBag)
        textField.textfieldDidBeginBlock = {[weak self] in
            guard let mySelf = self else{return}

            if mySelf._currentPercent.count > 0 {
                mySelf._currentPercent = ""
                textField.input.text = ""
                if textField.input.text?.count == 0 {
                    self?.volumeTextField.emptyPersentage()
                }
            }
        }

        textField.input.keyboardType = UIKeyboardType.numberPad
        textField.customBgColor = UIColor.ThemeView.alertBg
        return textField
    }()


    ///Market price level
    lazy var marketPriceButton: RepeatButton = {
        let button = RepeatButton()
        button.setTitle("cp_overview_text53".ex_localized(), for: .normal)
        button.addTarget(self, action: #selector(clickMarketPriceButton), for: .touchUpInside)
        configBtn(button: button)
        return button
    }()

    ///Our best
    lazy var firstBestButton: RepeatButton = {
        let button = RepeatButton()
        button.setTitle(EXSwapMarketOrderPriceType.sameSideOptimal.introduce, for: .normal)
        button.addTarget(self, action: #selector(clickMarketPriceButton), for: .touchUpInside)
        configBtn(button: button)
        return button
    }()
    
    lazy var lastBestButton: RepeatButton = {
        let button = RepeatButton()
        button.setTitle(EXSwapMarketOrderPriceType.oppositeSideOptimal.introduce, for: .normal)
        button.addTarget(self, action: #selector(clickMarketPriceButton), for: .touchUpInside)
        configBtn(button: button)
        return button
    }()
    
    //MARK:
    //MARK:
    lazy var canCloseLabel: UILabel = {
        let label = UILabel(text:"cp_can_be_reduced".ex_localized(), font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()
    
    lazy var dashlineLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    //MARK:
    lazy var canCloseValueLabel: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
   
    lazy var stopLP: UILabel = {
        let label = UILabel(text:"cp_expected_profit_and_loss_simple".ex_localized(), font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(click))
        label.addGestureRecognizer(tap)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    
    
    lazy var stopLPvalue: UILabel = {
        let label = UILabel(text:"", font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeLabel.colorMedium, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    ///
    lazy var closePositionButton: EXSButton = {
        let button = EXSButton()
        button.setTitle("cp_content_text28".ex_localized(), for: .normal)
        button.titleLabel?.font = UIFont.ThemeFont.HeadBold
        button.addTarget(self, action: #selector(clickClosePositionButton), for: .touchUpInside)
        return button
    }()
    
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dashlineLabel.drawDashLine()
        self.containView.exs_roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
    private func initLayout() {
        let horMargin = 16
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(horMargin)
            make.top.equalTo(horMargin)
            make.height.equalTo(scaleHeight(22))
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
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.height.equalTo(20)
            make.width.equalTo(35)
        }
        
        contractTypeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(scaleHeight(18))
            make.width.equalTo(45)
            make.centerY.equalTo(dealTypeLabel)
            make.left.equalTo(dealTypeLabel.snp.right)//.offset(10)
        }
        
        self.priceInput.snp.makeConstraints { (make) in
            make.left.equalTo(horMargin)
            make.right.equalTo(-horMargin)
            make.top.equalTo(self.dealTypeLabel.snp.bottom).offset(26)
            make.height.equalTo(66)
        }
        
        marketPriceButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.priceInput.snp.bottom).offset(scaleHeight(8))
            make.left.equalTo(self.priceInput)
            make.height.equalTo(20)
        }
        firstBestButton.snp.makeConstraints { (make) in
            make.top.height.width.equalTo(marketPriceButton)
            make.left.equalTo(self.marketPriceButton.snp.right).offset(8)
        }
        lastBestButton.snp.makeConstraints { (make) in
            make.top.height.width.equalTo(marketPriceButton)
            make.left.equalTo(self.firstBestButton.snp.right).offset(8)
            make.right.equalTo(self.priceInput)
        }
        volumeTextField.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.priceInput)
            make.height.equalTo(100)
            make.top.equalTo(self.marketPriceButton.snp.bottom).offset(20)
            
        }
        canCloseLabel.snp.makeConstraints { make in
            make.top.equalTo(volumeTextField.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(horMargin)
        }
        canCloseValueLabel.snp.makeConstraints { make in
            make.top.equalTo(canCloseLabel)
            make.right.equalToSuperview().offset(-horMargin)
        }
        stopLP.snp.makeConstraints { make in
            make.top.equalTo(canCloseLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(horMargin)
        }
        
        dashlineLabel.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(stopLP.snp.bottom).offset(8)
            make.left.right.equalTo(stopLP)
        }
        stopLPvalue.snp.makeConstraints { make in
            make.top.equalTo(stopLP)
            make.right.equalToSuperview().offset(-horMargin)
        }
    
        self.closePositionButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(stopLP.snp.bottom).offset(28)
            make.right.equalTo(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-44)
        }
    }
}

//MARK: action
extension EXSClosePositionSheet {
    
    //MARK: alert
    @objc func click(){
        let alert = EXCommonAlert()
        alert.configAlert(title: "cp_expected_profit_and_loss".ex_localized(), message: "cp_contract_close_expected_profit_and_loss_msg".ex_localized(), bottomOnlyOneBtn: true) { [weak alert] type in
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
    

    @objc func clickCancelButton() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
       
        let mask = getWindowMask()
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let `self` = self else{ return }
            mask?.alpha = 0
            self.containView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(470)
            }
            self.layoutIfNeeded()
        }, completion: { [weak self] _ in
            guard let `self` = self else{ return }
            self.removeFromWindow()
            self.dissmiss?()
        })
    }
    
    func unselectOtherButton(sender:UIButton) {
        if sender != marketPriceButton {
            unselectButton(sender: marketPriceButton)
        }
        if sender != firstBestButton {
            unselectButton(sender: firstBestButton)
        }
        if sender != lastBestButton {
            unselectButton(sender: lastBestButton)
        }
    }
    
    func changePriceType(sender:UIButton) {
        priceType = .limitPrice
        if sender.isSelected == false{
            return
        }
        if sender == marketPriceButton {
            priceType = .marketPrice
            EXNewTracking.shared.track(event: .swapPositionMarketPrice, info: [:])
        }
        if sender == firstBestButton {
            priceType = .sameSideOptimal
            EXNewTracking.shared.track(event: .swapbestcounterparty, info: [:])
        }
        if sender == lastBestButton {
            priceType = .oppositeSideOptimal
            EXNewTracking.shared.track(event: .swapOwnBest, info: [:])
        }
    }
    func unselectButton(sender:UIButton) {
        sender.isSelected = false
        sender.layer.borderColor = UIColor.ThemeView.seperator.cgColor
    }
    
    @objc func clickMarketPriceButton(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        sender.layer.borderColor = UIColor.ThemeBtn.highlight.cgColor
        if sender.isSelected {
            sender.layer.borderColor = UIColor.ThemeBtn.highlight.cgColor

        }else {
            sender.layer.borderColor = UIColor.ThemeView.seperator.cgColor
        }
        self.unselectOtherButton(sender: sender)
        changePriceType(sender: sender)
        self.priceInput.marketPriceLabel.text = "   " + (sender.titleLabel?.text ?? "")
        self.priceInput.marketPriceLabel.isHidden = !sender.isSelected
        priceInput.isUserInteractionEnabled = !sender.isSelected
        updateEstimated()
    }
    
    @objc func clickClosePositionButton() {
        let res = self.positionM?.closeMinValueLimit(input: self.volumeTextField.input.text ?? "0")
        if res!.0 == false{
            EXAlert.showFail(msg: res!.1,in: self)
            return
        }
        self.closePositionCallback?(self.priceInput.input.text ?? "0", self.priceType,self.volumeTextField.input.text ?? "0",self.positionM)
    }
    
    
    func configBtn(button: RepeatButton){
        button.showsTouchWhenHighlighted = false
        button.adjustsImageWhenHighlighted = false
        button.titleLabel?.font = UIFont.ThemeFont.SecondaryBold
        button.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        button.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)
        button.setBackgroundColor(color: UIColor.ThemeView.seperator, forState: .normal)
        button.layer.borderColor = UIColor.ThemeView.seperator.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 2
        button.setBackgroundColor(color: UIColor.clear, forState: .highlighted)
        button.setBackgroundColor(color: UIColor.clear, forState: .selected)
    }
}

