//
//  EXContractMakeOrderView.swift
//  Chainup
//
//  Created by ZYJ on 2023/11/8.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
//import Lottie

let exs_proportion_width : CGFloat = (192 + 32) / 375 * EXSCREEN_WIDTH//左边的宽度 English: Left width
enum EXOpenOrderType {
    case qty //数量-张/币 English: Quantity - sheets/coin
    case value //委托价值下单 English: Order placement based on entrusted value
}

///开单view （开多/空） English: /Invoice view (open multiple/empty)
class EXContractMakeOrderView: UIView {
    //MARK: 属性 English: MARK: Properties
    static let buttonHeight:CGFloat = 30
    var contractVm = EXContractHomeViewModel()
    static let canOpenMoreTopHeight:CGFloat = 24
    var currentUserConfig = SLUserConfig()
    var positionType:SLPositionMode = .both
    var openContractAlert: EXComVoidBlock?
    var openOrderType:EXOpenOrderType = .qty
    // 点击深度价格 English: Click on deep pricing
    var moneyShortCallBack: EXComVoidBlock?
    typealias ClickBuyOrSellBlock = (EXContractOrderModel) -> ()
    typealias ClickButtonBlock = (EXSwapTransationViewShowType) -> ()
    typealias UpdateDepthMaxBlock = () -> ()
    var updateDepthMaxCountBlock: UpdateDepthMaxBlock?
    //    var heightChangeBlock: EXComIntBlock?
    var clickTradeBlock : ClickBuyOrSellBlock?
    var updateTransactionShowTypeBlock:ClickButtonBlock?
    typealias ChangeLayoutBlock = (CGFloat) -> ()
    //    var changeLayoutBlock : ChangeLayoutBlock?
    var _transactionShowType : EXSwapTransationViewShowType?
    /// 开仓平仓 English: /Opening and closing positions
    var transactionShowType : EXSwapTransationViewShowType? {
        
        set {
            _transactionShowType = newValue
            reloadTransationTypeView()
            reloadMakeOrderData()
        }
        get {
            if !onlySellBtn.isHidden, onlySellBtn.isSelected {
                return .showClose
            }
            return _transactionShowType
        }
    }
    
    lazy var inputVaild = EXSInputLimitDelegate()
    lazy var volumeVaild = EXSInputLimitDelegate()
    
    var makeOrderViewModel : EXSwapMarkOrderViewModel? {
        didSet {
            if makeOrderViewModel?.itemModel != nil {
                reloadUnitData()
                makeOrderViewModel?.getCoinOpenOrderMaxMinLimit()
                volumeTextField.openOrderType = self.openOrderType
                volumeTextField.openTypeUnit = makeOrderViewModel!.getOpenOrderQutryUnit()
               // updateVolumeTextFieldTypeBtn()
                self.stopLossPriceField.input.text = ""
                self.stopProfitPriceField.input.text = ""
                self.priceTextField.input.text = makeOrderViewModel!.itemModel?.last_px ?? ""
                self.priceTextField.decimal = makeOrderViewModel!.itemModel?.ex_contractInfo?.px_unit ?? "0.01"
                self.inputVaild.decail = makeOrderViewModel!.itemModel?.ex_contractInfo?.px_unit ?? "0.01"
                textFieldValueHasChanged(textField:self.priceTextField.input)
                makeOrderViewModel!.makerOrderUnitChangeBlock = {[weak self] in
                    self?.reloadUnitData()
                }
                
            }
        }
    }
    /// 委托类型 (限价委托，市价委托，计划委托) English: /Type of commission (limit price commission, market price commission, planned commission)
    var defineOrderType : EXSwapMarketOrderType = .limited {
        didSet {
            self.trackingEventByOnToggle(orderType: defineOrderType)
        }
    }
    /// 普通合约价格类型 English: /Type of ordinary contract price
    var normalPriceType : EXSwapMarketOrderPriceType = .limitPrice
    /// 执行价格类型 English: /Execution price type
    var performPriceType : EXSwapPlanOrderPriceType = .limitPlan
    
    var priceArr = EXSwapMarketOrderType.getOrderTypes()
    
    //    [EXSwapMarketOrderType.limited,
    //                    EXSwapMarketOrderType.market,
    //                    EXSwapMarketOrderType.planOrder(),
    //                    EXSwapMarketOrderType.postOnly,
    //                    EXSwapMarketOrderType.immediateOrCance,
    //                    EXSwapMarketOrderType.fillOrKill]
    //coins_exchange_buy_grey。coins_exchange_buy_select coins_exchange_sell_grey coins_exchange_sell_select
    
    
    var executeOpenLongPrice:String {
        return priceTextField.input.text ?? ""
    }
    
    var executeOpenEmptyPrice:String {
        return priceTextField.input.text ?? ""
    }
    
    var _currentPercent = ""
    var openMoreQty : String {
        if _currentPercent.count > 0,
           let vm = makeOrderViewModel {
            var canOpen = vm.canOpenMore
            if shouldVolumeFieldUseQuoteCoinCalculate() {
                canOpen = vm.canOpenMoreValue
            }
            if self.openOrderType == .value{ //价值开单 English: Value invoicing
                canOpen = vm.canOpenMoreValue
            }
            
            if canOpen.greaterThanOrEqual(BTZERO) {
                return canOpen.bigMul(_currentPercent)
            }
        }
        return self.volumeTextField.stepInput.input.text ?? ""
    }
    var openEmptyQty : String {
        if _currentPercent.count > 0,
           let vm = makeOrderViewModel {
            var canOpen = vm.canOpenShort
            if shouldVolumeFieldUseQuoteCoinCalculate() {
                canOpen = vm.canOpenShortValue
            }
            if self.openOrderType == .value{ //价值开单 English: Value invoicing
                canOpen = vm.canOpenShortValue
            }
            if canOpen.greaterThanOrEqual(BTZERO) {
                
                return canOpen.bigMul(_currentPercent)
            }
        }
        return self.volumeTextField.stepInput.input.text ?? ""
    }
    //MARK: lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.card1
        //止盈止损的按钮 English: Stop profit and stop loss button
        stopPLButtonContentView.addSubview(stopPLButton)
        //止盈止损的输入框view English: View the input box for stop profit and stop loss
        stopPLFieldContentView.exs_addSubViews([stopLossPriceField,stopProfitPriceField])
        //止盈止损的容器 English: Container for stopping profits and losses
        stopPLModuleContainerView.addArrangedSubview(stopPLButtonContentView)
        stopPLModuleContainerView.addArrangedSubview(stopPLFieldTopMagin)
        stopPLModuleContainerView.addArrangedSubview(stopPLFieldContentView)
        
