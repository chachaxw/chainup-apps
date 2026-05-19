//
//  EXChangeMarginAmountSheet.swift
//  Chainup
//
//  Created by ZYJ on 2023/5/7.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit
class EXChangeMarginAmountSheet: UIView {
    var confimModelCallBack:(() -> ())?
    var currentIndex = 0
    var positionModel : EXSwapPositionModel?{
        didSet {
            
            if let pm = positionModel {
                
                infoVaild.decail = positionModel?.ex_contractInfo?.value_unit ?? ""
                volumeTextField.decimal = String(infoVaild.limetValue)

                volumeTextField.input.delegate = infoVaild
                volumeTextField.symbolLabel.text = pm.ex_contractInfo?.margin_coin
                setMarginValue(value: pm.im)
                let reality = self.positionModel?.calculateLeverage() ?? "1"
                leverValueView.setRightText(String(format:"%@X",reality.exs_decimalString(1)))
                setPriceValue(value: pm.calculateReducePrice())
                volumeTextField.input.keyboardType = UIKeyboardType.decimalPad
                
                if let cm = pm.ex_contractInfo {
                    if (cm.area == .CONTRACT_BLOCK_SIMULATION){
                        transferBtn.isEnabled = false
                    }
                }
            }
        }
    }
    
    var infoVaild:EXSInputLimitDelegate = EXSInputLimitDelegate()

    var asset : EXCItemCoinModel? {
        get {
            return EXSwapPersonInfo.shared.getSwapAssetItem(withCoin: positionModel?.ex_contractInfo?.margin_coin)
        }
    }
    
    
     //MARK: lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.alertBg
        configSubView()
        configTitle()
      
    }
    

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor.ThemeView.alertBg
        configSubView()
        configTitle()
    }
    
    
    
    //MARK: lazy
    
    let segmentedView = JXSegmentedView()

     ///必须持有，否则文案显示不处理 English: /Must be held, otherwise the copy will not be processed
     lazy var linesegmentedDataSource: EKContractIndicatorSegmentDatasource = {
         let source = EKContractIndicatorSegmentDatasource()
         source.titles = ["cp_order_text20".ex_localized(),"cp_order_text21".ex_localized()]
         source.titleNormalFont = UIFont.ThemeFont.BodyMedium
         source.titleSelectedFont = UIFont.ThemeFont.BodyMedium
         return source
     }()
     
     lazy var lineIndicatorLienView: EKIndicatorSegmentIndicator = {
         let view = EKIndicatorSegmentIndicator()
         return view
     }()
    /// 取消 English: /Cancel
    lazy var cancelButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_overview_text56".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorMedium)
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    //数量输入框 English: Quantity input box
    lazy var volumeTextField : EXSPersentageField = {
        let textField = EXSPersentageField()
      
        textField.input.textColor = UIColor.ThemeLabel.colorLite
        
        textField.input.keyboardType = UIKeyboardType.decimalPad
        textField.decimal = "2"//精度 English: accuracy
        textField.maxValue = "0"//最大值 English: Maximum value
        textField.setPlaceHolder(placeHolder: "cl_volume".ex_localized())
        
        textField.symbolLabel.text = "cp_overview_text9".ex_localized()
     
        textField.input.rx.text.orEmpty.changed.asObservable().subscribe { (event) in
            self.textFieldValueHasChanged(textField: textField.input)
        }.disposed(by: self.exs_disposeBag)
        textField.textfieldDidBeginBlock = {[weak self] in
            guard let mySelf = self else{return}

            if textField.input.text?.count == 0 {
                mySelf.volumeTextField.emptyPersentage()
                mySelf.confirmButton.isEnabled = false
            }
        }
        textField.clickBtnBlock = { [weak self] _ in
            guard let mySelf = self else{return}
            mySelf.textFieldValueHasChanged(textField: textField.input)
        }
        textField.input.keyboardType = UIKeyboardType.numberPad
        textField.customBgColor = UIColor.ThemeView.alertBg
        return textField
    }()
    /// 可用余额 English: /Available balance
    lazy var availableLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.text = "cp_overview_text19".ex_localized()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
//        label.attributedText = getAvailable(price: "--", volume: "")
        return label
    }()
    /// 可用余额 English: /Available balance
    lazy var availableValueLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.SecondaryMedium
