//
//  EXSChangeLevelSheet.swift
//  EXSwapSDK
//
//  Created by ZYJ on 2023/4/29.
//

import UIKit
import EXKit
class EXSChangeLevelSheet: UIView {
    
    var makeOrderViewModel : EXSwapMarkOrderViewModel?
    var multiplierCoin:String = ""
    var leverAndMaxCoinDic = [String:String]()
    var userMaxLevel: String = ""
    var userCurrentLeverage = "20"
    var attainableMaxLevel:String = ""
    var minLevel:String = ""
    var sliderChangedValue:Float = 0
    var clickConfirmButtonBlock : ((String)->())?
  
    
     //MARK: lifecycle
    init(frame: CGRect, minLevel: String, maxLevel: String,availableLevel:String) {
    
        super.init(frame: frame)
        self.minLevel = minLevel
        attainableMaxLevel = maxLevel
        userMaxLevel = availableLevel
        exs_roundCorners(corners: [.topLeft, .topRight], radius: 10)
        self.backgroundColor = UIColor.ThemeView.bg
        
        containerV.exs_addSubViews([maxCoinTipDescLabel,maxCoinTipValueLabel,canOpenVolDescLabel,canOpenVolValueLabel])
        
        exs_addSubViews([titleLabel,cancelButton,highestLevelLabel,containerV,tipLabel,leverageInput,slider,confirmButton])
        initLayout()
        updateTip()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: lazy
    /// 标题 English: /Title
    let titleLabel: UILabel = {
        let label = UILabel(text: "cp_contract_setting_text8".ex_localized(), font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    /// 取消 English: /Cancel
    lazy var cancelButton: UIButton = {
        let button = UIButton(buttonType: .custom, title: "cp_overview_text56".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorMedium)
        button.ext_SetAddTarget(self, #selector(clickCancelButton))
        return button
    }()
    /// 当前持仓支持的最高杠杆 English: /The highest leverage supported by the current position
    let highestLevelLabel: UILabel = {
        let label = UILabel(text: "".ex_localized(), font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
        return label
    }()
    lazy var containerV:UIView = {
        let v = UIView()
       
        return v
    }()
    lazy var maxCoinTipDescLabel:UILabel = {
        let label = UILabel(text: "cp_overview_text43".ex_localized(), font: UIFont.Ex.regular(10), textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
        return label
    }()
    lazy var maxCoinTipValueLabel:UILabel = {
        let label = UILabel(text: "--", font: UIFont.Ex.medium(16), textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    lazy var canOpenVolValueLabel:UILabel = {
        let label = UILabel(text: "--", font: UIFont.Ex.medium(16), textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    lazy var canOpenVolDescLabel:UILabel = {
        let label = UILabel(text: "cp_overview_text10".ex_localized(), font: UIFont.Ex.regular(10), textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
        return label
    }()
    /// 提示 English: /Prompt
    lazy var tipLabel: UILabel = {
        let text = "cp_contract_setting_text9".ex_localized()
        let label = UILabel(text: text, font: UIFont.ThemeFont.SecondaryMedium, textColor: UIColor.ThemeState.warning, alignment: .left)
        label.isHidden = true
        return label
    }()
    /// 杠杆输入 English: /Lever input
    lazy var leverageInput: EXSStepInputView = {
        let input = EXSStepInputView()
        input.decimal = "1"
        input.input.addTarget(self, action: #selector(leveageConTextChange), for: .editingChanged)
        input.layer.cornerRadius = 4
        input.minusBtn.addTarget(self, action: #selector(stepChangeAction(sender:)), for: .touchUpInside)
        input.plusBtn.addTarget(self, action: #selector(stepChangeAction(sender:)), for: .touchUpInside)
        return input
    }()
    /// 杠杆滑块 English: /Lever slider
    lazy var slider : EXNewLeverageSliderView = {
        
        let v = EXNewLeverageSliderView(frame: CGRect.init(x: 0, y: 0, width: EXSCREEN_WIDTH - 30, height: 50),minLevel: Int(minLevel) ?? 1 , maxLevel: Int(attainableMaxLevel) ?? 100,availableLevel:Int(userMaxLevel) ?? 0)
        v.isLever = true
        v.valueChangedCallback = {[weak self] (value) in
            if value > 50 {
                self?.tipLabel.isHidden = false
            } else {
                self?.tipLabel.isHidden = true
            }
            guard let mySelf = self else {
                return
            }
            var newV = value
            if mySelf.userMaxLevel.greaterThan("0") && value > Int(mySelf.userMaxLevel)!{
                newV = Int(mySelf.userMaxLevel)!
            }
            
            self?.sliderChangedValue = Float(newV)
            if self?.leverageInput.input.isEditing == false {
                self?.leverageInput.input.text = String(newV)  //+ "x"
                self?.changeCoinValueLabel(leverage: String(newV))
            }
        }
        v.startEdit = {[weak self]  in
            self?.leverageInput.input.resignFirstResponder()
        }
        return v
    }()
    
    /// 确认 English: /Confirm
    lazy var confirmButton: EXSButton = {
        let button = EXSButton()
        button.setTitleColor(.Ex.text4, for: .normal)
        button.addTarget(self, action: #selector(clickConfirmButton), for: .touchUpInside)
        button.setTitle("cp_calculator_text16".ex_localized(), for: .normal)
        return button
    }()
    /// 横线 English: /Horizontal line
//    lazy var horLineView: UIView = {
//        let view = UIView()
//        view.ext_UseAutoLayout()
//        view.backgroundColor = UIColor.ThemeView.seperator
//        return view
//    }()
    
    
    //MARK: action
    /// 点击取消 English: /Click to cancel
    @objc func clickCancelButton() {
        EXAlert.dismiss()
    }
    @objc func stepChangeAction(sender:UIButton) {
        if sender == leverageInput.minusBtn {
            slider.updateSliderValue(value: sliderChangedValue - 1)
        }else if sender == leverageInput.plusBtn {
            if self.userMaxLevel.greaterThan("0") {
                if let v = leverageInput.input.text,v.greaterThan(self.userMaxLevel){
                    slider.updateSliderValue(value: Float(self.userMaxLevel)!)
                    return
                }
            }
            slider.updateSliderValue(value: sliderChangedValue + 1)
        }
    }
    @objc func leveageConTextChange(sender : UITextField) {
        
        if (sender.text ?? "0").greaterThan(userMaxLevel) {
            sender.text = userMaxLevel
        }
        let value = Float(sender.text ?? "0") ?? 0
        changeCoinValueLabel(leverage: String(Int(value)))
        slider.updateSliderValueOnlyUI(value: value)

    }
    
    func changeCoinValueLabel(leverage:String) {
        let unit = makeOrderViewModel?.itemModel?.ex_contractInfo?.volumeUnit ?? multiplierCoin

        if var value = leverAndMaxCoinDic[leverage] {
            
            if let vm = makeOrderViewModel, let model = vm.itemModel {

                value = value.toVolumePrecision(withContractID: model.ex_contractInfo?.instrument_id ?? 0)
                
                if !vm.isCoin {
                    if let info = model.ex_contractInfo {
                        
                        value = EXFormula.coin(toTicket: value, price: vm.itemModel?.index_px ?? "0", contract: info).toString(0)
                    }
                }
            }
            maxCoinTipDescLabel.text = "cp_overview_text43".ex_localized() + "(\(unit))"
            maxCoinTipValueLabel.text = value
        }
        makeOrderViewModel?.leverage = leverage
        makeOrderViewModel!.loadOpenOrder(px: makeOrderViewModel?.itemModel?.last_px,
                                          emptyPx:"",
                                          moreQty: "",
                                          emptyQty: "",
                                          perform_px: "0",
                                          contractType: .limited,
                                          priceType: .limitPrice,
                                          planPriceType: .limitPlan,
                                          timeForce: 0, openOrderType: .qty)
        
        canOpenVolDescLabel.text = "cp_overview_text10".ex_localized() + "(\(unit))"
        canOpenVolValueLabel.text = self.makeOrderViewModel?.canOpenMore ?? ""
    }
    /// 点击确认 English: /Click to confirm
    @objc func clickConfirmButton() {
        var leverage = self.leverageInput.input.text ?? "10"
        if leverage.contains("x"){ //去掉x English: Remove x
            leverage = leverage.replacingOccurrences(of: "x", with: "")
        }
        if leverage.lessThan("1") {
            leverage = "1"
        }
        
        if leverage.hasPrefix("0"){
            
            leverage = (leverage as NSString).substring(from: 1)
        }
        clickConfirmButtonBlock?(leverage)
    }
    
    func updateTip(){
        let value = Float(userCurrentLeverage) ?? 0
        if value > 0 {
            if Float(value) > 50 {
                self.tipLabel.isHidden = false
            } else {
                self.tipLabel.isHidden = true
            }
        }
    }
    fileprivate func initLayout(){
        highestLevelLabel.text = "cp_extra_text114".ex_localized() + " " + userMaxLevel + "x"
        let horMargin = 16
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(horMargin)
            make.top.equalTo(20)
            make.height.equalTo(28)
        }
//        self.horLineView.snp.makeConstraints { (make) in
//            make.top.equalTo(titleLabel.snp.bottom).offset(15)
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(0.5)
//        }
        self.cancelButton.snp.makeConstraints { (make) in
            make.right.equalTo(-horMargin)
            make.top.height.equalTo(self.titleLabel)
            make.width.equalTo(50)
        }
        var w = self.cancelButton.titleResizeSize(btnImageSpace: 0).width
        let maxW = (Device_W - 16 * 2) * 0.5
        if w > maxW {
            w = maxW
        }
        self.cancelButton.snp.updateConstraints { make in
            make.width.equalTo(w)
        }
       
        highestLevelLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(horMargin)
        }
        
        self.leverageInput.snp.makeConstraints { (make) in
            make.left.equalTo(horMargin)
            make.right.equalTo(-horMargin)
            make.top.equalTo(self.highestLevelLabel.snp.bottom).offset(10)
            make.height.equalTo(44)
        }
        slider.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(leverageInput.snp.bottom).offset(32)
            make.height.equalTo(16)
        }
        
        //slider real height 16 + 8 + 12
        tipLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(slider.snp.bottom).offset( 8 + 12 + 12)
        }
        containerV.snp.makeConstraints { (make) in
            make.top.equalTo(tipLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
        }
        
        maxCoinTipDescLabel.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
        }
        maxCoinTipValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(maxCoinTipDescLabel.snp.bottom).offset(2)
            make.centerX.equalTo(maxCoinTipDescLabel)
        }
        canOpenVolDescLabel.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.left.equalTo(maxCoinTipDescLabel.snp.right).offset(96)
        }
        canOpenVolValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(canOpenVolDescLabel.snp.bottom).offset(2)
            make.centerX.equalTo(canOpenVolDescLabel)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(44)
            make.top.equalTo(containerV.snp.bottom).offset(28)
            make.bottom.equalTo(-50)
            
        }
    }
    
}

