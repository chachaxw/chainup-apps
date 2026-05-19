//
//  EXCoinMapSheet.swift
//  Chainup
//
//  Created by liuxuan on 2023/12/17.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
class EXCoinMapSheet: UIView {
    let disposebg = DisposeBag()
    //After selecting input, callback the string, btc/USDT.
    //After selecting all, the callback will be empty, and the filtering parameters will be empty
    typealias CoinMapSheetCallback = (String) -> ()
    var onCoinMapCallback:CoinMapSheetCallback?
    
    var btnsAry:[EXTextButton] = []
    var filterModel:EXFilterDataModel = EXFilterDataModel()
    var isExpand:Bool = false
    static let column:Int = 3
    
    var coinSymbol:String = ""
    var coinMarket:String = ""
    
    var lastLeftValue:String?
    var lastRightValue:String?
    var selectedItemValue:String = ""


    lazy var input: EXTextField = {
        let textField = EXTextField()
//        textField.setPlaceHolder(placeHolder: "redpacket_send_inputAmount".localized())
        textField.input.setPlaceHolderAtt("redpacket_send_inputAmount".localized(),color: .Ex.text3)
        textField.input.font = UIFont.ThemeFont.BodyMedium
        textField.input.backgroundColor = .Ex.fill3
        textField.backgroundColor = .Ex.fill3
        
        textField.maxLenth = 10
        textField.textfieldValueChangeBlock = {[weak self]str in
            self?.lastLeftValue = str
        }
        return textField
    }()
    
    var selectionField: EXSelectionField = {
        let textField = EXSelectionField()
        textField.input.setPlaceHolderAtt("redpacket_send_inputAmount".localized(),color: .Ex.text3)
        textField.input.font = UIFont.ThemeFont.BodyMedium
        textField.middleView.backgroundColor = .Ex.fill3
        textField.triangle.backgroundColor = .Ex.fill3
        textField.triangle.fillColor = .Ex.fill3
        textField.input.textColor = .Ex.text3
        for view in textField.middleView.subviews {
            view.backgroundColor = .Ex.fill3
        }
        return textField
    }()
    
    lazy var slashLabel:UILabel = {
        let title = UILabel()
        title.text = "/"
        title.textAlignment = .center
        title.font = UIFont.ThemeFont.HeadMedium
        title.textColor = .Ex.fill5
        return title
    }()
    
    lazy var titleLabel:UILabel = {
        let title = UILabel()
        title.text = "filter_mix_tradeCoinPair".localized()
        title.font = UIFont.ThemeFont.HeadMedium
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var closeBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadMedium
        btn.setTitle("common_text_close".localized(), for: .normal)
        btn.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var resetBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.layer.cornerRadius = 4
        btn.setTitle("filter_action_reset".localized(), for: .normal)
        btn.extSetBorderWidth(0.5, color: UIColor.ThemeView.highlight)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadRegular
        btn.setTitleColor(.Ex.text1, for: .normal)
        btn.addTarget(self, action: #selector(resetBtnAction), for: .touchUpInside)
//        btn.backgroundColor = .Ex.fill3
        return btn
    }()
    
    lazy var confirmBtn:EXButton = {
        let btn = EXButton()// UIButton.init(type: .custom)
        btn.cornerRadius = 4
        btn.setTitle("common_text_btnConfirm".localized(), for: .normal)
        btn.titleLabel?.font = UIFont.ThemeFont.HeadRegular
        btn.setTitleColor(.Ex.text2, for: .normal)
        btn.addTarget(self, action: #selector(confirmBtnAction), for: .touchUpInside)
        return btn
        
    }()
    
    lazy var titleView :UIView = {
        let footer = UIView()
        footer.backgroundColor = UIColor.ThemeView.bg
        return footer
    }()
    
    lazy var titleSeperator:UIView = {
        let footer = UIView()
        footer.backgroundColor = UIColor.ThemeView.seperator
        return footer
    }()
    
    lazy var coinMapView :UIView = {
        let footer = UIView()
        footer.backgroundColor = UIColor.ThemeView.bg
        return footer
    }()
    
    lazy var mixContainer:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var footerView:UIView = {
        let footer = UIView()
        footer.backgroundColor = UIColor.ThemeView.bg
        return footer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSheetViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configSheetViews()
    }
    
    func handleActions() {
        selectionField.normalStyle()
        selectionField.textfieldDidTapBlock = {[weak self] in
            self?.expandCells()
        }
        input.textfieldValueChangeBlock = {[weak self] text in
            self?.updateLeftValue(text)
        }
    }
    
    func updateLeftValue(_ value:String) {
        self.coinSymbol = value 
    }
    
    func configSheetViews() {
        self.isExpand = false
        self.addSubview(titleView)
        self.addSubview(coinMapView)
        self.addSubview(footerView)
        
        titleView.addSubview(titleLabel)
        titleView.addSubview(closeBtn)
        titleView.addSubview(titleSeperator)
        
        coinMapView.addSubview(mixContainer)
                
        mixContainer.addArrangedSubview(input)
        mixContainer.addArrangedSubview(slashLabel)
        mixContainer.addArrangedSubview(selectionField)
        
        footerView.addSubview(resetBtn)
        footerView.addSubview(confirmBtn)
        
        mixContainer.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(30)
            make.top.equalTo(16)
        }
        
        titleSeperator.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        resetBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.width.equalTo(confirmBtn.snp.width)
            make.right.equalTo(confirmBtn.snp.left).offset(-15)
            make.top.equalTo(30)
            make.height.equalTo(44)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.width.equalTo(resetBtn.snp.width)
            make.left.equalTo(resetBtn.snp.right).offset(15)
            make.top.equalTo(30)
            make.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.right.equalTo(closeBtn.snp.left).offset(-15)
        }
        
        closeBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
        titleView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalTo(SCREEN_WIDTH)
            make.height.equalTo(52)
        }
        