        self.exs_addSubViews([
            orderBuyBtn,orderSellBtn,
            avilabelView,
            orderTypeBtn,
            triggerTextField,performTextField,volumeTextField,entrustLabel,marketPriceLabel,canOpenMoreLabel,buyBtn,sellBtn,canCloseMoreLabel,canCloseShortLabel,marketPerformBtn,marketLabel,canMoreCostLabel,onlySellBtn,stopPLModuleContainerView,priceTextField,canShortCostLabel,canOpenShortLabel])
        self.exs_addSubViews([shouldLoginOrRegisterView,logoutMaskView])
        //        self.exs_addSubViews([buyTipLabel,sellTipLabel])
        setUpUI()
        updateUI()
        //MARK: 输入限制 English: MARK: Input Restrictions
        self.priceTextField.input.delegate = self.inputVaild
        self.triggerTextField.input.delegate = self.inputVaild
        self.performTextField.input.delegate = self.inputVaild
        self.stopLossPriceField.input.delegate = inputVaild
        stopProfitPriceField.input.delegate = inputVaild
        self.volumeTextField.stepInput.decimal = self.volumeVaild.decail
        self.volumeTextField.stepInput.input.delegate = self.volumeVaild
        transactionShowType = .showOpen
        self.trackingEventByOnToggle(orderType: self.defineOrderType)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateVolumeTextFieldTypeSource(){
        if makeOrderViewModel != nil{
            volumeTextField.openTypeUnit = makeOrderViewModel!.getOpenOrderQutryUnit()
        }
    }
    ///最新价格 English: /Latest prices
    func updateLastPrice(price: String){
        var tf = priceTextField.input
        if defineOrderType == .limited{
        }else if defineOrderType == .planOrder(isMarket: false){
            tf = self.performTextField.input
        }
        
        if (tf.text?.isEmpty ?? true) && tf.isEditing == false{
            tf.text = price
            self.reloadMakeOrderData() //update can open
        }
        
    }
    ///最新价格 清空 English: /Latest price clearance
    func clearLastPrice(){
        self.priceTextField.input.text = nil
        self.performTextField.input.text = nil
        self.triggerTextField.input.text = nil
        
    }
    
    
    //MARK: lazy UI 开仓 English: MARK: Lazy UI opening
    lazy var maskBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemeView.mask
        return view
    }()
    //MARK: "开仓 English: MARK: "Opening a position"
    lazy var orderBuyBtn: RepeatButton = {
        let btnBuy = RepeatButton.init(type: .custom)
        btnBuy.titleLabel?.font = .Ex.medium(14)
        btnBuy.setTitle("cp_overview_text1".ex_localized(), for: .normal)
        btnBuy.setTitleColor(.Ex.text2, for: .normal)
        btnBuy.setTitleColor(.Ex.text4, for: .selected)
        let normalImg = UIImage.exs_themeImageNamed(imageName: "contract_openpositions")
        btnBuy.setBackgroundImage(normalImg, for: .normal)
        //        btnBuy.seletedBackGroundSvgImageName = "contract_openpositions_hover"
        var newSize = normalImg.size
        newSize.width += 100
        let ig = UIImage.svg_themeImageNamed(imageName: "contract_openpositions_hover")
        let newImg = ig?.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 10, bottom: 5, right: 30),resizingMode: .stretch)
        btnBuy.setBackgroundImage(ig, for: .selected)
        //        btnBuy.setBackgroundImage(UIImage.exs_themeImageNamed(imageName: "contract_openpositions_hover"), for: .selected)
        btnBuy.addTarget(self, action: #selector(onOrderActionChanged(_:)), for: .touchUpInside)
        btnBuy.isSelected = true
        return btnBuy
    }()
    //MARK: lazy UI 平仓 English: MARK: Lazy UI Closing Position
    lazy var orderSellBtn:RepeatButton = {
        let btnSell = RepeatButton.init(type: .custom)
        btnSell.titleLabel?.font = .Ex.medium(14)
        btnSell.setTitle("cp_overview_text2".ex_localized(), for: .normal)
        btnSell.setTitleColor(.Ex.text2, for: .normal)
        btnSell.setTitleColor(.Ex.text4, for: .selected)
        btnSell.isSelected = false
        btnSell.setBackgroundImage(UIImage.exs_themeImageNamed(imageName: "contract_unwind"), for: .normal)
        //        btnSell.setImage(UIImage.exs_themeImageNamed(imageName: "contract_unwind"), for: .normal)
        btnSell.setBackgroundImage(UIImage.svg_themeImageNamed(imageName: "contract_unwind_hover"), for: .selected)
        //        btnSell.setBackgroundImage(UIImage.exs_themeImageNamed(imageName: "contract_unwind_hover"), for: .selected)
        btnSell.addTarget(self, action: #selector(onOrderActionChanged(_:)), for: .touchUpInside)
        return btnSell
    }()
    //可用 English: available
    lazy var avilabelView: EXAvailableView = {
        let v = EXAvailableView()
        return v
    }()
    /// 委托类型按钮 English: /Delegate Type Button
    lazy var orderTypeBtn : EXSDirectionButton = {
        let btn = EXSDirectionButton()
        btn.ext_UseAutoLayout()
        btn.backgroundColor = UIColor.getConfigBg()//UIColor.ThemeView.card2
        btn.container.backgroundColor =  UIColor.getConfigBg()//UIColor.ThemeView.card2
        btn.container.layer.cornerRadius = 4
        btn.container.layer.masksToBounds = true
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.getConfigBg().cgColor//UIColor.ThemeView.card2.cgColor
        btn.layer.cornerRadius = 4
        btn.addTarget(self, action: #selector(clickOrderTypeBtn(sender:)), for: UIControl.Event.touchUpInside)
        btn.titleLabel.font = UIFont.ThemeFont.BodyRegular
        btn.text(content: priceArr[0].display)
        btn.showIndcator = true
        btn.btnClickBlock = { [weak self] in
            let alert = EXOrderTypeShowAlert()
            alert.type = self?.defineOrderType
            EXAlert.showSheet(sheetView: alert, animated: true, bgTapCancel: true, allowForwardTouch: false)
        }
        return btn
    }()
    
    //只减仓位于 单向持仓 English: Only reducing positions in one-way positions
    lazy var onlySellBtn : EXSButton = {
        let btn = EXSButton()
        btn.setTitle("cp_order_text54".ex_localized(), for: .normal)
        btn.clearColors()
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        //        btn.setFont(UIFont.ThemeFont.SecondaryMedium)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_uncheck"), for: .normal)
        btn.setImage(UIImage.svg_themeImageNamed(imageName: "public_icon_check_mark"), for: .selected)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 3)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        
        btn.rx.controlEvent(.touchUpInside)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe { [weak self] (_) in
                guard let nSelf = self else { return  }
                nSelf.clickedOnlySellBtn(sender: nSelf.onlySellBtn)
        }.disposed(by: self.exs_disposeBag)
//        btn.addTarget(self, action: #selector(clickedOnlySellBtn(sender:)), for: .touchUpInside)
        return btn
    }()
    
    
    ///市价使用 English: /Market price usage
    /// 市价交易 English: /Market price trading
    lazy var marketLabel : UILabel = {
        let label = UILabel(text: "  " + "cp_overview_text36".ex_localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .center)
        label.backgroundColor = UIColor.ThemeBtn.disable //UIColor.ThemeView.card2
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    ///对手价里的价格 输入框 English: /Price Input Box in Opponent Price
    lazy var priceTextField : EXSStepInputView = {
        let textField = EXSStepInputView()
        textField.input.exs_setPlaceHolderAtt("cp_overview_text30".ex_localized(), color: UIColor.ThemeLabel.colorDark)
        textField.textfieldDidBeginBlock = {[weak self] in
            guard let self = self else { return }
            self.trackingEventByOnInput(orderType: self.defineOrderType)
        }
        textField.textValueChangeBLock = {[weak self] str in
            guard let mySelf = self else{return}
//            //print("价钱-\(str)") English: Print ("price - \ (str)")
            mySelf.textFieldValueHasChanged(textField: textField.input)
        }
        //加号 减号 处理 English: Plus minus processing
        textField.stepBtnsBlock = {  [weak self] (val,pesent) in
            guard let mySelf = self else{return}
            mySelf.textFieldValueHasChanged(textField: mySelf.priceTextField.input)
        }
        return textField
    }()
    ///条件单使用====== English: /Condition sheet usage======
    ///1.触发价格 English: /1. Trigger price
    lazy var triggerTextField : EXSBorderField = {
        let textField = EXSBorderField()
        textField.ext_UseAutoLayout()
        textField.input.textColor = UIColor.ThemeLabel.colorLite
        textField.unitLabel.text = ""
        textField.maxLenth = 9
        textField.layer.cornerRadius = 4
        textField.bgView.layer.cornerRadius = 4
        textField.bgView.layer.masksToBounds = true
        textField.bgView.backgroundColor =  UIColor.getConfigBg()//UIColor.ThemeView.card2
        textField.input.textAlignment = .center
        textField.setPlaceHolder(placeHolder:  "cp_order_text70".ex_localized())
        textField.textfieldValueChangeBlock = {[weak self]str in
            guard let mySelf = self else{return}
            mySelf.textFieldValueHasChanged(textField: textField.input)
        }
        textField.input.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    ///2.1"委托价格" English: /2.1 "Commission Price"
    lazy var performTextField : EXSBorderField = {
        let textField = EXSBorderField()
        textField.ext_UseAutoLayout()
        textField.input.textColor = UIColor.ThemeLabel.colorLite
        textField.setPlaceHolder(placeHolder: "cp_overview_text30".ex_localized())
        textField.unitLabel.isHidden = true
        textField.input.textAlignment = .center
        textField.textfieldValueChangeBlock = {[weak self]str in
            guard let mySelf = self else{return}
            mySelf.textFieldValueHasChanged(textField: textField.input)
        }
        textField.bgView.layer.cornerRadius = 4
        textField.bgView.layer.masksToBounds = true
        textField.bgView.backgroundColor = UIColor.getConfigBg()//UIColor.ThemeView.card2
        textField.layer.cornerRadius = 4
        textField.maxLenth = 9
        textField.input.keyboardType = UIKeyboardType.decimalPad
        textField.input.snp.updateConstraints { (make) in
            make.right.equalToSuperview().offset(-5)
        }
        return textField
    }()
    ///2.2 市价 市价按钮 English: /2.2 Market Price Market Price Button
    lazy var marketPerformBtn : UIButton = {
        let btn = UIButton(buttonType: .custom, title: "cp_overview_text53".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorLite)
        btn.ext_UseAutoLayout()
        btn.ext_SetAddTarget(self, #selector(clickPlanMarketBtn))
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 0.5
        btn.backgroundColor = UIColor.getConfigBg()//UIColor.ThemeView.card2
        btn.layer.borderColor = UIColor.getConfigBg().cgColor//UIColor.ThemeView.card2.cgColor
        btn.layer.cornerRadius = 4
        return btn
    }()
    ///条件单使用====== English: /Condition sheet usage======
    
    //MARK: 市价提示框 选择市价覆盖 价格输入框 English: MARK: Market price prompt box, select market price overlay price input box
    lazy var marketPriceLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.backgroundColor =  UIColor.ThemeBtn.disable //UIColor.ThemeView.card2
        label.text = "cp_overview_text36".ex_localized()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.BodyRegular
        label.layer.cornerRadius = 4
        label.layer.borderWidth = 0.5
        label.layer.masksToBounds = true
        label.layer.borderColor = UIColor.ThemeBtn.disable.cgColor //UIColor.ThemeView.card2.cgColor
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()
    //MARK: fix 合约价值 English: MARK: Fix Contract Value
    lazy var entrustLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "≈ ￥--"
        return label
    }()
    //MARK: 滑杆输入框 English: MARK: Sliding bar input box
    lazy var volumeTextField : EXSliderInputView = {
        let sliderInput = EXSliderInputView()
        sliderInput.backgroundColor = UIColor.ThemeView.card1
        sliderInput.stepInput.input.textColor = UIColor.ThemeLabel.colorLite
        sliderInput.stepInput.input.keyboardType = UIKeyboardType.decimalPad
        sliderInput.maxValue = "0"//最大值 English: Maximum value
        let placeH = "cp_overview_text8".ex_localized() + "(" + "cp_overview_text9".ex_localized() + ")"
        sliderInput.setPlaceHolder(placeHolder: placeH)
        sliderInput.stepInput.textfieldDidBeginBlock = { [weak self] in
            guard let self = self else { return }
            self.trackingEventByOnVolume(orderType: self.defineOrderType)
            
        }
        sliderInput.stepInput.input.rx.text.orEmpty.changed.asObservable().subscribe { (event) in
            if let str = event.element{
                sliderInput.stepInput.input.text = String(str)
                self.textFieldValueHasChanged(textField: sliderInput.stepInput.input)
            }
        }.disposed(by: self.exs_disposeBag)
        //输入-滑杆重置 English: Input - Sliding Rod Reset
        sliderInput.stepInput.input.rx.controlEvent([.editingDidBegin]).asObservable().subscribe(onNext: { [weak self] in
            guard let mySelf = self else{return}
            if mySelf._currentPercent.count > 0 {
                mySelf._currentPercent = ""
                mySelf.volumeTextField.reset(callback: false)
            }
        }).disposed(by: self.exs_disposeBag)
        //滑杆监听 English: Sliding rod monitoring
        sliderInput.slider.valueOnTapCallback = {[weak self] _ in
            guard let self = self else { return }
            self.trackingEventByOnVolume(orderType: self.defineOrderType, isOnTap: true)
        }
        sliderInput.slider.valueChangedCallback = { [weak self] v in
            guard let mySelf = self else{return}
            
            //            mySelf.volumeTextField.stepInput.percent = true
            let value = "\(v)"
            mySelf._currentPercent = value.bigDiv("100")
            mySelf.volumeTextField.stepInput.input.text = value.appending("%")
            mySelf.textFieldValueHasChanged(textField: mySelf.volumeTextField.stepInput.input)
        }
        sliderInput.selectedOpenType = { [weak self] otype in
            guard let newSelf = self else{
                return
            }
            //更新布局 English: Update Layout
            newSelf.volumeTextField.openTypeUnit = newSelf.makeOrderViewModel!.getOpenOrderQutryUnit()
            newSelf.openOrderType = otype
            //清空数据 English: wipe data
            newSelf._currentPercent = ""
            newSelf.volumeTextField.reset()
            newSelf.updateVolumeDecail()
            newSelf.reloadMakeOrderData()
            //print("更新类型 = \(newSelf.openOrderType)")
        }
        
        //MARK: 添加蒙版 English: MARK: Add a mask
        sliderInput.popViewShowBlock = {[weak self] in
            guard let mySelf = self else{return}
            mySelf.addmask()
        }
        //MARK: 移除蒙版 English: MARK: Remove Mask
        sliderInput.popViewDismissBlock = {[weak self] in
            guard let mySelf = self else{return}
            mySelf.removeMask()
        }
        //        return view
        sliderInput.stepInput.input.keyboardType = UIKeyboardType.numberPad
        return sliderInput
    }()
    
    
    /// 可开多 English: /Kaiduo
    lazy var canOpenMoreLabel: SLSwapHorDetailView = {
        let v = SLSwapHorDetailView()
        v.leftLabel.textColor = UIColor.ThemeLabel.colorMedium
        v.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        v.rightLabel.textColor = UIColor.ThemeLabel.colorLite
        v.rightLabel.font = UIFont.ThemeFont.SecondaryMedium
        return v
    }()
    /// 可开空 English: /Can be opened empty
    lazy var canOpenShortLabel: SLSwapHorDetailView = {
        let v = SLSwapHorDetailView()
        v.leftLabel.textColor = UIColor.ThemeLabel.colorMedium
        v.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        v.rightLabel.textColor = UIColor.ThemeLabel.colorLite
        v.rightLabel.font = UIFont.ThemeFont.SecondaryMedium
        return v
    }()
    
    //止盈止损部分 English: Stop profit and stop loss portion
    //止盈止损view English: Stop profit and stop loss view
    lazy var stopPLButtonContentView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    //止盈止损按钮 English: Stop profit and stop loss button
    lazy var stopPLButton:EXSButton = {
        let btn = EXSButton()
        btn.setTitle("cp_overview_text12".ex_localized(), for: .normal)
        btn.clearColors()
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        //        btn.setFont(UIFont.ThemeFont.BodyRegular)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_uncheck"), for: .normal)
        btn.setImage(UIImage.svg_themeImageNamed(imageName: "public_icon_check_mark"), for: .selected)
        //        btn.ext_SetImages([UIImage.exs_themeImageNamed(imageName: "public_icon_uncheck")], controlStates: [.normal])
        //        btn.seletedSvgImageName = "public_icon_check_mark"
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 3)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        btn.addTarget(self, action: #selector(clickedStopPLBtn(sender:)), for: .touchUpInside)
        return btn
    }()
    //止盈价输入 English: Stop profit price input
    lazy var stopProfitPriceField:EXSBorderField = {
        let textField = EXSBorderField()
        textField.onlyInput = true
        textField.backgroundColor = UIColor.ThemeView.card1
        textField.ext_UseAutoLayout()
        textField.input.textAlignment = .center
        textField.input.textColor = UIColor.ThemeLabel.colorLite
        textField.setPlaceHolder(placeHolder: "cp_extra_text65".ex_localized())
        textField.unitLabel.text = ""
        textField.bgView.backgroundColor =  UIColor.getConfigBg()//UIColor.ThemeView.card2
        textField.textfieldValueChangeBlock = {[weak self]str in
            guard let mySelf = self else{return}
            mySelf.textFieldValueHasChanged(textField: textField.input)
        }
        textField.bgView.layer.cornerRadius = 4
        textField.maxLenth = 9
        textField.input.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    
    //止盈止损的容器 English: Container for stopping profits and losses
    lazy var stopPLModuleContainerView : UIStackView = {
        let view = UIStackView()
        view.ext_UseAutoLayout()
        view.axis = .vertical
        view.layoutIfNeeded()
        view.backgroundColor = UIColor.clear
        return view
    }()
    lazy var stopPLFieldTopMagin:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.isHidden = true
        return view
    }()
    //止盈止损输入框 English: Stop profit and stop loss input box
    lazy var stopPLFieldContentView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    //止损价输入框 English: Stop loss price input box
    lazy var stopLossPriceField:EXSBorderField = {
        let textField = EXSBorderField()
        textField.onlyInput = true
        textField.backgroundColor = UIColor.ThemeView.card1
        textField.ext_UseAutoLayout()
        textField.input.textAlignment = .center
        textField.input.textColor = UIColor.ThemeLabel.colorLite
        textField.setPlaceHolder(placeHolder: "cp_extra_text64".ex_localized())
        textField.unitLabel.text = ""
        textField.bgView.backgroundColor =  UIColor.getConfigBg()//UIColor.ThemeView.card2
        textField.textfieldValueChangeBlock = {[weak self]str in
            guard let mySelf = self else{return}
            mySelf.textFieldValueHasChanged(textField: textField.input)
        }
        textField.bgView.layer.cornerRadius = 4
        textField.maxLenth = 9
        textField.input.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    
    
    
    
    
    
    
    /// 开多按钮 English: /Turn on multiple buttons
    lazy var buyBtn : EXSButton = {
        let btn = EXSButton()
        btn.ext_UseAutoLayout()
        btn.ext_SetAddTarget(self, #selector(clickBuyOrSellBtn))
        btn.setTitle("cp_overview_text22".ex_localized(), for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.color = UIColor.ThemekLine.up
        btn.highlightedColor = UIColor.extColorWithHex("#26C0A4")
        return btn
    }()
    //    lazy var sellTipLabel:UILabel = {
    //        let ret = UILabel()
    //        ret.text = "".ex_localized()
    //        ret.font = UIFont.ThemeFont.SecondaryRegular
    //        ret.textColor = UIColor.white.withAlphaComponent(0.6)
    //        return ret
    //    }()
    //    lazy var buyTipLabel:UILabel = {
    //        let ret = UILabel()
    //        ret.text = "".ex_localized()
    //        ret.font = UIFont.ThemeFont.SecondaryRegular
    //        ret.textColor = UIColor.white.withAlphaComponent(0.6)
    //        return ret
    //    }()
    /// 开空按钮 English: /On/Off button
    lazy var sellBtn : EXSButton = {
        let btn = EXSButton()
        btn.ext_UseAutoLayout()
        btn.ext_SetAddTarget(self, #selector(clickBuyOrSellBtn))
        btn.setTitle("cp_overview_text22".ex_localized(), for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyRegular
        btn.color = UIColor.ThemekLine.down
        btn.highlightedColor = UIColor.extColorWithHex("#D75E75")
        return btn
    }()
    
    
    /// 可平多 English: /Kepingduo
    lazy var canCloseMoreLabel : SLSwapHorDetailView = {
        let v = SLSwapHorDetailView()
        v.leftLabel.textColor = UIColor.ThemeLabel.colorMedium
        v.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        v.rightLabel.textColor = UIColor.ThemeLabel.colorLite
        v.rightLabel.font = UIFont.ThemeFont.SecondaryMedium
        v.isHidden = true
        return v
    }()
    /// 可平空 English: /Can level the air
    lazy var canCloseShortLabel : SLSwapHorDetailView = {
        let v = SLSwapHorDetailView()
        v.leftLabel.textColor = UIColor.ThemeLabel.colorMedium
        v.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        v.rightLabel.textColor = UIColor.ThemeLabel.colorLite
        v.rightLabel.font = UIFont.ThemeFont.SecondaryMedium
        v.isHidden = true
        return v
    }()
    
    //预估成本 English: Estimated cost
    lazy var canMoreCostLabel: SLSwapHorDetailView = {
        let v = SLSwapHorDetailView()
        v.leftLabel.textColor = UIColor.ThemeLabel.colorMedium
        v.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        v.rightLabel.textColor = UIColor.ThemeLabel.colorLite
        v.rightLabel.font = UIFont.ThemeFont.SecondaryMedium
        v.leftLabel.text = "cp_overview_text11".ex_localized()
        return v
    }()
    lazy var canShortCostLabel: SLSwapHorDetailView = {
        let v = SLSwapHorDetailView()
        v.leftLabel.textColor = UIColor.ThemeLabel.colorMedium
        v.leftLabel.font = UIFont.ThemeFont.SecondaryRegular
        v.rightLabel.textColor = UIColor.ThemeLabel.colorLite
        v.rightLabel.font = UIFont.ThemeFont.SecondaryMedium
        v.leftLabel.text = "cp_overview_text11".ex_localized()
        return v
    }()
    
    //顶部遮盖view 用于未登录 English: Top cover view for unlisted users
    lazy var logoutMaskView:UIControl = {
        let ret = UIControl()
        ret.backgroundColor = UIColor.clear
        ret.addTarget(self, action: #selector(clickBuyOrSellBtn), for: .touchUpInside)
        return ret
    }()
    //登录 English: Login
    lazy var shouldLoginOrRegisterView:EXSLoginView = {
        let v = EXSLoginView()
        v.confirmButton.ext_SetAddTarget(self, #selector(clickBuyOrSellBtn))
        return v
    }()
}

// MARK: - setupUI
extension EXContractMakeOrderView {
    
    func getUserConfigUpdateDateVolumTextUnit(){
        if self.openOrderType == .qty{
            updateVolumTextUnit()
        }
    }
    // 切换币和张 更新数量框的单位 English: Switch the units of currency and sheet update quantity boxes
    func updateVolumTextUnit(){
        self.openOrderType = .qty
        self.volumeTextField.openOrderType = .qty
        self.volumeTextField.openTypeUnit = self.makeOrderViewModel!.getOpenOrderQutryUnit()
    }
    fileprivate func limitVolumeLayout() {
        volumeTextField.snp.remakeConstraints { (make) in
            make.left.right.equalTo(priceTextField)
            make.height.equalTo(EXSliderInputView.viewHeight)
            make.top.equalTo(priceTextField.snp.bottom).offset(8)
        }
    }
    
    fileprivate func planVolumeLayout() {
        
        volumeTextField.snp.remakeConstraints { (make) in
            make.left.right.equalTo(priceTextField)
            make.height.equalTo(EXSliderInputView.viewHeight)
            make.top.equalTo(performTextField.snp.bottom).offset(8)
        }
    }
    //MARK: 单向和双向持仓布局1 English: MARK: Unidirectional and Bidirectional Position Layout 1
    func layoutOrderTypeBtn() {
        
        if onlySellBtn.isHidden {//双向 English: two-way
            avilabelView.snp.remakeConstraints { make in
                make.height.equalTo(EXAvailableView.viewHeight)
                make.top.equalTo(orderBuyBtn.snp.bottom)//.offset(-5)
                make.left.equalTo(16)
                make.right.equalToSuperview().offset(-16)
            }
        }else{
            avilabelView.snp.remakeConstraints { make in
                make.height.equalTo(EXAvailableView.viewHeight)
                make.top.equalToSuperview() //.offset(-8)
                make.left.equalTo(16)
                make.right.equalToSuperview().offset(-16)
            }
        }
        orderTypeBtn.snp.remakeConstraints { (make) in
            make.height.equalTo(26)
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(avilabelView.snp.bottom)
            make.right.equalToSuperview().offset(-15)
        }
    }
    //MARK: 单向和双向持仓布局2 English: MARK: Unidirectional and Bidirectional Position Layout 2
    func updateOnlySellBtnLayout(){
        //双向 English: two-way
        var stopPLtop: CGFloat = 10
        var buyBtnTop: CGFloat = 40 //
        if onlySellBtn.isHidden == false {
            stopPLtop = (8 + 18 + 8) //只减仓按钮的高度 English: The height of the position reduction button only
            buyBtnTop = 40
        }
        stopPLModuleContainerView.snp.updateConstraints { make in
            make.top.equalTo(volumeTextField.snp.bottom).offset(stopPLtop)
        }
        buyBtn.snp.updateConstraints { make in
            make.bottom.equalTo(sellBtn.snp.top).offset(-buyBtnTop)
        }
    }
    //止盈止损的view English: View of stop profit and stop loss
    func configStopView(){
        
    }
    // MARK: - 布局 English: MARK: - Layout
    func setUpUI() {
        ///条件单 English: /Condition sheet
        triggerTextField.isHidden = true
        performTextField.isHidden = true
        marketPerformBtn.isHidden = true
        //只减仓 English: Only reduce positions
        onlySellBtn.isHidden = true
        shouldLoginOrRegisterView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(canOpenMoreLabel)
            make.bottom.equalToSuperview()
        }
        logoutMaskView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(0)
            make.bottom.equalTo(shouldLoginOrRegisterView.snp.top)
        }
        orderBuyBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(15)
            make.height.equalTo(EXContractMakeOrderView.buttonHeight)
            make.right.equalTo(orderSellBtn.snp.left)
            make.width.equalTo(orderSellBtn.snp_width)
        }
        
        orderSellBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(orderBuyBtn)
            make.left.equalTo(orderBuyBtn.snp.right)
            make.width.equalTo(orderSellBtn.snp_width)
        }
        
//        avilabelView.snp.makeConstraints { make in
//            make.height.equalTo(EXAvailableView.viewHeight)
//            make.top.equalTo(orderBuyBtn.snp.bottom)
//            make.left.equalTo(16)
//            make.right.equalToSuperview().offset(-16)
//
//        }
        
        layoutOrderTypeBtn()
        
        //marketPriceLabel 和对手价 view frame 一样 English: MarketPriceLabel and competitor price view frame are the same
        marketPriceLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(priceTextField)
        }
        priceTextField.snp.makeConstraints { (make) in
            make.top.equalTo(orderTypeBtn.snp.bottom).offset(8)
            make.height.equalTo(40)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
        limitVolumeLayout()
        //只减仓 默认隐藏 English: Only reduce positions and hide by default
        onlySellBtn.snp.makeConstraints { (make) in
            make.top.equalTo(volumeTextField.snp.bottom).offset(8)
           // make.width.equalTo(60)
            make.height.equalTo(18)
            make.left.equalTo(priceTextField).offset(2)
        }
        //止盈止损部分 English: Stop profit and stop loss portion
        stopPLModuleContainerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(priceTextField)
//            make.left.equalTo(priceTextField).offset(2)
            make.top.equalTo(volumeTextField.snp.bottom).offset(10)
        }
        stopPLButtonContentView.snp.makeConstraints { (make) in
            make.height.equalTo(18)
        }
        stopPLButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(2)
        }
        stopPLFieldTopMagin.snp.makeConstraints { make in
            make.height.equalTo(8)
        }
        stopLossPriceField.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.height.equalTo(35)
            make.width.equalTo(stopProfitPriceField)
        }
        stopProfitPriceField.snp.makeConstraints { (make) in
            make.top.equalTo(stopLossPriceField)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-13)
            make.height.equalTo(36)
            make.width.equalToSuperview().multipliedBy(0.49)
        }
        
        entrustLabel.snp.makeConstraints { (make) in
            make.right.equalTo(priceTextField)
            make.height.equalTo(12)
            //            make.top.equalTo(volumeTextField.snp.bottom).offset(10)
            make.centerY.equalTo(stopPLButton)
        }
        
        ///从下往上布局 English: /Layout from bottom to top
        ///卖出开空 English: /Selling short positions
        
        sellBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(priceTextField)
            make.height.equalTo(40)
            //            make.top.equalTo(canShortCostLabel.snp.bottom)
            make.bottom.equalToSuperview()//.offset(-32)
        }
        //成本 English: cost
        canShortCostLabel.snp.makeConstraints { (make) in
//            make.left.right.equalTo(canOpenShortLabel)
            make.left.right.equalToSuperview()
            make.height.equalTo(12)
            make.bottom.equalTo(sellBtn.snp.top).offset(-8)
        }
        //可开空 English: Can be opened empty
        canOpenShortLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(12)
            make.bottom.equalTo(canShortCostLabel.snp.top).offset(-8)
        }
        //可平空-- 默认隐藏 English: Flatten - default hidden
        canCloseShortLabel.snp.makeConstraints { make in
            make.edges.equalTo(canShortCostLabel)
        }
        
        
        // 买入开多 English: Buy Kaiduo
        buyBtn.snp.makeConstraints { (make) in
            make.left.right.equalTo(priceTextField)
            make.height.equalTo(40)
            make.bottom.equalTo(sellBtn.snp.top).offset(-40)
        }
        //开多成本 English: Open multiple costs
        canMoreCostLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(12)
            make.bottom.equalTo(buyBtn.snp.top).offset(-8)
        }
        //可开多 English: Kaiduo
        canOpenMoreLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(12)
            make.bottom.equalTo(canMoreCostLabel.snp.top).offset(-8)
        }
        //可平多-默认隐藏 - 平仓显示 English: Kepingduo - Default Hidden - Closing Display
        canCloseMoreLabel.snp.makeConstraints { make in
            make.edges.equalTo(canMoreCostLabel)
        }
        
        
        ///条件单相关 English: /Condition sheet related
        triggerTextField.snp.makeConstraints { (make) in
            make.left.right.equalTo(priceTextField)
            make.height.equalTo(36)
            make.top.equalTo(orderTypeBtn.snp.bottom).offset(10)
        }
        
        performTextField.snp.makeConstraints { (make) in
            make.left.equalTo(priceTextField)
            make.height.equalTo(36)
            make.top.equalTo(triggerTextField.snp.bottom).offset(10)
        }
        marketLabel.snp.remakeConstraints { (make) in
            make.edges.equalTo(performTextField)
        }
        
        marketPerformBtn.snp.makeConstraints { (make) in
            make.left.equalTo(performTextField.snp.right).offset(5)
            make.right.equalTo(priceTextField)
            make.width.equalTo(60)
            make.top.height.equalTo(performTextField)
        }
      //  reloadTransationTypeView()
    }
    
    func showPlanTypeUI(_ show:Bool) {
        triggerTextField.isHidden = !show
        performTextField.isHidden = !show
        marketPerformBtn.isHidden = !show
        
        if show, marketPerformBtn.isSelected {
            marketLabel.isHidden = false
            defineOrderType = .planOrder(isMarket: true)
        }else {
            marketLabel.isHidden = true
        }
    }
    //MARK: 平仓调整 可开多和可开空的距离按钮的间距 English: MARK: Adjust the spacing between the distance buttons for opening more and opening less positions during closing positions