//        label.attributedText = getAvailable(price: "--", volume: "")
        return label
    }()
    lazy var headerSeparateView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var priceValueView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.setLeftText("cp_calculator_text4".ex_localized())
        return view
    }()
    lazy var leverValueView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.setLeftText("cp_order_text27".ex_localized())
        return view
    }()
    lazy var marginValueView: SLSwapHorDetailView = {
        let view = SLSwapHorDetailView()
        view.ext_UseAutoLayout()
        view.setLeftText("cp_order_text12".ex_localized())
        return view
    }()
    lazy var transferBtn:RepeatButton = {
        let btn = RepeatButton(type: .custom)
//        btn.svg_themeImageNamed(imageName: "public_transfer")
        btn.setImage(UIImage.svg_themeImageNamed(imageName: "public_transfer"), for: .normal)
        btn.setImage(UIImage.svg_themeImageNamed(imageName: "public_transfer_not"), for: .disabled)
        return btn
    }()
    private lazy var confirmButton: EXButton = {
        let button = EXButton(buttonType: .custom, title: "cp_calculator_text16".ex_localized(), titleFont: UIFont.ThemeFont.HeadBold, titleColor: UIColor.white)
        button.selectStyle = .blueColor
        button.ext_SetAddTarget(self, #selector(clickConfirmButton))
        return button
    }()
}



extension EXChangeMarginAmountSheet{
    
    
    func configAdd() {
        let maxValue = asset?.canUseAmount.toValuePrecision(withContract: positionModel?.instrument_id ?? 0) ?? "0"
        if let marginCoin = positionModel?.ex_contractInfo?.margin_coin {
            availableLabel.text = "cp_overview_text19".ex_localized()
            availableValueLabel.text =  maxValue + marginCoin
        }
        volumeTextField.maxValue = maxValue
       

    }
    func configDecrease() {
        let maxValue = positionModel?.canSubMarginAmount.toValuePrecision(withContract: positionModel?.instrument_id ?? 0) ?? "0"
        if let marginCoin = positionModel?.ex_contractInfo?.margin_coin {
            availableLabel.text = "cp_order_text23".ex_localized()
            availableValueLabel.text =  maxValue + marginCoin
        }
        volumeTextField.maxValue = maxValue
    }
    func resetVolumeTextField() {
        volumeTextField.input.text = ""
        volumeTextField.emptyPersentage()
        textFieldValueHasChanged(textField: volumeTextField.input)
    }
    
    func setMarginValue(value:String) {
        if let pm = positionModel {
            
            marginValueView.setRightText(value.toValuePrecision(withContract: pm.instrument_id) + (pm.ex_contractInfo?.margin_coin ?? "USDT"))
        }
    }
    func setPriceValue(value:String) {
        if let pm = positionModel {
            var force = value
            if force != "--"{
                force = value.toPricePrecision(withContractID: pm.instrument_id)
            }
            priceValueView.setRightText(force + (pm.ex_contractInfo?.quote_coin ?? "USDT"))
        }
    }
    //MARK: 输入更新刷新页面 English: MARK: Input updates to refresh the page
    func textFieldValueHasChanged(textField:UITextField) {
        guard let pm = self.positionModel else {
            return
        }
        var text = textField.text ?? "0"
        var amount = "0"
        if self.currentIndex == 0 {
            amount = pm.canUseAmount
        }else {
            amount = pm.canSubMarginAmount
        }
      
        if self.currentIndex == 0 {
            amount = pm.im.bigAdd(text)
        }else {
            amount = pm.im.bigSub(text)
        }
        confirmButton.isEnabled = amount.greaterThan("0")
        let position = EXSwapPositionModel()
        position.cur_qty = pm.cur_qty
        position.index_px = pm.index_px
        position.side = pm.side
        position.keepRate = pm.keepRate
        position.maxFeeRate =  pm.maxFeeRate
//        position.realizedAmount = pm.realizedAmount
//        position.unRealizedAmount = pm.unRealizedAmount
        position.ex_contractInfo = pm.ex_contractInfo
        position.im = amount
        position.marginRate = pm.marginRate
        
        let forcePrice = position.calculateReducePrice()
        if forcePrice == "--"{
            leverValueView.setRightText("-- X")
        }else{
            let reality = position.calculateLeverage()
            leverValueView.setRightText(String(format:"%@X",reality))
        }
       
        if self.positionModel?.position_type == .allType { // 全仓 English: Full warehouse
            return
        }
        setPriceValue(value: forcePrice)
        setMarginValue(value: amount)
    }
    
}
//MARK: action
extension EXChangeMarginAmountSheet{
    