        coinMapView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(46)
        }
        
        footerView.snp.makeConstraints { (make) in
            make.top.equalTo(coinMapView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(104)
            make.bottom.equalToSuperview()
        }
        
        
        
        slashLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(20)
        }
        input.snp.makeConstraints { (make) in
//            make.width.equalToSuperview().multipliedBy(0.47)
            make.left.equalToSuperview()
            make.right.equalTo(slashLabel.snp.left).offset(-10)
            make.centerY.equalToSuperview()
        }
        
        selectionField.snp.makeConstraints { (make) in
//            make.width.equalToSuperview().multipliedBy(0.45)
            make.right.equalToSuperview()
            make.left.equalTo(slashLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        handleActions()
        subcribeBtnEnable()
    }

    func subcribeBtnEnable() {
        Observable.combineLatest(input.input.rx.text.orEmpty, selectionField.input.rx.text) { textValue1, textValue2 in
            let t1 = textValue1.trimmingCharacters(in: .whitespaces)
            return (!t1.isEmpty) && textValue2 != "common_action_sendall".localized()
        }
        .subscribe(onNext: { [weak self] isValid in
            guard let self = self else { return }
            if isValid {
                self.confirmBtn.isEnabled = true
                self.confirmBtn.setTitleColor(.Ex.text1, for: .normal)
            } else {
                self.confirmBtn.isEnabled = false
                self.confirmBtn.setTitleColor(.Ex.text2, for: .normal)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func clearData() {
        for btn in btnsAry {
            btn.removeFromSuperview()
        }
        btnsAry.removeAll()
    }
    
    func bindMixCell(model:EXFilterDataModel) {
        self.filterModel = model
        self.coinMarket = EXFoldItemType.forceAll.rawValue
        if model.itemListHiddenAll {
            self.coinMarket = ""
        }
        configCells()
    }
    
    @objc func itemDidTapAction(sender:UIButton) {
        for btn in btnsAry {
            if btn == sender {
                btn.isSelected = true
            }else {
                btn.isSelected = false
            }
        }
        let model = self.filterModel.extraItems[sender.tag]
        selectionField.setText(text: model.text)
        selectionField.normalStyle()
        self.lastRightValue = model.valueKey
        self.coinMarket = model.valueKey
        self.expandCells()
        configCells()
    }
    
    func expandCells() {
        isExpand = !isExpand
        if isExpand {
            if self.isExpand {
                let horizonGap = SCREEN_WIDTH * 0.06
                let btnWidth = (SCREEN_WIDTH - 30 - horizonGap*2)/3
                let btnHeight = Int(btnWidth * 0.316)
                let ygap = 15
                let startX = 15
                let startY = 66
                
                for (idx,item) in filterModel.extraItems.enumerated() {
                    
                    let cellItem = EXTextButton()
                    cellItem.supportCheckHighlight = true
                    if self.selectedItemValue.isEmpty {
                        if !filterModel.itemListHiddenAll {
                            cellItem.isSelected = (idx == 0)
                        }
                    }else {
                        if item.valueKey == self.selectedItemValue {
                            cellItem.isSelected = true
                        }else {
                            cellItem.isSelected = false
                        }
                    }
                    cellItem.setFont(font: .Ex.medium(14))
                    cellItem.color = .Ex.fill3
                    cellItem.setTitleColor(.Ex.main4, for: .selected)
                    cellItem.setTitle(item.text, for: .normal)
                    cellItem.addTarget(self, action: #selector(itemDidTapAction(sender:)), for: .touchUpInside)
                    
                    coinMapView.addSubview(cellItem)
                    let col = idx %  EXFoldFilterCell.column
                    let row = idx / EXFoldFilterCell.column
                    let xPosition = (btnWidth + horizonGap)*CGFloat(col)
                    let yPosition = (btnHeight + ygap)*(row)
                    let px = CGFloat(startX) + xPosition
                    let py = startY + yPosition
                    cellItem.frame = CGRect(x: px, y: CGFloat(py), width: btnWidth, height: CGFloat(btnHeight))
                    cellItem.tag = idx
                    btnsAry.append(cellItem)
                }
            }
            
            coinMapView.snp.remakeConstraints { (make) in
                make.top.equalTo(titleView.snp.bottom)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(EXCoinMapSheet.getHeight(models: self.filterModel.extraItems,expand: true))
            }
  
        }else {
            coinMapView.snp.remakeConstraints { (make) in
                make.top.equalTo(titleView.snp.bottom)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(EXCoinMapSheet.getHeight(models: self.filterModel.extraItems))
            }
        }
    }
    
    func configCells() {
        if filterModel.items.count > 0 {
            let leftModel = filterModel.items[0]
//            input.setPlaceHolder(placeHolder: leftModel.inputPlaceHolder)
            input.input.setPlaceHolderAtt(leftModel.inputPlaceHolder,color: .Ex.text3)
            input.input.font = UIFont.ThemeFont.BodyMedium
            if let lastValue = self.lastLeftValue {
                input.setText(text: lastValue)
            }
//            else {
//                input.setText(text: "")
//            }
            
        }
        if filterModel.extraItems.count > 0 {
            self.clearData()
            var rightItem = EXFilterItem()
            if filterModel.itemListHiddenAll { //Separate processing of right title
                rightItem.text = "common_action_sendall".localized()
                rightItem.valueKey = ""
            }else{
                rightItem = filterModel.extraItems[0]
            }
            
            if let lastValue = self.lastRightValue,lastValue.count > 0 {
                self.selectedItemValue = lastValue
                if selectedItemValue == EXFoldItemType.forceAll.rawValue {
                    input.setText(text: "common_text_allDay".localized())
                    self.updateLeftValue("common_text_allDay".localized())
                    input.input.isUserInteractionEnabled = false
                }else {
//                    if let lastLeft = lastLeftValue,lastLeft == "common_text_allDay".localized(){
//                        input.setText(text: "")
//                        self.updateLeftValue("")
//                    }
                    input.input.isUserInteractionEnabled = true
                }
                for item in filterModel.extraItems {
                    if item.valueKey == lastValue {
                        selectionField.setText(text: item.text)
                    }
                }
            }else {
                self.selectedItemValue = ""
                if rightItem.valueKey == EXFoldItemType.forceAll.rawValue {
                    input.setText(text: "common_text_allDay".localized())
                    self.updateLeftValue("common_text_allDay".localized())
                    input.input.isUserInteractionEnabled = false
                }else {
                    if let lastLeft = lastLeftValue,lastLeft == "common_text_allDay".localized() {
                        input.setText(text: "")
                        self.updateLeftValue("")
                    }
                    input.input.isUserInteractionEnabled = true
                }
                selectionField.setText(text: rightItem.text)
            }
        }
    }
    
    @objc func confirmBtnAction() {
        if self.coinMarket == EXFoldItemType.forceAll.rawValue  {
            self.onCoinMapCallback?("")
            EXAlert.dismiss()
        }else {
            if self.coinSymbol.isEmpty {
                EXAlert.showFail(msg: "filter_input_coinsymbol".localized())
            }else {
                self.onCoinMapCallback?(self.coinSymbol.uppercased() + "/" + self.coinMarket.uppercased())
                EXAlert.dismiss()
            }
        }
    }
    
    @objc func resetBtnAction() {
        self.lastLeftValue = ""
        self.lastRightValue = nil
        self.coinMarket = EXFoldItemType.forceAll.rawValue
        self.coinSymbol = ""
        configCells()
    }
    
    @objc func closeAction() {
        EXAlert.dismiss()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 10)
    }
    
}

extension EXCoinMapSheet {
    
    class func getHeight(models:[EXFilterItem],expand:Bool = false) -> CGFloat{
        let normalHeight:CGFloat = 46
        if expand {
            let quotient = models.count/self.column
            var  remainder = models.count%self.column

            if remainder > 0 {
                remainder = 1
            }
            let rowHeight = (quotient + remainder)*36
            let gapHeight = (quotient + remainder - 1)*15
            return CGFloat(rowHeight + gapHeight) + normalHeight + 20
            
        }else {
            return normalHeight
        }
    }
}