//    func reloadCanCloseLabel() {
//        canCloseShortLabel.snp.remakeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.height.equalTo(17)
//            make.bottom.equalTo(sellBtn.snp.top).offset(-8)
//        }
//        canCloseMoreLabel.snp.remakeConstraints { (make) in
//            make.left.right.equalToSuperview()
//            make.height.equalTo(17)
//            make.bottom.equalTo(buyBtn.snp.top).offset(-8)
//
//        }
//    }
    
    func setupOnlySell(hide:Bool) {
        onlySellBtn.isHidden = !hide
        orderBuyBtn.isHidden = hide
        orderSellBtn.isHidden = hide
        reloadLayoutMargin()
        
    }
    
    //MARK: 止盈止损的处理 English: MARK: Treatment of stop loss and stop loss
    func reloadStopPLModule() {
        
        var hidePLModule = false
        if case .planOrder(_) = defineOrderType {
            hidePLModule = true
        }
        if transactionShowType == .showClose {
            hidePLModule = true
        }
        if hidePLModule {
            stopPLButtonContentView.isHidden = true
            stopPLButton.isSelected = false
            
        }else {
            stopPLButtonContentView.isHidden = false
        }
        if hidePLModule {
            stopPLButton.isSelected = false
            stopPLFieldTopMagin.isHidden = true
            stopPLFieldContentView.isHidden = true
            stopProfitPriceField.input.text = ""
            stopLossPriceField.input.text = ""
        }
    }
    func reloadMarketOrderView() { // 委托类型加载界面 English: Delegate Type Loading Interface
//        debug//print("====>\(#function)")
        reloadUnitData()
        reloadLayoutMargin()
        priceTextField.isHidden = false
        if case .planOrder(_) = defineOrderType {
            priceTextField.isHidden = true
        }
        if defineOrderType == .market {
            priceTextField.isHidden = true
        }
        priceTextField.input.isUserInteractionEnabled = !(defineOrderType == .market)
        reloadStopPLModule()
        
        if case .planOrder(_) = defineOrderType { // 计划委托 English: Plan delegation
            
            showPlanTypeUI(true)
            updateMarketPriceUI(hidden: true)
            planVolumeLayout()
        }else {
//            if defineOrderType == .limited {
//
//              //  opponentView.showOpponentUI()
//            }else {
//               // opponentView.hideOpponentUI()
//            }
            showPlanTypeUI(false)
            limitVolumeLayout()
            
            if defineOrderType == .market {
                //市价可以直接计算可买可卖 English: The market price can be directly calculated as available for purchase or sale
                reloadMakeOrderData()
                entrustLabel.text = entrustLabelText()
                updateMarketPriceUI(hidden: false)
            }else {
                updateMarketPriceUI(hidden: true)
                
            }
        }
    }
    
    func updateMarketPriceUI(hidden:Bool) {
        
        priceTextField.input.endEditing(true)
        marketPriceLabel.text = "   " + "cp_overview_text36".ex_localized()
        marketPriceLabel.isHidden = hidden
    }
    //MARK: 市价数量输入框 的单位 English: MARK: The unit of the market price quantity input box
    func updateVolumModule() {
        updateVolumeDecail()
        let text = getVolumeFieldPlaceholdText()
        let placeH = text
        volumeTextField.setPlaceHolder(placeHolder: placeH, font: 14)
    }
    
    func getEntrustLabelUnit() -> String {
        
        guard let vm = makeOrderViewModel else { return "" }
        //MARK: 限价委托价值单位为币 English: MARK: The value of the price limit commission is in currency
        if openOrderType == .value {
            let unit =  makeOrderViewModel?.itemModel?.ex_contractInfo?.base_coin ?? ""
//            //print("限价委托价值=\(unit)") English: Print ("Limit commission value=\ (unit)")
            return  unit // 币 English: currency
        }
        if shouldVolumeFieldUseQuoteCoinCalculate() {
            
            return makeOrderViewModel?.volumeUnit ?? ""
        }
        if vm.isCoin {
            
            return "cp_overview_text9".ex_localized()
        }
        
        return vm.itemModel!.ex_contractInfo?.base_coin ?? ""
    }
    
    func getVolumeUnit() -> String {
        
        if shouldVolumeFieldUseQuoteCoinCalculate() {
            
            return makeOrderViewModel?.openValueUnit ?? ""
        }
        
        return makeOrderViewModel?.volumeUnit ?? ""
    }
    
    func getVolumeFieldPlaceholdText() -> String {
        if transactionShowType == .showOpen{
            //市价类型需要单位 English: Market price type requires units
            if  defineOrderType.isMarketOrderType() {
                let unit = getVolumeUnit()
                return "cp_overview_text28".ex_localized() + "(" + unit + ")"
            }
            //别的类型无需单位 English: Other types do not require units
            return  "cp_overview_text8".ex_localized()
        }else{ //平仓全要单位 English: All units required for closing positions
            //市价类型--数量单位 English: Market price type - quantity unit
            if  defineOrderType.isMarketOrderType() {
                let unit = getVolumeUnit()
                return "cp_overview_text8".ex_localized() + "(" + unit + ")"
            }
            var unit = "cp_overview_text9".ex_localized()
            //其他类型 English: Other types
            if let vm = makeOrderViewModel {
                if vm.isCoin {
                   unit = vm.itemModel?.ex_contractInfo?.base_coin ?? ""
                }
            }
            return "cp_overview_text8".ex_localized() + "(" + unit + ")"
        }
       
    }
    func shouldVolumeFieldUseQuoteCoinCalculate() -> Bool {
        if defineOrderType.isMarketOrderType() && transactionShowType == .showOpen {
            return true
        }
        return false
    }
    func updateUIForShowCloseType() { // 平仓 English: Closing position
        if !hasLogin() { // 未登录状态 持仓 English: Unlogged Position
            
            getCloseEmpty(price: "-", volume: makeOrderViewModel?.volumeUnit ?? "-")
            getCloseMore(price: "-", volume: makeOrderViewModel?.volumeUnit ?? "-")
            
            
        } else { // 登录状态 English: Login status
            getCloseMore(price: makeOrderViewModel?.canCloseMore ?? "0", volume: makeOrderViewModel?.volumeUnit ?? "-")
            getCloseEmpty(price: makeOrderViewModel?.canCloseShort ?? "0", volume: makeOrderViewModel?.volumeUnit ?? "-")
        }
    }
    
    func setupCanOpenText() {
        if transactionShowType == .showOpen { // 开仓 English: open a granary to provide relief
            if !hasLogin() { // 未登录状态 English: Not logged in status
                self.getOpenMore(price: "-", volume: self.makeOrderViewModel?.volumeUnit ?? "-")
                self.getOpenEmpty(price: "-", volume: self.makeOrderViewModel?.volumeUnit ?? "-")
            } else { // 登录状态 English: Login status
                self.getOpenMore(price: self.makeOrderViewModel?.canOpenMore ?? "0", volume: self.makeOrderViewModel?.volumeUnit ?? "-")
                self.getOpenEmpty(price: self.makeOrderViewModel?.canOpenShort ?? "0", volume: self.makeOrderViewModel?.volumeUnit ?? "-")
            }

            
        } else if transactionShowType == .showClose  { // 平仓 English: Closing position
            updateUIForShowCloseType()
        }
        
    }
    func reloadTransationTypeView() { // 开平仓加载界面 English: Loading interface for opening and closing positions
        reloadStopPLModule()
        updateVolumModule()
        refreshBtnTitle()
        setupCanOpenText()
        reloadLayoutMargin()
        if defineOrderType == .market{            
            self.updateVolumeTextFieldTypeSource()
            self.updateVolumeTextFieldTypeBtn()
        }
        
    }
    func reloadLayoutMargin() {
        var space = 55
        if transactionShowType == .showOpen { //开仓 English: open a granary to provide relief
           canCloseMoreLabel.isHidden = true
           canCloseShortLabel.isHidden = true
            if self.onlySellBtn.isHidden == true && self.stopPLButton.isSelected { //双向 English: two-way
                space = 48
            }
            // 买入开多 English: Buy Kaiduo
            UIView.animate(withDuration: 0.08) { [weak self] in
                guard  let s = self else {
                    return
                }
                s.buyBtn.snp.updateConstraints { make in
                    make.bottom.equalTo(s.sellBtn.snp.top).offset(-space)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.canOpenMoreLabel.isHidden = false
                self?.canOpenShortLabel.isHidden = false
                self?.canMoreCostLabel.isHidden = false
                self?.canShortCostLabel.isHidden = false
            }
          
            
        }else{ //平仓 English: Closing position
            
            space = 39
            
            UIView.animate(withDuration: 0.08) { [weak self] in
                guard  let s = self else {
                    return
                }
                s.buyBtn.snp.updateConstraints { make in
                    make.bottom.equalTo(s.sellBtn.snp.top).offset(-space)
                }
            }
            canOpenMoreLabel.isHidden = true
            canOpenShortLabel.isHidden = true
            canMoreCostLabel.isHidden = true
            canShortCostLabel.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.canCloseMoreLabel.isHidden = false
                self?.canCloseShortLabel.isHidden = false
                
            }
        }
        
       // //print("reloadLayoutMargin =\(reloadLayoutMargin)")
        
    }
    func resetTextField(clearPrice: Bool = true) {
        if clearPrice{
            priceTextField.input.text = ""
        }
        volumeTextField.reset()
        performTextField.input.text = ""
        stopLossPriceField.input.text = ""
        stopProfitPriceField.input.text = ""
        _currentPercent = ""
        entrustLabel.text = entrustLabelText()
    }
    
    func setupShouldLoginOrRegisterView(hide:Bool) {
        self.shouldLoginOrRegisterView.isHidden = hide
        self.logoutMaskView.isHidden = hide
        
    }
    
    func setupBuyAndSellBtn(buyAttrString:NSAttributedString,sellAttrString:NSAttributedString) {
        
        self.buyBtn.setAttributedTitle(buyAttrString, for: .normal)
        self.buyBtn.setAttributedTitle(buyAttrString, for: .selected)
        self.sellBtn.setAttributedTitle(sellAttrString, for: .normal)
        self.sellBtn.setAttributedTitle(sellAttrString, for: .selected)
    }
    
    //MARK:  登录/注册 /买卖 English: MARK: Login/Registration/Trading
    func refreshBtnTitle() {
        
        if hasLogin() && SLUserConfig.checkHasOpenContract {
            setupShouldLoginOrRegisterView(hide: true)
        }else{
            setupShouldLoginOrRegisterView(hide: false)
            //登录 English: Login
            if !hasLogin(){
                shouldLoginOrRegisterView.setupLoginUI()
                return
            }
            if !SLUserConfig.checkHasOpenContract{
                shouldLoginOrRegisterView.setupRegisterUI()
                return
            }
        }
        if transactionShowType == .showOpen { // 开仓 English: open a granary to provide relief
            let buyAttrString = NSMutableAttributedString().exs_add(string: "cp_overview_text13".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.ThemeFont.BodyBold])
            let sellAttrString = NSMutableAttributedString().exs_add(string: "cp_overview_text14".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.ThemeFont.BodyBold])
            self.setupBuyAndSellBtn(buyAttrString: buyAttrString, sellAttrString: sellAttrString)
            
        } else if transactionShowType == .showClose  { // 平仓 English: Closing position
            
            let buyAttrString = NSMutableAttributedString().exs_add(string: "cp_extra_text4".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.ThemeFont.BodyBold])
            let sellAttrString = NSMutableAttributedString().exs_add(string:"cp_extra_text5".ex_localized(), attrDic: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.ThemeFont.BodyBold])
            self.setupBuyAndSellBtn(buyAttrString: buyAttrString, sellAttrString: sellAttrString)
        }
    }
    
    fileprivate func setupCostLabel() {
        
        setupOpenLongLabel()
        setupOpenShortLabel()
    }
    
    func setupOpenLongLabel() {
        if let openLongModel = makeOrderViewModel?.orderLongModel {
            var cost = "0"
            if !onlySellBtn.isSelected && transactionShowType == .showOpen {
                
                    if  !openLongModel.freezAssets.isEmpty {
                        cost = (openLongModel.freezAssets) //.toValuePrecision(withContract: openLongModel.instrument_id,holdzero: false)
                    }
            }
            if let marginCoin = openLongModel.ex_contractInfo?.margin_coin {
                cost = cost + " " + marginCoin
            }
            self.canMoreCostLabel.rightLabel.text = cost
        }
    }
    func setupOpenShortLabel() {
        if let openShortModel = makeOrderViewModel?.orderShortModel {
            var cost = "0"
            if !onlySellBtn.isSelected && transactionShowType == .showOpen {
                
                let v = openShortModel.freezAssets
                if !v.isEmpty {
                    cost = (openShortModel.freezAssets) //.toValuePrecision(withContract: openShortModel.instrument_id,holdzero: false)
                }
            }
            if let marginCoin = openShortModel.ex_contractInfo?.margin_coin {
                cost = cost + " " + marginCoin
            }
            self.canShortCostLabel.rightLabel.text = cost
        }
    }
    
    //MARK: 刷新订单数据 可开多/可开空 English: MARK: Refreshing order data allows for opening more/opening less
    func reloadMakeOrderData() { // 数据改变加载界面 订阅 English: Data change loading interface subscription
        entrustLabel.isHidden = false
        if self.openOrderType == .qty { // 数量 /为币下单时 隐藏币的折合 English: Quantity/hidden currency conversion when placing an order for currency
            if self.makeOrderViewModel?.isCoin ?? false {
                entrustLabel.isHidden = true
            }
        }
        
        if transactionShowType == .showClose {
            entrustLabel.isHidden = true
        }
        
        if makeOrderViewModel == nil || makeOrderViewModel?.itemModel == nil {
            return
        }
        
        if hasLogin() {
            if transactionShowType == .showOpen { // 开仓页面 English: Opening page
                if  case .planOrder(_) = self.defineOrderType {
                    makeOrderViewModel!.loadOpenOrder(px: self.triggerTextField.input.text,
                                                      emptyPx: self.triggerTextField.input.text,
                                                      moreQty: openMoreQty,
                                                      emptyQty: openEmptyQty,
                                                      currentPercent:_currentPercent,
                                                      perform_px: self.performTextField.input.text ?? "0",
                                                      contractType: defineOrderType,
                                                      priceType: normalPriceType,
                                                      planPriceType: performPriceType,
                                                      timeForce: 0,
                                                      openOrderType: self.openOrderType
                    )
                }  else {
                    let opponentType = EXOpponentPriceType.none
                    var idx = 1
                    if defineOrderType == .postOnly {
                        idx = 1
                    } else if defineOrderType == .fillOrKill {
                        idx = 2
                    } else if defineOrderType == .immediateOrCance {
                        idx = 3
                    }
                    makeOrderViewModel!.loadOpenOrder(px: self.executeOpenLongPrice,
                                                      emptyPx:self.executeOpenEmptyPrice,
                                                      opponentType: opponentType,
                                                      moreQty: openMoreQty,
                                                      emptyQty: openEmptyQty,
                                                      currentPercent:_currentPercent,
                                                      perform_px: self.performTextField.input.text ?? "0",
                                                      contractType: defineOrderType,
                                                      priceType: normalPriceType,
                                                      planPriceType: performPriceType,
                                                      timeForce: idx,
                                                      openOrderType: self.openOrderType
                    )
                    if self.stopPLButton.isSelected {
                        
                        makeOrderViewModel?.orderLongModel?.takerProfitTrigger = self.stopProfitPriceField.input.text ?? ""
                        makeOrderViewModel?.orderLongModel?.stopLossTrigger = self.stopLossPriceField.input.text ?? ""
                        
                        makeOrderViewModel?.orderShortModel?.takerProfitTrigger = self.stopProfitPriceField.input.text ?? ""
                        makeOrderViewModel?.orderShortModel?.stopLossTrigger = self.stopLossPriceField.input.text ?? ""
                    }
                }
                self.getOpenMore(price: self.makeOrderViewModel?.canOpenMore ?? "0", volume: self.makeOrderViewModel?.volumeUnit ?? "-")
                self.getOpenEmpty(price: (self.makeOrderViewModel?.canOpenShort ?? "0"), volume: self.makeOrderViewModel?.volumeUnit ?? "-")
                setupCostLabel()
            } else { // 平仓页面 English: Closing page
                if self.defineOrderType == .limited {
                    makeOrderViewModel!.loadCloseOrder(px: self.executeOpenLongPrice,
                                                       emptyPx:self.executeOpenEmptyPrice,
                                                       qty: self.volumeTextField.stepInput.input.text,
                                                       qtyPrecent: _currentPercent,
                                                       perform_px: self.performTextField.input.text ?? "0",
                                                       contractType: defineOrderType,
                                                       priceType: normalPriceType,
                                                       planPriceType: performPriceType,
                                                       timeForce: 0)
                } else if self.defineOrderType.isHighOrderType() {
                    var idx = 1
                    if defineOrderType == .postOnly {
                        idx = 1
                    } else if defineOrderType == .fillOrKill {
                        idx = 2
                    } else if defineOrderType == .immediateOrCance {
                        idx = 3
                    }
                    makeOrderViewModel!.loadCloseOrder(px: self.executeOpenLongPrice,
                                                       emptyPx:self.executeOpenEmptyPrice,
                                                       qty: self.volumeTextField.stepInput.input.text,
                                                       qtyPrecent: _currentPercent,
                                                       perform_px: self.performTextField.input.text ?? "0",
                                                       contractType: defineOrderType,
                                                       priceType: normalPriceType,
                                                       planPriceType: performPriceType,
                                                       timeForce: idx)
                } else {
                    makeOrderViewModel!.loadCloseOrder(px: self.triggerTextField.input.text,
                                                       emptyPx:self.triggerTextField.input.text,
                                                       qty: self.volumeTextField.stepInput.input.text,
                                                       qtyPrecent: _currentPercent,
                                                       perform_px: self.performTextField.input.text ?? "0",
                                                       contractType: defineOrderType,
                                                       priceType: normalPriceType,
                                                       planPriceType: performPriceType,
                                                       timeForce: 0)
                }
                self.getCloseMore(price: self.makeOrderViewModel?.canCloseMore ?? "0", volume: self.makeOrderViewModel?.volumeUnit ?? "-")
                self.getCloseEmpty(price: self.makeOrderViewModel?.canCloseShort ?? "0", volume: self.makeOrderViewModel?.volumeUnit ?? "-")
                setupCostLabel()
            }
        } else {
        }
    }
    func setAvailabelLabe() {
        
    }
    //MARK: 输入框 English: MARK: Input box
    func textFieldValueHasChanged(textField:UITextField) {
        if makeOrderViewModel == nil || makeOrderViewModel?.itemModel == nil || makeOrderViewModel?.itemModel?.ex_contractInfo == nil {
            return
        }
        reloadMakeOrderData() //第一步计算最大可开 English: The first step is to calculate the maximum opening capacity
        reloadMakeOrderData() //真正计算 English: True calculation
        entrustLabel.text = entrustLabelText()
        //MARK: fix 余额不足toast showFail English: MARK: Insufficient fix balance toast showFailure
        //MARK: 必填项有值才处理 English: MARK: Required fields must have values before processing
        switch defineOrderType {
        case .limited:
            if (priceTextField.input.text == nil || (priceTextField.input.text ?? "0").lessThanOrEqual(BTZERO)) {
                return
            }
            
        case  .planOrder://计划委托 English: Plan delegation
            if performPriceType == .limitPlan {
                if performTextField.input.text == nil || (performTextField.input.text ?? "0").lessThanOrEqual(BTZERO) {
                    return
                }
            }
            
        default:break
            
        }
        
        if volumeTextField.stepInput.input.text == nil || (volumeTextField.stepInput.input.text ?? "0").lessThanOrEqual(BTZERO) {
            return
        }
        //MARK: 必填项有值才来校验 English: MARK: Only verify if there is a value for a required field
        var order : EXContractOrderModel?
        if transactionShowType == .showOpen { // 开仓 English: open a granary to provide relief
            order = makeOrderViewModel?.orderLongModel
            //MARK: 多单 English: MARK: Multiple orders
            if let o = order {
                var qty = o.qty
                //MARK: 校验市价 English: MARK: Verify market price
                if o.freezAssets.greaterThan(makeOrderViewModel?.canUseAmount ?? "0") {
                    //MARK: 余额不足; English: MARK: Insufficient balance;
                    EXAlert.showFail(msg: "cp_str_insufficient".ex_localized(),holdResponder: true)
                    return
                }
                
                //MARK: 限价委托价值 English: MARK: Limit Order Value
                if self.openOrderType == .value {
                    
                }else{
                    if shouldVolumeFieldUseQuoteCoinCalculate() == false{ //非市价比较 English: Non market price comparison
                        if let vm = makeOrderViewModel,let info = vm.itemModel?.ex_contractInfo, vm.isCoin {
                            qty = EXFormula.ticket(toCoin: qty, price: "", contract: info)
                        }
                        if qty.greaterThan(makeOrderViewModel?.canOpenMore ?? "0") {
                            //MARK: 超过最大可开数量"; English: "MARK: Exceeded the maximum number of openings";
                            EXAlert.showFail(msg: "cp_extra_text168".ex_localized(),holdResponder: true)
                            return
                        }
                    }
                }
            }
        }
    }
    
    func getCurrentPrice() -> String {
        var price = "0"
        if self.defineOrderType == .limited {
            price = self.executeOpenLongPrice
        } else if self.defineOrderType.isHighOrderType() {
            price = self.executeOpenLongPrice
        }else if defineOrderType == .market {
            price = makeOrderViewModel?.middleValue() ?? "0"
        } else {
            if performPriceType == .marketPlan {
                price = self.triggerTextField.input.text ?? "0"
            } else {
                price = self.performTextField.input.text ?? "0"
            }
        }
        
        return price
    }
    //MARK: 预估成本 English: MARK: Estimated cost
    func entrustLabelText() -> String {
        
        let price = getCurrentPrice()
        let vol = self.openMoreQty
        var amount = BTZERO;
        guard let vm = makeOrderViewModel else { return "" }
        ////print("输入价格=\(price) 输入量 =\(vol)") English: Print ("Input price=(price) Input quantity=(vol)")
        if let info = vm.itemModel?.ex_contractInfo {
            //MARK: 限价委托价值 English: MARK: Limit Order Value
            if self.openOrderType == .value{
                amount = EXFormula.valueTobi(value: vol, price: price, contractModel: info)
            }else{
                
                //市价单独处理 English: Separate processing of market price
                if shouldVolumeFieldUseQuoteCoinCalculate() {
                    //市价先清空末位0 English: Clear the last 0 of the market price first
                    amount = amount.toString(0)
                    if !vol.isEmpty {
                        amount = EXFormula.calculateContractValue(withValue: vol, price: price, contract: info)
                        if !vm.isCoin {
                            amount = amount.bigDiv(info.face_value).toString(0)
                        }else {
                            amount = amount.toVolumePrecision(withContractID: info.instrument_id,holdZero: true)
                        }
                    }
                }else{
                    if vm.isCoin { //币的话 -- 折合 张 English: In terms of currency - equivalent to Zhang
                        amount = EXFormula.coin(toTicket: vol, price: price, contract: info).toString(0)
                    } else { //张的话 -- 折合币 English: Zhang's Words - Equivalent to Coins
                        amount = EXFormula.ticket(toCoin: vol, contract: info)
                        //币 合约数量精度计算 English: Calculation of Precision in Currency Contract Quantity
                        amount = amount.toVolumePrecision(withContractID: info.instrument_id,holdZero: true)
                    }
                }
            }
        }
        
        return "≈ " + amount + " " + getEntrustLabelUnit()
    }
    
    func reloadUnitData() {
        
        updateVolumModule()
        volumeTextField.reset(callback: false)
        _currentPercent = ""
        if let quoteCoin = makeOrderViewModel?.itemModel?.ex_contractInfo?.quote_coin {
            
//            priceTextField.unitLabel.text = quoteCoin
            //触发价格单位隐藏 English: Trigger price unit hiding
           // triggerTextField.unitLabel.text = quoteCoin
        }
    }
}

