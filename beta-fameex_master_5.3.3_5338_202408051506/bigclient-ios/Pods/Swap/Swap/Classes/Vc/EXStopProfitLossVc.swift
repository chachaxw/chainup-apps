//
//  SLStopProfitLossVc.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/3/31.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import RxSwift
//import SGPagingView
import YYText
import EXKit
import MapKit


enum EXStopProfitLossPriceType {
    case market
    case limit
}

class EXStopProfitLossVc : EXSNavCustomVC {
    deinit{
        //print("-EXStopProfitLossVc---")
    }
    var updateRateCountdownTimer:Timer?
    typealias ClickStopProfitLoss = (Bool) -> ()
    var clickStopProfitLoss : ClickStopProfitLoss?
    var currentPriceType:EXStopProfitLossPriceType = .market
    var positionModel : EXSwapPositionModel? {
        didSet {
            px_unit = positionModel?.ex_contractInfo?.quote_coin ?? "-"
            marginCoin = positionModel?.ex_contractInfo?.marginCoin ?? "-"
            infoVaild.decail = positionModel?.ex_contractInfo?.px_unit ?? "0.01"
            volumeValid.decail = positionModel?.ex_contractInfo?.volumeDecial ?? "0.01"
            setHeaderContent()
            guard let pModel = positionModel else {
                return
            }
            var color = UIColor.ThemekLine.down
            if pModel.side == .openMore {
                color = UIColor.ThemekLine.up
            }
            dealTypeLabel.textColor = color
            dealTypeLabel.text = pModel.side.introduce
            nameLabel.text = pModel.ex_contractInfo?.showName() ?? ""
            
            contractTypeLabel.text = pModel.position_type.introduce + "\(pModel.leverageLevel)X"
            canCloseLabel.attributedText = getCloseMore(price: pModel.canCloseVolumeDisplay, volume: pModel.ex_contractInfo?.volumeUnit ?? "")
            volumeTextField.maxValue = positionModel?.canCloseVolumeDisplay ?? "0"//最大值 English: Maximum value
            volumeTextField.decimal = String(volumeValid.limetValue)
            volumeTextField.input.text = positionModel?.canCloseVolumeDisplay
            volumeTextField.fullSelect()
            if EXStoreData.storeBool(forKey: EXS_UNIT_VOL) {
                volumeTextField.input.keyboardType = UIKeyboardType.decimalPad
            } else {
                volumeTextField.input.keyboardType = UIKeyboardType.numberPad
            }
        }
    }
    var stopProfitList = [EXContractOrderModel]()
    var stopLossList = [EXContractOrderModel]()
    var px_unit : String = "-"
    var marginCoin:String = ""
    var lastPrice = "--"
    var submitCount = 0
    var pxTypeStr = ""
    