    /// 点击取消 English: /Click to cancel
    @objc func clickCancelButton() {
        EXAlert.dismiss()
    }
    @objc func clickAddButton() {
        availableValueLabel.snp.updateConstraints { make in
            make.right.equalToSuperview().offset(-30)
        }
        transferBtn.isHidden = false
        resetVolumeTextField()
        configAdd()
    }
    
    @objc func clickDecreaseButton() {
        availableValueLabel.snp.updateConstraints { make in
            make.right.equalToSuperview().offset(-16)
        }
        transferBtn.isHidden = true
        resetVolumeTextField()
        configDecrease()
    }
    
    @objc func clickConfirmButton() {
        if self.volumeTextField.input.text == nil {
            return
        }
       
        if let pm = self.positionModel {
            var im = pm.im
            let text = self.volumeTextField.input.text
            im = im.toValuePrecision(withContract: positionModel!.instrument_id)
            if text != nil,text!.isEmpty {
                EXAlert.showFail(msg: "redpacket_send_inputAmount".ex_localized())
                return
            }

            var currentIM = "0"
            if self.currentIndex == 0 {
                currentIM = im.bigAdd(text ?? "0")
            }else {
                currentIM = im.bigSub(text ?? "0")
            }
            
            currentIM = currentIM.bigSub(im).toValuePrecision(withContract: positionModel!.instrument_id)
                     
            confirmButton.isUserInteractionEnabled = false
            
            EXContractNetwork.changePositionMargin(id: self.positionModel!.instrument_id, positionId: self.positionModel!.pid, amount: currentIM, type:self.currentIndex == 0 ? "1" : "2") {[weak self] success in
                
                if success {
                    self?.confimModelCallBack?()
                }
                self?.confirmButton.isUserInteractionEnabled = true
            }
        }
    }
}

//MARK: UI
extension EXChangeMarginAmountSheet: JXSegmentedViewDelegate{
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        if currentIndex == index {
            return
        }
        currentIndex = index
        if index == 0 {
            clickAddButton()
        }else{
            clickDecreaseButton()
        }
    }
}
//MARK: UI
extension EXChangeMarginAmountSheet{
    func configTitle(){
        self.segmentedView.delegate = self
        self.segmentedView.dataSource = linesegmentedDataSource
        self.segmentedView.indicators = [lineIndicatorLienView]
    }
    
    func configSubView(){
        exs_roundCorners(corners: [.topLeft, .topRight], radius: 10)
        
        exs_addSubViews([segmentedView,cancelButton,headerSeparateView])
        exs_addSubViews([volumeTextField,availableLabel,availableValueLabel,transferBtn])
        exs_addSubViews([priceValueView,leverValueView,marginValueView])
        addSubview(confirmButton)
        segmentedView.contentEdgeInsetLeft = 0
        segmentedView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-100)
            make.height.equalTo(32)
        }
        self.cancelButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(60)
            make.height.equalTo(20)
            
        }
        headerSeparateView.snp.makeConstraints { (make) in
            make.top.equalTo(segmentedView.snp.bottom).offset(1)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
        volumeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(headerSeparateView.snp.bottom).offset(scaleHeight(16))
            make.leading.equalTo(segmentedView)
            make.trailing.equalTo(cancelButton)
            make.height.equalTo(100)
        }
       
        availableLabel.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(volumeTextField.snp.bottom).offset(8)
        }
        availableValueLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalTo(availableLabel)
        }
        transferBtn.snp.makeConstraints { (make) in
            make.trailing.equalTo(cancelButton)
            make.centerY.equalTo(availableLabel)
        }
        
        priceValueView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(scaleHeight(20))
            make.top.equalTo(availableLabel.snp.bottom).offset(scaleHeight(28))
        }
        leverValueView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(scaleHeight(20))
            make.top.equalTo(priceValueView.snp.bottom).offset(scaleHeight(12))
        }
        marginValueView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(scaleHeight(20))
            make.top.equalTo(leverValueView.snp.bottom).offset(scaleHeight(12))
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(marginValueView.snp.bottom).offset(scaleHeight(28))
            make.leading.equalTo(segmentedView)
            make.trailing.equalTo(cancelButton)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(scaleHeight(-44))
        }
    }
}