// MARK: - Even Click
// MARK: 开仓平仓 English: MARK: Opening and closing positions
extension EXContractMakeOrderView {
    @objc func onOrderActionChanged(_ sender:UIButton) {
        self.endEditing(true)
        if sender == orderBuyBtn {
            if orderBuyBtn.isSelected  {
                return
            }
         
            updateTransactionShowTypeBlock?(.showOpen)
            //            transactionShowType = .showOpen
            sender.isSelected = true
            orderSellBtn.isSelected = false
            
        }else if sender == orderSellBtn {
            if orderSellBtn.isSelected {
                return
            }
           
            updateTransactionShowTypeBlock?(.showClose)
            //            transactionShowType = .showClose
            sender.isSelected = true
            orderBuyBtn.isSelected = false
           
        }
        updateVolumeTextFieldTypeBtn()
        onlySellBtn.isSelected = orderSellBtn.isSelected
        
    }
    
    //MARK: 价值下单按钮处理 English: MARK: Value Order Button Processing
    func updateVolumeTextFieldTypeBtn(){
        
        if transactionShowType == .showClose {
            volumeTextField.updateTypeBtn(show: false)
        }else{
            if defineOrderType == .market || defineOrderType == .planOrder(isMarket: true) {
                volumeTextField.updateTypeBtn(show: false)
            }else{
                volumeTextField.updateTypeBtn(show: true)
            }
        }
    }
    //MARK: 点击计划委托的市价 English: MARK: Click on the market price of the plan commission
    @objc func clickPlanMarketBtn(_ btn : UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            marketLabel.isHidden = false
            performTextField.input.isUserInteractionEnabled = false
            performPriceType = .marketPlan
            btn.backgroundColor = UIColor.Ex.main3
            btn.layer.borderColor = UIColor.Ex.main3.cgColor
            
        } else {
            marketLabel.isHidden = true
            performTextField.input.isUserInteractionEnabled = true
            performPriceType = .limitPlan
            btn.backgroundColor = UIColor.getConfigBg()
            btn.layer.borderColor = UIColor.ThemeView.border.cgColor
        }
        