    override func setNavCustomV() {
        self.setTitle("cp_overview_text12".ex_localized())
        self.navtype = .normal
        self.navCustomView.backgroundColor = UIColor.ThemeView.newbg
    }
    
    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubView()
        setInfoVaildDelegate()
        setupUnitLabel()
        self.requestProfitOrLossOrder()
//        //     先调一次,限价，布局撑开 然后再切换为默认的市价 English: First adjust once, limit the price, expand the layout, and then switch to the default market price
        clickLimitBtn()
        clickMarketBtn()
        addQuestionBtn()
        bindTipLabel()
        addSubcrbe()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateRateCountdownTimer?.invalidate()
        updateRateCountdownTimer = nil
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let hasTiped = EXStoreData.storeBool(forKey: contract_stopLossAndProfit_firstTiped)
        if hasTiped{
            return
        }
        questionBtn.sendActions(for: .touchUpInside)
        EXStoreData.setStoreObjectAndKey(true, key: contract_stopLossAndProfit_firstTiped)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBtnContaner.exs_roundCorners(corners: [.topLeft,.topRight], radius: 15)
    }
    
   
    
    
    //MARK: lazy
    
    
   let infoVaild:EXSInputLimitDelegate = EXSInputLimitDelegate()
   let volumeValid : EXSInputLimitDelegate = EXSInputLimitDelegate()
   lazy var container:UIStackView = {
       let stacker :UIStackView = UIStackView.init()
       stacker.axis = .vertical
       stacker.distribution = .fill
       stacker.backgroundColor = UIColor.ThemeView.card1
       return stacker
   }()
   /// 触发价格 English: /Trigger price
   lazy var tiggerType: UILabel = {
       let text = "cp_extra_text174".ex_localized()
       let label = UILabel(text: text, font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeLabel.colorMedium, alignment: .left)
       label.isHidden = true
       return label
   }()
   
   var profitPlaceholdView = UIView()
   var lossPlaceholdView = UIView()
    
    lazy var scrollView:UIScrollView = {
        let v = UIScrollView()
        v.contentSize = CGSize.init(width: EXSCREEN_WIDTH, height: EXS_SCREEN_HEIGHT-EX_NAV_SCREEN_HEIGHT)
        v.delegate = self
        return v
    }()
    
   /// ///============头部 English: /============Head
   let topView = UIView()
   /// 多 空 类型nav English: /Multi empty type nav
   lazy var dealTypeLabel: UILabel = {
       let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadMedium, textColor: nil, alignment: NSTextAlignment.left)
       label.ext_UseAutoLayout()
       return label
   }()
   /// 合约名称 English: /Contract Name
   lazy var nameLabel: UILabel = {
       let label = UILabel(text: nil, font: UIFont.ThemeFont.HeadBold, textColor: UIColor.ThemeLabel.colorLite, alignment: NSTextAlignment.left)
       label.ext_UseAutoLayout()
       return label
   }()
   /// 全仓逐仓类型 English: /Full warehouse by warehouse type
   lazy var contractTypeLabel: UILabel = {
       let label = UILabel(text: nil, font: UIFont.ThemeFont.MinimumRegular, textColor: UIColor.ThemeLabel.colorHighlight, alignment: NSTextAlignment.center)
       label.ext_UseAutoLayout()
       label.backgroundColor =  UIColor.Ex.main3//UIColor.ThemeLabel.colorHighlight.withAlphaComponent(0.15)
       label.layer.cornerRadius = 2
       label.layer.masksToBounds = true
       return label
   }()
   ///右侧问号 English: /Right question mark
   let questionBtn = UIButton(type: .custom)
   private lazy var headerView: EXCOThreeColumnView = {
       let retV = EXCOThreeColumnView()
       retV.backgroundColor = UIColor.ThemeView.newbg
       retV.leftbgView.backgroundColor = UIColor.ThemeView.newbg
       retV.middleBgView.backgroundColor = UIColor.ThemeView.newbg
       retV.rightBgView.backgroundColor = UIColor.ThemeView.newbg
       return retV
   }()
   ///============
   ///
   ///圆角处理 English: /Rounding treatment
   let topBtnContaner = UIView()
   //止盈 English: Stop surplus
   lazy var openProfitBtn : EXSButton = {
       let btn = EXSButton()
       btn.setTitle(String(format:" %@","cp_stoporder_text1".ex_localized()), for: .normal)
       btn.clearColors()
//        btn.setFont(UIFont.ThemeFont.SecondaryBold)
       btn.titleLabel?.font = UIFont.ThemeFont.SecondaryBold
       btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
       btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_uncheck"), for: .normal)
       btn.setImage(UIImage.svg_themeImageNamed(imageName: "public_icon_check_mark"), for: .selected)
       btn.addTarget(self, action: #selector(openProfitOrLoss(sender:)), for: .touchUpInside)
       btn.isSelected = true
       return btn
   }()
   //止损 English: Stop loss
   lazy var openLossBtn : EXSButton = {
       let btn = EXSButton()
       btn.clearColors()
       btn.setTitle(String(format:" %@","cp_stoporder_text2".ex_localized()), for: .normal)
//        btn.setFont(UIFont.ThemeFont.SecondaryBold)
       btn.titleLabel?.font = UIFont.ThemeFont.SecondaryBold
       btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
       btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_uncheck"), for: .normal)
       btn.setImage(UIImage.svg_themeImageNamed(imageName: "public_icon_check_mark"), for: .selected)
       btn.addTarget(self, action: #selector(openProfitOrLoss(sender:)), for: .touchUpInside)
       btn.isSelected = true
       return btn
   }()
   
   /// 止盈触发价格 English: /Stop profit trigger price
   lazy var profitTiggerInput: EXSBorderField = {
       let textField = EXSBorderField()
       textField.titleTop = true
       textField.ext_UseAutoLayout()
       textField.input.textColor = UIColor.ThemeLabel.colorLite
       textField.unitLabel.textColor = UIColor.ThemeLabel.colorLite
       textField.bgView.layer.cornerRadius = 4
       textField.maxLenth = 9
       textField.setPlaceHolder(placeHolder: "cp_content_text31".ex_localized())
       textField.leftLabel.text = "cp_overview_text15".ex_localized()
       textField.textfieldValueChangeBlock = {[weak self]str in
           guard let mySelf = self else{return}
           mySelf.textFieldValueHasChanged(textField: mySelf.profitTiggerInput.input)
       }
       textField.input.keyboardType = UIKeyboardType.decimalPad
       textField.bgView.backgroundColor = UIColor.ThemeView.card2
       return textField
   }()
   
   /// 止盈执行价格 English: /Stop profit execution price
   lazy var profitExcutiveInput: EXSBorderField = {
       let textField = EXSBorderField()
       textField.titleTop = true
       textField.ext_UseAutoLayout()
       textField.bgView.layer.cornerRadius = 4
       textField.input.textColor = UIColor.ThemeLabel.colorLite
       textField.unitLabel.textColor = UIColor.ThemeLabel.colorLite
       textField.setPlaceHolder(placeHolder: "cp_content_text31".ex_localized())
       textField.leftLabel.text = "cp_order_text36".ex_localized()
       textField.textfieldValueChangeBlock = {[weak self]str in
           guard let mySelf = self else{return}
           mySelf.textFieldValueHasChanged(textField: mySelf.profitExcutiveInput.input)
       }
       textField.maxLenth = 9
       textField.input.keyboardType = UIKeyboardType.decimalPad
       
       textField.textfieldDidBeginBlock = { [weak self] in
           guard let newSelf = self else{
               return
           }
           newSelf.profitExcutiveInput.input.text = ""
           newSelf.profitMarketPerformBtn.isSelected = false
       }
       textField.bgView.backgroundColor = UIColor.ThemeView.card2
       return textField
   }()
   lazy var profitTipLabelView:UIView = {
       let retView = UIView()
       
       retView.addSubview(profitTipLabel)
       profitTipLabel.snp.makeConstraints { (make) in
           make.leading.equalToSuperview()
           make.top.equalTo(4)
       }
       return retView
   }()
   lazy var profitTipLabel:UILabel = {
       
       let label = UILabel(text: "".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemekLine.up, alignment: .left)
       
       return label
   }()
   /// 可平 English: /Keping
   lazy var canCloseLabel : UILabel = {
       let label = UILabel()
       label.ext_UseAutoLayout()
       label.textColor = UIColor.ThemeLabel.colorMedium
       label.font = UIFont.ThemeFont.SecondaryRegular
       label.attributedText = self.getCloseMore(price: "-", volume: "-")
       return label
   }()
   
   lazy var lossTipLabelView:UIView = {
       
       let v = UIView()
       v.addSubview(lossTipLabel)
       lossTipLabel.snp.makeConstraints { (make) in
           make.leading.equalToSuperview()
           make.top.equalTo(4)
       }
       return v
   }()
   
   lazy var lossTipLabel:UILabel = {
       
       let label = UILabel(text: "".ex_localized(), font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemekLine.down, alignment: .left)
       
       return label
   }()
   
   
   lazy var profitMessage :UILabel = {
       
       let lable = UILabel()
       lable.font = UIFont.ThemeFont.SecondaryRegular
       lable.textColor = UIColor.ThemeState.warning
       return lable
       
   }()
   
   
   //    lazy var profitMarketLabel : UILabel = {
   //        let marketLabel = UILabel.init(text: "cp_overview_text53".ex_localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorHighlight, alignment: .right)
   //            marketLabel.adjustsFontSizeToFitWidth = true
   //        return marketLabel
   //    }()
   
   //    lazy var profitMarketCover : UILabel = {
   //        let marketCover = UILabel.init(text: "cp_overview_text53".ex_localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
   //        marketCover.backgroundColor = UIColor.ThemeView.bg
   //        marketCover.isHidden = true
   //        return marketCover
   //    }()
   
   
   /// 止损触发价格 English: /Stop loss trigger price
   lazy var lossTiggerInput: EXSBorderField = {
       let textField = EXSBorderField()
       textField.titleTop = true
       textField.ext_UseAutoLayout()
       textField.input.textColor = UIColor.ThemeLabel.colorLite
       textField.unitLabel.textColor = UIColor.ThemeLabel.colorLite
       textField.maxLenth = 9
       textField.bgView.layer.cornerRadius = 4
       textField.setPlaceHolder(placeHolder: "cp_content_text31".ex_localized())
       textField.leftLabel.text = "cp_overview_text16".ex_localized()
       textField.textfieldValueChangeBlock = {[weak self]str in
           guard let mySelf = self else{return}
           mySelf.textFieldValueHasChanged(textField: mySelf.lossTiggerInput.input)
       }
       textField.input.keyboardType = UIKeyboardType.decimalPad
       textField.bgView.backgroundColor = UIColor.ThemeView.card2
       return textField
   }()
   
   /// 止损执行价格 English: /Stop loss execution price
   lazy var lossExcutiveInput: EXSBorderField = {
       let textField = EXSBorderField()
       textField.titleTop = true
       textField.input.leftViewMode = .always
       textField.ext_UseAutoLayout()
       textField.input.textColor = UIColor.ThemeLabel.colorLite
       textField.unitLabel.textColor = UIColor.ThemeLabel.colorLite
       textField.setPlaceHolder(placeHolder: "cp_content_text31".ex_localized())
       textField.bgView.layer.cornerRadius = 4
       textField.textfieldDidBeginBlock = {[weak self] in
           self?.lossExcutiveInput.input.text = ""
       }
       textField.leftLabel.text = "cp_order_text37".ex_localized()
       textField.textfieldValueChangeBlock = {[weak self]str in
           guard let mySelf = self else{return}
           mySelf.textFieldValueHasChanged(textField: mySelf.lossExcutiveInput.input)
       }
       textField.maxLenth = 9
       textField.input.keyboardType = UIKeyboardType.decimalPad
       textField.bgView.backgroundColor = UIColor.ThemeView.card2
      
       return textField
   }()
   
   /// 执行市价 English: /Execute market price
   lazy var lossMarketPerformBtn : UIButton = {
       let btn = UIButton(buttonType: .custom, title: "cp_overview_text53".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorLite)
       btn.ext_UseAutoLayout()
       btn.ext_SetAddTarget(self, #selector(clickLimitBtn))
       btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .selected)
       btn.ext_setBackgroundColor(backgroundColor: UIColor.ThemeView.card2, state: .normal)
       return btn
   }()
   /// 执行市价 English: /Execute market price
   lazy var profitMarketPerformBtn : UIButton = {
       let btn = UIButton(buttonType: .custom, title: "cp_overview_text53".ex_localized(), titleFont: UIFont.ThemeFont.BodyRegular, titleColor: UIColor.ThemeLabel.colorLite)
       btn.ext_UseAutoLayout()
       btn.ext_SetAddTarget(self, #selector(clickMarketBtn))
       btn.setTitleColor(UIColor.ThemeLabel.colorHighlight, for: .selected)
       btn.ext_setBackgroundColor(backgroundColor:  UIColor.ThemeView.card2, state: .normal)
       return btn
   }()
   //    lazy var lossMarketLabel : UILabel = {
   //        let marketLabel = UILabel.init(text: "cp_overview_text53".ex_localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorHighlight, alignment: .right)
   //           marketLabel.adjustsFontSizeToFitWidth = true
   //        return marketLabel
   //    }()
   
   //    lazy var lossMarketCover : UILabel = {
   //        let marketCover = UILabel.init(text: "cp_overview_text53".ex_localized(), font: UIFont.ThemeFont.BodyRegular, textColor: UIColor.ThemeLabel.colorLite, alignment: .left)
   //        marketCover.backgroundColor = UIColor.ThemeView.bg
   //        marketCover.isHidden = true
   //        return marketCover
   //    }()
   
   /// 提示 English: /Prompt
   lazy var tipsLabel: UILabel = {
       
       let label = UILabel(text: "", font: UIFont.ThemeFont.SecondaryRegular, textColor: UIColor.ThemeState.warning, alignment: .left)
       
       return label
   }()
   
   //数量输入框 English: Quantity input box
   lazy var volumeTextField : EXSPersentageField = {
       let textfield = EXSPersentageField()
       textfield.backgroundColor = UIColor.ThemeView.card1
       textfield.input.keyboardType = UIKeyboardType.decimalPad
       textfield.titlable.text =  "cp_overview_text8".ex_localized()
       textfield.setPlaceHolder(placeHolder: "cp_overview_text8".ex_localized())
       textfield.textfieldValueChangeBlock = {[weak self] persent in
           guard let mySelf = self else{return}
           mySelf.volumeTextField.input.text = persent
           mySelf.textFieldValueHasChanged(textField: mySelf.volumeTextField.input )
       }
       
       return textfield
   }()
   /// 确认 English: /Confirm
   lazy var confirmButton: EXSButton = {
       let button = EXSButton()
       button.setTitle("cp_calculator_text16".ex_localized(), for: .normal)
       button.addTarget(self, action: #selector(clickConfirmButton), for: .touchUpInside)
       button.setTitleColor(.white, for: .normal)
       button.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .disabled)
       return button
   }()
   
   // 止盈止损市价 右侧按钮 English: Stop profit and stop loss market price right button
   lazy var priceTypeBtn : EXSDirectionButton = {
       let btn = EXSDirectionButton()
       btn.ext_UseAutoLayout()
       btn.container.backgroundColor = UIColor.ThemeView.card1
       btn.titleLabel.font = UIFont.ThemeFont.SecondaryRegular
       btn.titleLabel.textColor = UIColor.ThemeLabel.colorMedium
//       btn.addTarget(self, action: #selector(clickPriceTypeBtn(sender:)), for: .touchUpInside)
       btn.rx.controlEvent(.touchUpInside).subscribe { [weak self] (_) in
           self?.clickPriceTypeBtn(sender: btn)
       }.disposed(by: self.exs_disposeBag)
       return btn
   }()
   
   lazy var revokeAllStopProfitOrderButton: EXSButton = {
       let button = EXSButton()
       button.setFont((UIFont.ThemeFont.BodyBold))
       button.setTitle("cp_extra_text176".ex_localized(), for: .normal)
       button.addTarget(self, action: #selector(clickRevokeAllStopProfitOrderButton), for: .touchUpInside)
       button.isHidden = true
       return button
   }()
   
   lazy var revokeAllStopLossOrderButton: EXSButton = {
       let button = EXSButton()
       button.setFont((UIFont.ThemeFont.BodyBold))
       button.setTitle("cp_extra_text177".ex_localized(), for: .normal)
       button.addTarget(self, action: #selector(clickRevokeAllStopLossOrderButton), for: .touchUpInside)
       button.isHidden = true
       return button
   }()
   
    
   let bottomBtnView = UIView()
}

//MARK: Requset
extension EXStopProfitLossVc {
    private func requestProfitOrLossOrder() {
        EXContractNetwork.queryProfitAndLossList(id: self.positionModel?.instrument_id ?? 0, orderSide: self.positionModel?.orderSide ?? "") {[weak self] model in
            
            guard let mySelf = self else {return}
            mySelf.stopProfitList = model.takeProfitList
            mySelf.stopLossList = model.stopLossList
                
            mySelf.revokeAllStopLossOrderButton.isHidden =  !(model.stopLossList.count > 0)
            mySelf.revokeAllStopLossOrderButton.setTitle(" " + "cp_extra_text177".ex_localized() + "：\(model.stopLossList.count)" + " ", for: .normal)
            
            mySelf.revokeAllStopProfitOrderButton.isHidden = !(model.takeProfitList.count > 0)
            mySelf.revokeAllStopProfitOrderButton.setTitle(" " + "cp_extra_text176".ex_localized() + "：\(model.takeProfitList.count)" + " ", for: .normal)
            
            mySelf.reloadVcData()

        } failure: { (_) in
            
        }
    }
}
//MARK: 市价点击 English: MARK: Market price click
extension EXStopProfitLossVc{
    @objc func clickPriceTypeBtn(sender:UIControl) {
        self.view.endEditing(true)
        
        let popover = EXPopover(options: EXPopover.commonTradePopOption, showHandler: nil, dismissHandler: nil)
        popover.popoverColor = UIColor.ThemeView.alertBg
        let models = orderWaysModel()
        let view = EXSBouncedView.init(frame: CGRect(x: 0, y: 0, width:130, height: CGFloat(models.count * 36)))
        view.setData(models,cellHeight: 36)
        view.clickViewIndexBlock = {[weak self] index  in
            popover.dismiss()
            
            guard let mySelf = self else{return}
            mySelf.priceTypeBtn.normalStyle()
            if index == 0 {
                
                mySelf.clickMarketBtn()
            }else {
                mySelf.clickLimitBtn()
            }
            mySelf.resetTextfield()
        }
        popover.show(view, fromView: sender)
    }
}
//MARK: function
extension EXStopProfitLossVc{
    func setInfoVaildDelegate() {
        profitTiggerInput.input.delegate = infoVaild
        profitExcutiveInput.input.delegate = infoVaild
        lossTiggerInput.input.delegate = infoVaild
        lossExcutiveInput.input.delegate = infoVaild
        volumeTextField.input.delegate = volumeValid
    }
    func resetTextfield() {
        profitTiggerInput.input.text = ""
        profitExcutiveInput.input.text = ""
        lossTiggerInput.input.text = ""
        lossExcutiveInput.input.text = ""
        profitTipLabel.text = ""
        lossTipLabel.text = ""
    }
    fileprivate func setupUnitLabel() {
        profitTiggerInput.unitLabel.text = positionModel?.ex_contractInfo?.quote_coin
        profitExcutiveInput.unitLabel.text = positionModel?.ex_contractInfo?.quote_coin
        volumeTextField.symbolLabel.text = positionModel?.ex_contractInfo?.volumeUnit
        lossTiggerInput.unitLabel.text = positionModel?.ex_contractInfo?.quote_coin
        lossExcutiveInput.unitLabel.text = positionModel?.ex_contractInfo?.quote_coin
    }
    
    func orderWaysModel() -> [EXSBouncedModel] {
        
        var models:[EXSBouncedModel] = []
        
        let model = EXSBouncedModel()
        model.name = "cp_overview_text53".ex_localized()
        model.selectedColor = (currentPriceType == .market) ? UIColor.ThemeView.bgTab : UIColor.ThemeView.newbg
        model.titleColor = (currentPriceType == .market) ? UIColor.ThemeView.highlight : UIColor.ThemeLabel.colorLite
        model.bgColor = (currentPriceType == .market) ? UIColor.ThemeView.bgIconh : UIColor.ThemeView.newbg
        models.append(model)
        
        let model1 = EXSBouncedModel()
        model1.name = "cp_overview_text54".ex_localized()
        model1.selectedColor = (currentPriceType == .limit) ? UIColor.ThemeView.bgTab : UIColor.ThemeView.newbg
        model1.titleColor = (currentPriceType == .limit) ? UIColor.ThemeView.highlight : UIColor.ThemeLabel.colorLite
        model1.bgColor = (currentPriceType == .limit) ? UIColor.ThemeView.bgIconh : UIColor.ThemeView.newbg
        
        models.append(model1)
        return models
    }
    
    
    func textFieldValueHasChanged(textField:UITextField) {
        
        var tipPrefix = "cp_extra_text95".ex_localized() + ":"
        var color = UIColor.ThemekLine.down
        if stopLossOrderProfit().greaterThan("0") {
            color = UIColor.ThemekLine.up
            tipPrefix = "cp_order_text38".ex_localized() + ":"
        }
        var showLoss = false
        var showPro = false
        
        if currentPriceType == .market {
            showLoss = lossTiggerInput.input.text?.count ?? 0 > 0
            showPro = profitTiggerInput.input.text?.count ?? 0 > 0
        }else{
            showLoss = lossExcutiveInput.input.text?.count ?? 0 > 0
            showPro = profitExcutiveInput.input.text?.count ?? 0 > 0
            
        }
       
        if showLoss {
            lossTipLabel.text = tipPrefix + stopLossOrderProfit() + marginCoin
            lossTipLabel.textColor = color
        }
        
        color = UIColor.ThemekLine.down
        if stopProfitOrderProfit().greaterThan("0") {
            color = UIColor.ThemekLine.up
            tipPrefix = "cp_order_text38".ex_localized() +  ":"
        }
        if showPro {
            profitTipLabel.text = tipPrefix + stopProfitOrderProfit() + marginCoin
            profitTipLabel.textColor = color
        }
    }
    
    func relaodMessage(messageLabel:UILabel,price:String)  {
        
        let message = price == "" ? "" : String(format: "cp_extra_text178".ex_localized(), price)
        messageLabel.text = message
    }
    func stopLossOrderProfit() -> String {
        
        var closePx = lossExcutiveInput.input.text ?? "0"
        if currentPriceType == .market {
            closePx = lossTiggerInput.input.text ?? "0"
        }
        let openPx = positionModel?.avg_open_px ?? "0"
        
        return calculatePorfit(excutivePx: closePx, openPx: openPx)
    }
    
    func stopProfitOrderProfit() -> String {
        var closePx = profitExcutiveInput.input.text ?? "0"
        if currentPriceType == .market {
            closePx = profitTiggerInput.input.text ?? "0"
        }
        let openPx = positionModel?.avg_open_px ?? "0"
        return calculatePorfit(excutivePx: closePx, openPx: openPx)
    }
    
}
//MARK: UI
extension EXStopProfitLossVc {
    
    private func configSubView() {
        //底部部分 可开和按钮 English: The bottom part can be opened and buttons
        bottomBtnView.backgroundColor = UIColor.ThemeView.card1
        bottomBtnView.addSubview(canCloseLabel)
        bottomBtnView.addSubview(confirmButton)
        canCloseLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().offset(16)
            make.height.equalTo(16)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(canCloseLabel.snp.bottom).offset(8)
            make.height.equalTo(44)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-32)
        }
        self.navCustomView.backgroundColor = UIColor.ThemeView.newbg
        self.contentView.backgroundColor = UIColor.ThemeView.newbg
        self.contentView.addSubview(scrollView)
        self.contentView.addSubview(bottomBtnView)
        self.scrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        bottomBtnView.backgroundColor = UIColor.ThemeView.card1
        bottomBtnView.snp.makeConstraints { make in
            make.top.equalTo(self.scrollView.snp.bottom)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(44+8+16+32)
        }
        scrollView.backgroundColor = UIColor.ThemeView.card1
        scrollView.addSubview(topView)
        scrollView.addSubview(topBtnContaner)
        scrollView.addSubview(container)
        topView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(120)
        }
        topBtnContaner.backgroundColor = UIColor.ThemeView.card1
        topBtnContaner.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(-20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(34)
        }
        container.snp.makeConstraints { (make) in
            make.top.equalTo(topBtnContaner.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(Device_W - 30)
            make.bottom.lessThanOrEqualToSuperview()
            // make.bottom.equalToSuperview()
        }
        //顶部的view English: Top view
        topView.backgroundColor = UIColor.ThemeView.newbg
        topView.addSubViews([
            dealTypeLabel,nameLabel,contractTypeLabel,questionBtn,
            headerView
        ])
        dealTypeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(22)
            make.height.equalTo(20)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealTypeLabel.snp.right).offset(5)
            make.height.equalTo(20)
            make.centerY.equalTo(dealTypeLabel)
        }
        contractTypeLabel.snp.makeConstraints { (make) in
            make.height.equalTo(18)
            make.width.equalTo(50)
            make.centerY.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(4)
        }
        contractTypeLabel.titleResizeSize()
        questionBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview() //.offset(-16)
            make.size.equalTo(CGSize(width: 46, height: 46))
            make.centerY.equalTo(dealTypeLabel)
        }
        
        headerView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.trailing.equalTo(-15)
            make.height.greaterThanOrEqualTo(40)
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
        }
        
        //顶部的止盈 止损 价格类型 English: Top stop loss price type
        topBtnContaner.addSubViews([openProfitBtn,openLossBtn,priceTypeBtn])
        openLossBtn.sizeToFit()
        openProfitBtn.sizeToFit()
        openProfitBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(18)
        }
        openLossBtn.snp.makeConstraints { (make) in
            make.top.equalTo(openProfitBtn)
            make.left.equalTo(openProfitBtn.snp.right).offset(20)
            make.height.equalTo(18)
        }
        priceTypeBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(openProfitBtn)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(18)
            make.width.equalTo(68)
        }
        
        //底部数量输入按钮顶部间距 English: Bottom quantity input button top spacing
        let volumeTopMargin = UIView()
        let volumeBottomMargin = UIView()
       
        //        scContainer.exs_addSubViews([topView,canCloseLabel,confirmButton,container])
        container.addArrangedSubview(profitTiggerInput)
        container.addArrangedSubview(profitPlaceholdView)
        container.addArrangedSubview(profitExcutiveInput)
        container.addArrangedSubview(profitTipLabelView)
        container.addArrangedSubview(lossTiggerInput)
        container.addArrangedSubview(lossPlaceholdView)
        container.addArrangedSubview(lossExcutiveInput)
        container.addArrangedSubview(lossTipLabelView)
        container.addArrangedSubview(volumeTopMargin)
        container.addArrangedSubview(volumeTextField)
        container.addArrangedSubview(volumeBottomMargin)
        profitTipLabelView.snp.makeConstraints { (make) in
            make.height.equalTo(31)
        }
        lossTipLabelView.snp.makeConstraints { (make) in
            make.height.equalTo(31)
        }
        profitTiggerInput.snp.makeConstraints { (make) in
            make.height.equalTo(66)
        }
        profitExcutiveInput.snp.makeConstraints { (make) in
            make.height.equalTo(66)
        }
        profitPlaceholdView.snp.makeConstraints { (make) in
            make.height.equalTo(10)
        }
        lossPlaceholdView.snp.makeConstraints { (make) in
            make.height.equalTo(10)
        }
        lossTiggerInput.snp.makeConstraints { (make) in
            make.height.equalTo(66)
        }
        lossExcutiveInput.snp.makeConstraints { (make) in
            make.height.equalTo(66)
        }