        defineOrderType = .planOrder(isMarket: btn.isSelected)
        updateVolumeTextFieldTypeBtn()
        updateVolumModule()
        entrustLabel.text = entrustLabelText()
        reloadMakeOrderData()
    }
    //MARK: 只减仓 English: MARK: Only reduce positions
    @objc func clickedOnlySellBtn(sender:UIButton) {
        
        sender.isSelected = !sender.isSelected;
        orderSellBtn.isSelected = sender.isSelected
        orderBuyBtn.isSelected = !sender.isSelected
        updateTransactionShowTypeBlock?(sender.isSelected ?.showClose : .showOpen)
//        volumeTextField.updateTypeBtn(show: sender.isSelected == false)
        updateVolumeTextFieldTypeBtn()
        resetTextField(clearPrice: false)
    }
    //MARK: 止盈止损 打开 English: MARK: Stop profit and stop loss open
    @objc func clickedStopPLBtn(sender:UIButton) {
        sender.isSelected = !sender.isSelected;
        if !sender.isSelected {
            stopLossPriceField.input.text = ""
            stopProfitPriceField.input.text = ""
        }
        stopPLFieldTopMagin.isHidden = !sender.isSelected
        stopPLFieldContentView.isHidden = !sender.isSelected
        updateDepthMaxCountBlock?()
        reloadLayoutMargin()
        EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_positions_tpsl.rawValue)
    }
    func updateVolumeDecail() {
        //MARK: 限价委托价值 English: MARK: Limit Order Value
        //市价 English: market price
        if shouldVolumeFieldUseQuoteCoinCalculate() || (openOrderType == .value && transactionShowType == .showOpen){
            volumeVaild.decail = makeOrderViewModel?.itemModel?.ex_contractInfo?.minOrderMoney_unit ?? "0.01"
        }else{
            //张 English: Zhang
            if let isCoin = makeOrderViewModel?.isCoin,!isCoin {
                volumeVaild.decail = "0"
            }else {
                self.volumeVaild.decail = makeOrderViewModel?.itemModel?.ex_contractInfo?.qty_unit ?? "0.01"
              //  //print("makeOrderViewModel?.itemModel?.ex_contractInfo?.qty_unit = \(makeOrderViewModel?.itemModel?.ex_contractInfo?.qty_unit ?? "0.01")")
            }
        }
        //MARK: 输入框位数限制 English: MARK: Input box limit
        volumeTextField.decimal = "\(volumeVaild.limetValue)"
        if shouldVolumeFieldUseQuoteCoinCalculate() {
            volumeTextField.stepInput.input.keyboardType = UIKeyboardType.decimalPad
            
        }else if EXStoreData.storeBool(forKey: EXS_UNIT_VOL) {
            
            volumeTextField.stepInput.input.keyboardType = UIKeyboardType.decimalPad
        } else {
            volumeTextField.stepInput.input.keyboardType = UIKeyboardType.numberPad
        }
        //小数位限制为0 只能输入整数 English: The decimal limit is 0, and only integers can be entered
        if volumeVaild.limetValue > 0 {
            volumeTextField.stepInput.input.keyboardType = UIKeyboardType.decimalPad
        }else{
            volumeTextField.stepInput.input.keyboardType = UIKeyboardType.numberPad
        }
    }
    
    func validateInput() -> Bool {
        
        switch defineOrderType {
        case .limited:
            
            if (priceTextField.input.text == nil || (priceTextField.input.text ?? "0").lessThanOrEqual(BTZERO)) {
                priceTextField.input.becomeFirstResponder()
                //  EXAlert.showFail(msg: "cp_tip_text1".ex_localized())
                return false
            }
            
        case  .planOrder:
            if triggerTextField.input.text == nil || (triggerTextField.input.text ?? "0").lessThanOrEqual(BTZERO) {
                triggerTextField.input.becomeFirstResponder()
                //  EXAlert.showFail(msg:  "cp_tip_text2".ex_localized())
                return false
            }
            if performPriceType == .limitPlan {
                if performTextField.input.text == nil || (performTextField.input.text ?? "0").lessThanOrEqual(BTZERO) {
                    performTextField.input.becomeFirstResponder()
                    //   EXAlert.showFail(msg:  "cp_extra_text33".ex_localized())
                    return false
                }
            }
        default:break
            
        }
        
        if volumeTextField.stepInput.input.text == nil || (volumeTextField.stepInput.input.text ?? "0").lessThanOrEqual(BTZERO) {
            volumeTextField.stepInput.input.becomeFirstResponder()
            if shouldVolumeFieldUseQuoteCoinCalculate() {
                // EXAlert.showFail(msg: "cp_content_text9".ex_localized())
            }else {
                
                // EXAlert.showFail(msg:  "cp_extra_text34".ex_localized())
            }
            return false
        }

        if self.stopPLButton.isSelected{ //Stop profit and stop loss processing
            
            var stopProfitPassed = false
            if let stopProfit = self.stopProfitPriceField.input.text, stopProfit.greaterThan("0"){
                stopProfitPassed = true
            }
            var stopLossPassed = false
            if let stopLoss = self.stopLossPriceField.input.text, stopLoss.greaterThan("0"){
                stopLossPassed = true
            }
            if stopProfitPassed || stopLossPassed {
                return true
            }
            self.stopProfitPriceField.input.becomeFirstResponder()
            return false
        }
        return true
    }
    //校验限价偏离比例失败 English: Verification of price limit deviation ratio failed
    func validateLimitPriceDeviationRatioFailure(_ btn : UIButton, order:EXContractOrderModel, itemM:EXSwapItemModel, validModel:EXCoinResultVoModel) -> Bool {
        
        if validModel.priceRange.isEmpty {
            return false
        }
        
        if defineOrderType.isHighOrderType() || defineOrderType == .limited  {
            
            //买入偏离(委托价格 - 最新价格) / 最新价格 English: Buy deviation (commission price - latest price)/latest price
            let buyDeviationRatio = order.px.bigSub(itemM.last_px).bigDiv(itemM.last_px)
            //卖出偏离(最新价格 - 委托价格) / 最新价格 English: Selling deviation (latest price - commission price)/latest price
            let sellDeviationRatio = itemM.last_px.bigSub(order.px).bigDiv(itemM.last_px)
            
            if btn == sellBtn {
                return sellDeviationRatio.greaterThan(validModel.priceRange)
            }
            if btn == buyBtn {
                return buyDeviationRatio.greaterThan(validModel.priceRange)
            }
            
        }
        
        if defineOrderType.isLimitPlan() {//条件单 English: Condition sheet
            //(委托价格 - 触发价格) / 触发价格 English: (Commission price - Trigger price)/Trigger price
            let planLimitBuyDeviationRatio = order.exec_px.bigSub(order.triggerPrice).bigDiv(order.triggerPrice)
            //(触发价格 - 委托价格) / 触发价格 English: (Trigger price - commission price)/Trigger price
            let planLimitSellDeviationRatio = order.triggerPrice.bigSub(order.exec_px).bigDiv(order.triggerPrice)
            
            if btn == sellBtn {
                return planLimitSellDeviationRatio.greaterThan(validModel.priceRange)
            }
            if btn == buyBtn {
                return planLimitBuyDeviationRatio.greaterThan(validModel.priceRange)
            }
        }
        return false
    }
    
    func getOrder(btn: UIButton) -> EXContractOrderModel?{
        var order : EXContractOrderModel?
        if btn == self.buyBtn && transactionShowType == .showOpen {
            order = makeOrderViewModel?.orderLongModel
        }
        if btn == self.sellBtn && transactionShowType == .showOpen {
            order = makeOrderViewModel?.orderShortModel
        }
        if btn == self.buyBtn && transactionShowType == .showClose {
            order = makeOrderViewModel?.orderCloseShortModel
        }
        if btn == self.sellBtn && transactionShowType == .showClose {
            order = makeOrderViewModel?.orderCloseMoreModel
        }
        return order
    }
    //校验 English: check
    func validateOrder(btn:UIButton,order : EXContractOrderModel?) -> Bool {
        
        if let itemM = makeOrderViewModel?.itemModel, let info = itemM.ex_contractInfo {
            
            let validModel = info.coinResultVo
            var marginCoin = info.quote_coin
            if info.isReverse == true { //反向 单位需切换 English: Reverse unit needs to be switched
                marginCoin = info.base
            }
            if transactionShowType == .showOpen{
                //print("输入的下单量 -\(order?.qty)")
                //MARK: freezAssets 开仓价值 English: MARK: FreezAssets opening value
                if (order?.freezAssets ?? "0").greaterThan(makeOrderViewModel?.canUseAmount ?? "0"){
                    //MARK: fix 余额不足 English: MARK: Insufficient fix balance
                    self.moneyShortCallBack?()
                    return false
                }
                //MARK: 市价的校验逻辑 English: MARK: Verification logic for market price
                if shouldVolumeFieldUseQuoteCoinCalculate() {
                    order?.orderUnit = 1//:价值 English: : Value
                    if defineOrderType == .market {
                        if (order?.px.count ?? 0) == 0 {
                            //MARK: fix 待优化 English: MARK: Fix to be optimized
                            EXAlert.showFail(msg: "order_placement_text6".ex_localized())
                            //若不存在委托价格（没有买一、卖一和最新成交价），委托不可提交，提示“委托不可提交” English: If there is no commission price (without buy one, sell one, and the latest transaction price), the commission cannot be submitted, and a prompt "Commission cannot be submitted" is displayed
                            return false
                        }
                    }
                    let max = makeOrderViewModel!.openOrderValueMax
                    let min = makeOrderViewModel!.openOrderValueMin
                    if max.greaterThan("0")  {
                        if (order?.qty ?? "0").greaterThan(max) {
                            let unit = max + " " + marginCoin + "！"
                            let msg = String(format:"order_placement_text4".ex_localized(),unit)
                            EXAlert.showFail(msg: msg)
                            return false
                        }
                    }
                    if min.greaterThan("0"){
                        if (order?.qty ?? "0").lessThan(min) {
                            let unit = min + " " + marginCoin + "！"
                            let msg = String(format:"order_placement_text3".ex_localized(),unit)
                            EXAlert.showFail(msg:msg)
                            return false
                        }
                    }
                }else {
                    //MARK: 限价委托价值的校验逻辑 English: MARK: Verification logic for limit price commission value
                    if self.openOrderType == .value {
                        order?.orderUnit = 1//:价值 English: : Value
                        if makeOrderViewModel!.openOrderValueMax.greaterThan("0") {
                            if (order?.qty ?? "0").greaterThan(makeOrderViewModel!.openOrderValueMax) {
                                EXAlert.showFail(msg: String(format:"order_placement_text4".ex_localized(),"\(makeOrderViewModel!.openOrderValueMax) \(marginCoin)"))
                                return false
                            }
                        }
                        
                        if makeOrderViewModel!.openOrderValueMin.greaterThan("0"){
                            if (order?.qty ?? "0").lessThan(makeOrderViewModel!.openOrderValueMin){
                                EXAlert.showFail(msg: String(format:"order_placement_text3".ex_localized(),"\(makeOrderViewModel!.openOrderValueMin) \(marginCoin)"))
                                return false
                            }
                        }
                        
                    }else{
                        order?.orderUnit = 0
                        if let iscoin = self.makeOrderViewModel?.isCoin, iscoin == true {
                            order?.orderUnit = 2//币 English: currency
                        }
                        
                        switch defineOrderType {
                        case .limited,.fillOrKill,.postOnly,.immediateOrCance:
                            if let o = order,
                               o.px.isEmpty {
                                
                                EXAlert.showFail(msg: "cp_overview_text50".ex_localized())
                                return false
                            }
                        default:break
                        }
                        
                        var min = validModel.minOrderVolume
                        var max = validModel.maxLimitVolume
                       
                        
                        var unit = self.makeOrderViewModel?.volumeUnit ?? ""
                        
                        if min.greaterThan("0"){
                            if (order?.qty ?? "0").lessThan(min) { //这里拿到的 order?.qty 是币转化为张的.，提示需要提示单位为币 English: Did you get the order here QTY is the conversion of coins into Zhang, Prompt needs to be prompted in currency
                                if let iscoin = self.makeOrderViewModel?.isCoin, iscoin == true {
                                    min = self.makeOrderViewModel?.openOrderCoinMin ?? "0"
                                }
                                
                                let minTip = "order_placement_text7".ex_localized() + " " + min + " " + unit
                                EXAlert.showFail(msg: minTip)
                                return false
                            }
                        }
                        if max.greaterThan("0"){
                            if (order?.qty ?? "0").greaterThan(max) {
                                if let iscoin = self.makeOrderViewModel?.isCoin, iscoin == true {
                                    max = self.makeOrderViewModel?.openOrderCoinMax ?? "0"
                                }
                                let maxTip = "order_placement_text8".ex_localized() + " " + max + " " + unit
                                EXAlert.showFail(msg:maxTip)
                                return false
                            }
                        }
                        if let o = order, validateLimitPriceDeviationRatioFailure(btn, order: o, itemM: itemM, validModel: validModel) {
                            EXAlert.showFail(msg: "cp_content_text12".ex_localized())
                            return false
                        }
                    }
                }
            }else{
                //平仓数量校验 - 只减仓来这里 English: Closing Quantity Verification - Only Reduce Positions Come Here
                //最大值不用校验 只卡最小值 English: Maximum value does not require verification, only card minimum value
                var min = validModel.minOrderVolume
                if min.lessThanOrEqual("0"){
                    return true
                }
                var unit = self.makeOrderViewModel?.volumeUnit ?? ""
                if let iscoin = self.makeOrderViewModel?.isCoin {
                    order?.orderUnit = iscoin ? 2 : 0
                }
                if (order?.qty ?? "0").lessThan(min) { //这里数量都是转为张的 English: The quantity here is all converted to Zhang's
                    if let iscoin = self.makeOrderViewModel?.isCoin, iscoin == true {
                        min = self.makeOrderViewModel?.openOrderCoinMin ?? "0"
                    }
                    let minTip = "order_placement_text7".ex_localized() + " " + min + " " + unit
                    EXAlert.showFail(msg: minTip)
                    return false
                }
                //可平数量校验 English: Levelable quantity verification
                //order?.qty 是转为张的，获取订单可平张数，这里只跟张比 English: Order QTY is converted to Zhang to obtain the number of available flat sheets for the order, which is only compared to Zhang here
                var canClose = self.makeOrderViewModel?.canCloseMoreVolume ?? "0" //可平多 English: Kepingduo
                if btn == self.buyBtn {//买入平空 English: Buy flat
                    canClose = self.makeOrderViewModel?.canCloseShortVolume ?? "0" //可平空 English: Can level the air
                }
                EXLogLine(message: "order?.qty => \(order?.qty), canClose => \(canClose)")
                if (order?.qty ?? "0").greaterThan(canClose) {
                    EXAlert.showFail(msg: "order_placement_text9".ex_localized())
                    return false
                }
            }
        }
        return true
    }
    func hasLogin() -> Bool {
        if (EXSwapPlatformSDK.shared.activeAccount?.token) != nil { // 已经登录 English: already logged
            return true
        }
        
        return false
    }
    
    //MARK: 下单 English: MARK: Placing an Order
    @objc func clickBuyOrSellBtn(_ btn : UIButton){
        if !hasLogin() {
            //弹出登录框 English: Pop up login box
            EXSwapPlatformSDK.shared.loginCallBack?()
            return
        }
        // 开通合约 English: Open contract
        if !SLUserConfig.checkHasOpenContract {
            self.openContractAlert?()
            return
        }
        /*
         双向 开仓做限制，平仓不做限制 English: Two way opening with restrictions, closing without restrictions
         单向 非只减仓 (开发仓做限制) English: Unidirectional non reduction of positions (with restrictions on developing positions)
         Bilateral opening with restrictions, closing without restrictions
         One way not only reducing positions (limited by developing positions)
         */
        
        var needkyclimt:Bool = false
        if onlySellBtn.isHidden == true  { //双向 English: two-way
            if transactionShowType == .showOpen {
                needkyclimt = true //开仓做限制 English: Opening positions with restrictions
            }
        }else{ //单向 English: one-way
            if onlySellBtn.isSelected == false {//非只减仓 English: Not just reducing positions
                needkyclimt = true
            }
        }
        if needkyclimt {
            
            if !currentUserConfig.kycVailatePassed  {
                NotificationCenter.default.post(name: Notification.Name(rawValue: EXContractKycLimitNotification), object: nil)
                return
            }
        }
        
        reloadMakeOrderData()
        
        if !validateInput() {return}
//        if !validateOrder(btn) {return}
        
        //市价单在validateOrder校验过了 English: The market price list has been verified in validateOrder
        //到这里的qty的单位都是张，显示的可平、可开是经过币张换算的。 English: The unit of qty here is Zhang, and the displayed values of Ping and Kai are converted by currency Zhang.
        let order = getOrder(btn: btn)
        if !validateOrder(btn:btn,order:order) {return}
        if order != nil {
            self.clickTradeBlock?(order!)
        }
    }
    //MARK: 市价限价 类型切换 更新高度 English: MARK: Market price limit type switch update height
    fileprivate func updateUI(orderTypeidx: Int = 0) {
        
        if orderTypeidx > priceArr.count - 1 {
            return
        }
        if priceArr[orderTypeidx] == defineOrderType{
            return //相同不用处理 English: Same, no need to handle
        }
        orderTypeBtn.text(content: priceArr[orderTypeidx].display)
        orderTypeBtn.normalStyle()
        resetTextField()
        defineOrderType = priceArr[orderTypeidx]
        updateDepthMaxCountBlock?()
        reloadMakeOrderData()//刷新可用 English: Refresh available
        reloadMarketOrderView()
        reloadLayoutMargin()
        if defineOrderType == .planOrder(isMarket:true){
            //如果是条件单需更新单位 English: If it is a condition sheet, the unit needs to be updated
            updateVolumModule()
        }
        updateVolumeTextFieldTypeBtn()
      
    
    }
    
    func orderWaysModel() -> [EXSBouncedModel] {
        
        var models:[EXSBouncedModel] = []
        
        for type in priceArr {
            let model = EXSBouncedModel()
            model.name = type.display
            if type == .fillOrKill {
                model.name = type.display
            }
            if type == .immediateOrCance {
                model.name = type.display
            }
            var isSelect = self.defineOrderType == type
            if  case .planOrder(_) = type, case .planOrder(_) = self.defineOrderType {
                isSelect = true
            }
            model.selectedColor = isSelect ? UIColor.ThemeView.bgTab : UIColor.ThemeView.alertBg
            model.titleColor = isSelect ? UIColor.ThemeView.highlight : UIColor.ThemeLabel.colorLite
            models.append(model)
        }
        
        return models
    }
    
    func addmask(){
        UIApplication.shared.keyWindow?.addSubview(self.maskBgView)
        //TopVC()?.view.addSubview(self.maskBgView)
        self.maskBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func removeMask(){
        self.maskBgView.removeFromSuperview()
    }
    //MARK:  点击切换委托类型按钮 English: MARK: Click the switch delegation type button
    @objc func clickOrderTypeBtn(sender:UIButton) {
        self.endEditing(true)
        addmask()
        let popover = EXPopover(options: EXPopover.commonTradePopOption, showHandler: nil, dismissHandler: nil)
        popover.popoverColor = UIColor.ThemeView.alertBg
        popover.didDismissHandler = { [weak self] in
            guard let mySelf = self else{return}
            mySelf.orderTypeBtn.normalStyle()
            mySelf.removeMask()
        }
        let models = orderWaysModel()
        let width = self.orderTypeBtn.sg_width
        let view = EXSBouncedView.init(frame: CGRect(x: 0, y: 0, width:width, height: 0))
        view.setData(models,cellHeight: 36)
        view.clickViewIndexBlock = {[weak self] index  in
            popover.dismiss()
            guard let mySelf = self else{return}
            mySelf.updateUI(orderTypeidx: index)
        }
        popover.show(view, fromView: sender)
    }
    
    //MARK:  更新杠杆 English: MARK: Update lever
    func changeLevel(_ level : String){
        
        makeOrderViewModel?.leverage = level
        if defineOrderType == .limited {
            textFieldValueHasChanged(textField: self.priceTextField.input)
        } else if defineOrderType.isHighOrderType() {
            textFieldValueHasChanged(textField: self.priceTextField.input)
        } else {
            textFieldValueHasChanged(textField: self.performTextField.input)
        }
    }
}

extension EXContractMakeOrderView{
    
    private func createTypeBtn(_ title: String ,_ selector : Selector) -> UIButton {
        let btn = UIButton()
        btn.ext_UseAutoLayout()
        btn.ext_SetAddTarget(self, selector)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for:.selected)
        btn.layer.borderWidth = 0.5
        btn.layer.borderColor = UIColor.ThemeView.border.cgColor
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryRegular
        return btn
    }
}
//MARK AttributeString
extension EXContractMakeOrderView {
    func getAvailable(price:String,volume:String) -> NSMutableAttributedString {
        let fullMsg = "cp_overview_text19".ex_localized() + " " + price + " " + volume
        return getAttr(title: "cp_overview_text19".ex_localized(), fullStr: fullMsg)
    }
    
    func getCloseMore(price:String,volume:String) {
        ////平仓 English: Closing position
        if self.transactionShowType == .showClose {
            self.canCloseShortLabel.leftLabel.text = "cp_overview_text17".ex_localized()
            self.canCloseShortLabel.rightLabel.text =  price + " " + volume
        }else{//开仓 English: open a granary to provide relief
            self.canCloseMoreLabel.leftLabel.text = "cp_overview_text17".ex_localized()
            self.canCloseMoreLabel.rightLabel.text =  price + " " + volume
        }
    }
    