//        volumeTopMargin.snp.makeConstraints { make in
//            make.height.equalTo(16)
//        }
        volumeTextField.snp.makeConstraints { (make) in
            make.height.equalTo(100)
        }
        volumeBottomMargin.snp.makeConstraints { make in
            make.height.equalTo(16)
        }
    }
    
    func addQuestionBtn(){
        questionBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_instructions"), for: .normal)
        questionBtn.rx.tap.subscribe(onNext: { (_) in
            EXNewTracking.shared.trackPage(name: .stopPLInfo, isEnter:true)
            let alert = EXStoplossAlert()
            alert.title = "cp_tip_text15".ex_localized()
            alert.dataList = AlertInfo.getStopPLInfo()
            EXAlert.showAlert(alertView: alert)
        }).disposed(by: self.exs_disposeBag)
    }
    
}

//MARK: 价格更新 English: MARK: Price update
extension EXStopProfitLossVc{
    func addSubcrbe(){
        //资金费率 - English: Fund rate-
        updateRateCountdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {  [weak self] _ in
            guard let newSelf = self else{
                return
            }
            if newSelf.positionModel == nil{
                return
            }
            newSelf.updatePrice()
        })
        RunLoop.main.add(updateRateCountdownTimer!, forMode: RunLoop.Mode.common)
        updateRateCountdownTimer?.fire()
        
        
    }
    
    //MARK: 更新指数价格 和 仓位价格 English: MARK: Update index prices and position prices
    func updatePrice(){
        EXContractNetwork.getPriceList { [weak self] priceList in
            for item in priceList {
                //更新标记价格 English: Update marked prices
                if item.icon == self?.positionModel?.ex_contractInfo?.contractName{
                    if let pm = item.priceModel{
                        self?.lastPrice = pm.lastPrice
                    }
                    self?.setHeaderContent()
                    break
                }
            }
        } failure: { (_) in
        }.disposed(by: self.exs_disposeBag)
        
    }
}
//MARK: 头部处理 English: MARK: Head processing
extension EXStopProfitLossVc{
    func setHeaderContent() {
        let models = generateHeaderModel()
        headerView.bindItems(with: models)
        headerView.titleMiddle.textAlignment = .center
        headerView.bottomMiddle.textAlignment = .center
    }
    