    func getCloseEmpty(price:String,volume:String){
        //平仓 / 只减仓 English: Closing/only reducing positions
        if self.transactionShowType == .showClose {
            self.canCloseMoreLabel.leftLabel.text = "cp_overview_text18".ex_localized()
            self.canCloseMoreLabel.rightLabel.text =  price + " " + volume
        }else{ //开仓 English: open a granary to provide relief
            self.canCloseShortLabel.leftLabel.text = "cp_overview_text18".ex_localized()
            self.canCloseShortLabel.rightLabel.text =  price + " " + volume
        }
    }
    
    func getOpenEmpty(price:String,volume:String){
        self.canOpenShortLabel.leftLabel.text = "cp_overview_text37".ex_localized()
        self.canOpenShortLabel.rightLabel.text =  price + " " + volume
    }
    
    func getOpenMore(price:String,volume:String){
        self.canOpenMoreLabel.leftLabel.text = "cp_overview_text46".ex_localized()
        self.canOpenMoreLabel.rightLabel.text = price + " " + volume
    }
    
    func getMayBeCost(cost:String)->NSMutableAttributedString {
        return getAttr(title: "cp_overview_text11".ex_localized(), fullStr: "cp_overview_text11".ex_localized() + " " + cost)
    }
    
    func getAttr(title:String,fullStr:String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ThemeFont.SecondaryRegular,
            .foregroundColor: UIColor.ThemeLabel.colorMedium,
        ]
        