    func generateHeaderModel() -> [EXCOThreeColumnDataModel] {
        var retV = [EXCOThreeColumnDataModel]()
        guard let pModel = positionModel else {
            return retV
        }
        let modell = EXCOThreeColumnDataModel()
        modell.title = "cp_order_text7".ex_localized()
        
        modell.content = pModel.avg_open_px.toPricePrecision(withContractID: pModel.instrument_id)
        modell.style = getCustomStyle()
        retV.append(modell)
        
        let modelm = EXCOThreeColumnDataModel()
        modelm.title = "cp_order_text31".ex_localized()

        modelm.content = lastPrice.toPricePrecision(withContractID: positionModel?.instrument_id ?? 0)
        modelm.style = getCustomStyle()
        retV.append(modelm)
        
        let modelr = EXCOThreeColumnDataModel()
        modelr.content = positionModel?.reducePrice == "--" ? "--" :  positionModel?.reducePrice.toPricePrecision(withContractID: positionModel?.instrument_id ?? 0) ?? "0"
        modelr.title = "cp_calculator_text4".ex_localized()
        modelr.style = getCustomStyle()
        retV.append(modelr)
        return retV
    }
    
    func getCommonStyle() -> EXCOThreeColumnStyle {
        let style = EXCOThreeColumnStyle()
        style.topLabelColor = UIColor.ThemeLabel.colorMedium
        style.topLabelFont = self.themeHNFont(size: 12)
        style.bottomLabelFont = self.themeHNFont(size: 14)
        style.bottomLabelColor = UIColor.ThemeLabel.colorLite
        return style
    }
    