        let attr = NSMutableAttributedString.init(string: fullStr, attributes: attributes)
        let nsString = NSString(string: fullStr)
        let titleRange = nsString.range(of: title)
        attr.addAttribute(.foregroundColor, value: UIColor.ThemeLabel.colorMedium, range:titleRange)
        return attr
    }
}


// MARK: Tracking Event
extension EXContractMakeOrderView {
    
    /// Toggle order type event
    /// - Parameter orderType: order type
   fileprivate func trackingEventByOnToggle(orderType: EXSwapMarketOrderType) {
       switch orderType {
       case .limited:
           EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_switch_order.rawValue, parameters: [EXSwapTrackingEventOrderType.limit_order.rawValue: "1"])
       case .market:
           EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_switch_order.rawValue, parameters: [EXSwapTrackingEventOrderType.market_order.rawValue: "1"])
       default:
           break
       }
    }
    
    /// input trigger order type
    /// - Parameter orderType: order type
   fileprivate func trackingEventByOnInput(orderType: EXSwapMarketOrderType) {
       switch orderType {
       case .limited:
           EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_limit_order_price_input.rawValue)
       case .market:
           EXTracking.shared.track(event: EXSwapTrackingEvent.app_futures_market_order_quantity_input.rawValue)
       default:
           break
       }
    }
    
    /// volume trigger order type
    /// - Parameter orderType: order type
    fileprivate func trackingEventByOnVolume(orderType: EXSwapMarketOrderType, isOnTap: Bool = false) {
        switch orderType {
        case .limited:
            let event: EXSwapTrackingEvent = isOnTap ? .app_futures_limit_order_quantity_slider : .app_futures_limit_order_quantity_input
            EXTracking.shared.track(event: event.rawValue)
        case .market:
            let event: EXSwapTrackingEvent = isOnTap ? .app_futures_market_order_quantity_slider : .app_futures_market_order_quantity_input
            EXTracking.shared.track(event: event.rawValue)
        default:
            break
        }
     }

}