    func getCustomStyle(
        topColor: UIColor = UIColor.ThemeLabel.colorMedium,
        topFont: UIFont = UIFont.ThemeFont.MinimumRegular,
        bottomColor: UIColor = UIColor.ThemeLabel.colorLite,
        bottomFont: UIFont = UIFont.ThemeFont.BodyRegular) -> EXCOThreeColumnStyle {
        let style = EXCOThreeColumnStyle()
        style.topLabelColor = topColor
        style.topLabelFont = topFont
        style.bottomLabelFont = bottomFont
        style.bottomLabelColor = bottomColor
        return style
    }
}
//MARK: lazy rx 事件监听 English: MARK: Lazy Rx event listening
extension EXStopProfitLossVc{
    func bindTipLabel() {
        let validP1 = profitTiggerInput.input.rx.text.orEmpty
        let validP2 = profitExcutiveInput.input.rx.text.orEmpty
        let validV = volumeTextField.input.rx.text.orEmpty
        Observable.combineLatest(validP1, validP2,validV).map {[weak self] (tuple) -> String? in
            let firstIsEmpty = tuple.0.isEmpty
            let otherIsEmpty = tuple.1.isEmpty && tuple.2.isEmpty
            guard let newSelf = self else {return ""}
            if newSelf.currentPriceType == .market && firstIsEmpty {
                return ""
            }
            if  firstIsEmpty && otherIsEmpty {
                return ""
            }
            return newSelf.profitTipLabel.text
        }.bind(to: profitTipLabel.rx.text).disposed(by: self.exs_disposeBag)
        
        let validL1 = lossTiggerInput.input.rx.text.orEmpty
        let validL2 = lossExcutiveInput.input.rx.text.orEmpty
        Observable.combineLatest(validL1, validL2,validV).map { [weak self] (tuple) -> String? in
            let firstIsEmpty = tuple.0.isEmpty
            let otherIsEmpty = tuple.1.isEmpty && tuple.2.isEmpty
            guard let newSelf = self else {return ""}
            if newSelf.currentPriceType == .market && firstIsEmpty {
                return ""
            }
            if  firstIsEmpty && otherIsEmpty {
                return ""
            }
            return newSelf.lossTipLabel.text
        }.bind(to: lossTipLabel.rx.text).disposed(by: self.exs_disposeBag)
    }
    //MARK: lazy 按钮是否可用 English: MARK: Is the lazy button available
    func bindBtnEnable(){
        var inputsAry:[Observable<String>] = []
        //类型一致的加一起 English: Add up of consistent types
        let allInputs = [profitTiggerInput,profitExcutiveInput,lossTiggerInput,lossExcutiveInput]
        for inputItem in allInputs {
            if inputItem.isHidden == false{
                let rxInputs = inputItem.input.rx.text.orEmpty.asObservable()
                inputsAry.append(rxInputs)
            }
        }
        //数量 English: quantity
        let vol = volumeTextField.input.rx.text.orEmpty.asObservable()
        inputsAry.append(vol)
        Observable.combineLatest(inputsAry)
            .distinctUntilChanged()
            .map({ strary in
                var count = 0
                for str in strary {
                    if str.count > 0 {
                        count += 1
                    }
                }
                return (count == inputsAry.count)
            })
            .bind(to:self.confirmButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}
extension EXStopProfitLossVc {
    
    private func reloadVcData() {
//        if self.stopProfitOrder != nil {
//            openProfitOrLoss(sender: self.openProfitBtn)
//        }
//        if self.stopLossOrder != nil {
//            openProfitOrLoss(sender: self.openLossBtn)
//        }
//        if tiggerIndex == BTContractOrderPriceType.tradePriceType {
//            tiggerPriceTapAction(sender: lastPriceBtn)
//        } else if tiggerIndex == BTContractOrderPriceType.markPriceType {
//            tiggerPriceTapAction(sender: fairPriceBtn)
//        } else if tiggerIndex == BTContractOrderPriceType.indexPriceType {
//            tiggerPriceTapAction(sender: indexPriceBtn)
//        }
    }
    
   
   
    func configProfitView() {
        //触发价 English: Trigger price
        profitTiggerInput.isHidden = !self.openProfitBtn.isSelected
        profitTipLabelView.isHidden = !self.openProfitBtn.isSelected
        var profitExcutiveHidden = (currentPriceType == .limit)

        if profitExcutiveHidden && !self.openProfitBtn.isSelected {
            profitExcutiveHidden = false
        }
        //输入执行价 English: Enter execution price
        profitPlaceholdView.isHidden = !profitExcutiveHidden
        profitExcutiveInput.isHidden = !profitExcutiveHidden
    }
    
    func configLossView() {
        lossTiggerInput.isHidden = !self.openLossBtn.isSelected
        lossTipLabelView.isHidden = !self.openLossBtn.isSelected
        var lossExcutiveHidden = (currentPriceType == .limit)
        if lossExcutiveHidden && !self.openLossBtn.isSelected {
            lossExcutiveHidden = false
        }
        lossExcutiveInput.isHidden = !lossExcutiveHidden
        lossPlaceholdView.isHidden = !lossExcutiveHidden
    }
    
    func shouldUnselectedBtn(sender : EXSButton) -> Bool {
        let arr = [openLossBtn,openProfitBtn]
        var hasUnselected = false
        for btn in arr {
            if btn != sender,btn.isSelected == false {
                hasUnselected = true
            }
        }
        return hasUnselected
    }
    
    //MARK: action
    //MARK: 止盈止损点击 English: MARK: Stop profit and stop loss click
    @objc func openProfitOrLoss(sender : EXSButton) {
        if shouldUnselectedBtn(sender: sender) {
            return
        }
        sender.isSelected = !sender.isSelected
        configProfitView()
        configLossView()
        bindBtnEnable()
    }
    //MARK: 确认 English: MARK: Confirm
    @objc func clickConfirmButton() {
        guard positionModel != nil else {
            return
        }
        if openProfitBtn.isSelected == true {
            if self.profitTiggerInput.input.text?.count == 0 {
                EXAlert.showFail(msg:   "cp_order_text70".ex_localized())
                return
            }
            if currentPriceType == .limit &&
                self.profitExcutiveInput.input.text?.count == 0 {
                EXAlert.showFail(msg:  "cp_extra_text167".ex_localized())
                return
            }
           
        }
        if openLossBtn.isSelected == true {
            if self.lossTiggerInput.input.text?.count == 0 {
                EXAlert.showFail(msg:   "cp_order_text70".ex_localized())
                return
            }
            if currentPriceType == .limit &&
                self.lossExcutiveInput.input.text?.count == 0 {
                EXAlert.showFail(msg:  "cp_extra_text167".ex_localized())
                return
            }
        }
        
        if self.volumeTextField.input.text?.count == 0 {
            EXAlert.showFail(msg:  "cp_extra_text169".ex_localized())
            return
        }
        
        //平仓最小值校验 English: Verification of minimum closing value
        
        let res = self.positionModel?.closeMinValueLimit(input: self.volumeTextField.input.text!)
        if res!.0 == false{
            EXAlert.showFail(msg: res!.1)
            return
        }
        
        
        
        submitCount = 0
        
        let profitResult = takeProfitOrder()
        if profitResult.hasError == true {return}
        let lossResult = takeLossOrder()
        if lossResult.hasError == true { return }
        let profitOrder = profitResult.profit
        let lossOrder = lossResult.loss
        if EXStoreData.storeBool(forKey: swapTPSLComfirmAlertNotTip) == false {
            let arr = currentPriceType == .market ? messageForMarketAlert() : messageForLimitAlert()
            let alert = EXStoplossAlert()
            alert.dataList = arr
            alert.title = "cp_extra_text96".ex_localized()
            alert.alertCallback = { [weak self] _ in
                self?.exuteSsumintOrder(profit: profitOrder, loss: lossOrder)
            }
            EXAlert.showAlert(alertView: alert)
        }else {
            self.exuteSsumintOrder(profit: profitOrder, loss: lossOrder)

        }
        
    }
    
    private func exuteSsumintOrder(profit:SLContractStopProfitOrStopLossOrder?,loss:SLContractStopProfitOrStopLossOrder?){
      
        if let positionModel = self.positionModel,profit != nil || loss != nil {
            confirmButton.isEnabled = false
            EXContractNetwork.creatOrderStopProfitOrStopLossOrder(position: positionModel, stopProfit: profit, stopLoss: loss) { [weak self] in
                guard let mySelf = self else {return}
                mySelf.confirmButton.isEnabled = true
                mySelf.clickStopProfitLoss?(true)
                if mySelf.submitCount == 0 {
                    EXAlert.showSuccess(msg:  "cp_extra_text109".ex_localized())
                    mySelf.navigationController?.popViewController(animated: true)
                }
            } failure: { [weak self] (shouldRequest) in
                guard let mySelf = self else {return}
                if shouldRequest {
                    mySelf.requestProfitOrLossOrder()
                }
                mySelf.confirmButton.isEnabled = true
            }
        }
    }
    
    private func messageForMarketAlert() -> [AlertInfo] {
        let pTigPrice = (profitTiggerInput.input.text ?? "0")
        let lTigPrice = (lossTiggerInput.input.text ?? "0")
        let volume = (volumeTextField.input.text ?? "0")
        let unit = (volumeTextField.symbolLabel.text ?? "")

        var arr = [AlertInfo]()
        if openProfitBtn.isSelected {
            let a = AlertInfo.getStopLPMessage(title: "cp_extra_text97".ex_localized(), content: "cp_extra_text91".ex_localized(), triggerPrice: pTigPrice, volum: volume, unit: unit)
            arr.append(a)
        }
        if openLossBtn.isSelected {
            let a = AlertInfo.getStopLPMessage(title: "cp_extra_text98".ex_localized(), content: "cp_extra_text91".ex_localized(), triggerPrice: lTigPrice, volum: volume, unit: unit)
            arr.append(a)
        }
        let tip = AlertInfo.getStopLPMessageNextTip()
        arr.append(tip)
        return arr
    }
   
    
    private func messageForLimitAlert() -> [AlertInfo] {
        let pTigPrice = (profitTiggerInput.input.text ?? "0")
        let pExcPrice = (profitExcutiveInput.input.text ?? "0")
        let lTigPrice = (lossTiggerInput.input.text ?? "0")
        let lExcPrice = (lossExcutiveInput.input.text ?? "0")
        let volume = (volumeTextField.input.text ?? "0")
        let unit = (volumeTextField.symbolLabel.text ?? "")
        var arr = [AlertInfo]()
        if openProfitBtn.isSelected {
            let a = AlertInfo.getStopLPMessage(title: "cp_extra_text99".ex_localized(), content: "cp_extra_text92".ex_localized(), triggerPrice: pTigPrice, volum: volume, unit: unit, strike: pExcPrice)
            arr.append(a)
        }
        if openLossBtn.isSelected {
            let a = AlertInfo.getStopLPMessage(title: "cp_extra_text100".ex_localized(), content: "cp_extra_text92".ex_localized(), triggerPrice: lTigPrice, volum: volume, unit: unit, strike: lExcPrice)
            arr.append(a)
        }
        let tip = AlertInfo.getStopLPMessageNextTip()
        arr.append(tip)
        return arr
    }
    
    //MARK: 提交止盈单 English: MARK: Submit profit stop order
    private func takeProfitOrder() -> (profit: SLContractStopProfitOrStopLossOrder?, hasError:Bool)  {
        if !self.openProfitBtn.isSelected {
            return (nil,false)
        }
        let tigg_px = self.profitTiggerInput.input.text ?? "0"
        let ex_px = currentPriceType == .market ? "0" : self.profitExcutiveInput.input.text ?? "0"
        var volume = self.volumeTextField.input.text ?? ""
        
        if let p = self.positionModel, p.isCoin {
        
            volume = EXFormula.coin(toTicket: volume, price: p.index_px, contract: p.ex_contractInfo).toString(0)
        }
        if !tigg_px.greaterThan("0") {
            EXAlert.showFail(msg: "cp_extra_text181".ex_localized())
            return (nil,true)
        }

        let profitOrder = SLContractStopProfitOrStopLossOrder()
        profitOrder.triggerType = "2"
        profitOrder.price = ex_px
        profitOrder.volume = volume
        profitOrder.triggerPrice = tigg_px
        profitOrder.type = currentPriceType == .market ? 2 : 1
        let cycleValue = EXStoreData.storeObject(forKey: EX_DATE_CYCLE) as? Int ?? 0
        profitOrder.expiredTime = EXSwapPlanOrderValidityPeriod.init(rawValue: cycleValue)?.parm()

        return (profitOrder,false)
    }
    
    
    /// 提交止损单 English: /Submit stop loss orders
    private func takeLossOrder() -> (loss:SLContractStopProfitOrStopLossOrder?,hasError:Bool) {
        
        if !self.openLossBtn.isSelected {
            
            return (nil,false)
        }
        let tigg_px = self.lossTiggerInput.input.text ?? "0"
        let ex_px = currentPriceType == .market ? "0" : self.lossExcutiveInput.input.text
        var volume = self.volumeTextField.input.text ?? ""

        if let p = self.positionModel, p.isCoin {
        
            volume = EXFormula.coin(toTicket: volume, price: p.index_px, contract: p.ex_contractInfo).toString(0)
        }
        if !tigg_px.greaterThan("0") {
            EXAlert.showFail(msg: "cp_extra_text181".ex_localized())
            return (nil,true)
        }

        let lossOrder = SLContractStopProfitOrStopLossOrder()
        lossOrder.triggerType = "1"
        lossOrder.price = ex_px ?? ""
        lossOrder.volume = volume
        lossOrder.triggerPrice = tigg_px
        lossOrder.type = currentPriceType == .market ? 2 : 1
        let cycleValue = EXStoreData.storeObject(forKey: EX_DATE_CYCLE) as? Int ?? 0
        lossOrder.expiredTime = EXSwapPlanOrderValidityPeriod.init(rawValue: cycleValue)?.parm()

        return (lossOrder,false)
       
    }
   
    //MARK: 切换市价限价 English: MARK: Switch market price limit
    @objc func clickLimitBtn() {
        currentPriceType = .limit
        priceTypeBtn.text(content: orderWaysModel()[1].name)
        priceTypeBtn.relayout()
        self.view.endEditing(true)
        configLossView()
        configProfitView()
        bindBtnEnable()
    }
    
    @objc func clickMarketBtn() {
        currentPriceType = .market
        priceTypeBtn.text(content: orderWaysModel()[0].name)
        priceTypeBtn.relayout()
        self.view.endEditing(true)
        configLossView()
        configProfitView()
        bindBtnEnable()
    }
    @objc func clickRevokeAllStopProfitOrderButton() {
        let orderIds = self.stopProfitList.map { "\($0.oid)" }
        revokeAllStopProfitOrderButton.isUserInteractionEnabled = false
        EXContractNetwork.revokeOrderForStopProfitOrStopLoss(contractId: self.positionModel?.instrument_id ?? 0, orderIds: orderIds) {
            self.revokeAllStopProfitOrderButton.isUserInteractionEnabled = true
            EXAlert.showSuccess(msg:  "cp_extra_text180".ex_localized())
            self.requestProfitOrLossOrder()
        } failure: { (_) in
            
        }
    }
    
    @objc func clickRevokeAllStopLossOrderButton() {
        let orderIds = self.stopLossList.map { "\($0.oid)" }
        revokeAllStopLossOrderButton.isUserInteractionEnabled = false
        EXContractNetwork.revokeOrderForStopProfitOrStopLoss(contractId: self.positionModel?.instrument_id ?? 0, orderIds: orderIds) {
            self.revokeAllStopLossOrderButton.isUserInteractionEnabled = true
            EXAlert.showSuccess(msg:  "cp_extra_text179".ex_localized())
            self.requestProfitOrLossOrder()
        } failure: { (_) in
            
        }
    }
}

extension EXStopProfitLossVc {
    func getCloseMore(price:String,volume:String) -> NSMutableAttributedString {
        
        let fullMsg = "cp_order_text35".ex_localized() + " " + price + " " + volume

        return getAttr(title: "cp_order_text35".ex_localized(), fullStr: fullMsg)
    }
    //可平仓位 English: Flat position
    func getAttr(title:String,fullStr:String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.ThemeFont.SecondaryRegular,
            .foregroundColor: UIColor.ThemeLabel.colorMedium,
        ]
        
        let attr = NSMutableAttributedString.init(string: fullStr, attributes: attributes)
        let nsString = NSString(string: fullStr)
        let titleRange = nsString.range(of: title)
        attr.addAttribute(.foregroundColor, value: UIColor.ThemeLabel.colorMedium, range:titleRange)
        attr.addAttribute(.font, value: UIFont.ThemeFont.SecondaryMedium, range:titleRange)

        return attr
    }
}
extension EXStopProfitLossVc {
    func calculatePorfit(excutivePx:String,openPx:String)->String {
        var qty = volumeTextField.input.text ?? "0"
        if let position = positionModel, let model = positionModel?.ex_contractInfo {
            
            var profit = "0"
            if !model.isCoin {
                qty = EXFormula.ticket(toCoin: qty, contract: model)
            }
            
            if position.side == .openMore {
                profit = EXFormula.calculateCloseLongProfitAmount(qty, holdAvgPrice: openPx, markPrice: excutivePx, contractInfo: model)
            }else {
                profit = EXFormula.calculateCloseShortProfitAmount(qty, holdAvgPrice: openPx, markPrice: excutivePx, contractInfo: model)
            }
            return profit.toValuePrecision(withContract: model.instrument_id)
        }
        return ""
    }
}

extension EXStopProfitLossVc{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset
        if point.y < 0 {
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
}

