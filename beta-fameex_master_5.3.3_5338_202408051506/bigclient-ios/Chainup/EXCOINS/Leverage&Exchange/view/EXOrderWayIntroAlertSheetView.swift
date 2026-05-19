//
//  EXOrderWayIntroAlertSheetView.swift
//  Chainup
//
//  Created by bradjohn on 2024/1/2.
//  Copyright © 2024 Chainup. All rights reserved.
//

import UIKit
import SnapKit
import JXSegmentedView
import EXKit

class EXOrderWayIntroAlertSheetView: EXCustomBaseView {
    
    var subItems = [EXOrderWayIntroAlertSheetSubView]()
    
    private var cancelButton = UIButton(buttonType: .custom, title: "common_text_btnCancel".localized(), titleFont: .ThemeFont.BodyMedium, titleColor: .ThemeLabel.colorMedium)
    lazy var segmentedView: JXSegmentedView = {
        let view = JXSegmentedView()
        return view
    }()
    lazy var titleDataSource: EKIndicatorSegmentDatasource = {
        let dataSource = EKIndicatorSegmentDatasource()
        dataSource.titleNormalFont = UIFont.ThemeFont.HeadMedium
        dataSource.titleSelectedFont = UIFont.ThemeFont.HeadMedium
        return dataSource
    }()
    lazy var indicator: EKIndicatorSegmentIndicator = {
        let obj = EKIndicatorSegmentIndicator()
        return obj
    }()
    
    lazy var listContainerView = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    lazy var menuTitles:[String] = {
        let array = ["contract_action_limitPrice".localized(),
                     "contract_action_marketPrice".localized()]
        return array
    }()
    
    //
    var orderAction:EXTradeOrderAction = .buy
    var orderWay:EXTradeOrderWay = .limit
    //
    init(orderWay:EXTradeOrderWay = .limit,orderAction:EXTradeOrderAction = .buy) {
        super.init(frame: .zero)
        self.orderWay = orderWay
        self.orderAction = orderAction
        //
        titleDataSource.titles = menuTitles
        subItems = [EXOrderWayIntroAlertSheetSubView(orderWay: .limit,orderAction: orderAction),
                    EXOrderWayIntroAlertSheetSubView(orderWay: .market)]
        segmentedView.reloadData()
        if orderWay == .limit {
            self.segmentedView.selectItemAt(index: 0)
        }else if orderWay == .market {
            self.segmentedView.selectItemAt(index: 1)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //
    override func setSubView() {
        super.setSubView()
        backgroundColor = UIColor.ThemeView.alertBg
        //
        configSubViews()
        //
        cancelButton.rx.tap.subscribe(onNext:{
            EXAlert.dismiss()
        }).disposed(by: self.disposeBag)
        //
        self.snp.makeConstraints { make in
            make.height.equalTo(Device_H * 600.0/812)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.exs_roundCorners(corners: [.topLeft,.topRight], radius: 12)
    }
    
    func configSubViews() {
        //
        addSubview(cancelButton)
        addSubview(listContainerView)
        //
        segmentedView.dataSource = titleDataSource
        segmentedView.indicators = [indicator]
        segmentedView.delegate = self
        segmentedView.listContainer = listContainerView
        addSubview(segmentedView)
        //
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalTo(segmentedView).offset(-6)
            make.right.equalTo(-16)
            make.height.equalTo(40)
        }
        //
        segmentedView.snp.remakeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(0)
            make.right.equalTo(cancelButton.snp.left).offset(-10)
            make.height.equalTo(32.7)
        }
        //
        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom).offset(5)
            make.left.right.bottom.equalTo(0)
        }
    }
    
}


extension EXOrderWayIntroAlertSheetView : JXSegmentedViewDelegate,
                                          JXSegmentedListContainerViewDataSource,
                                          JXSegmentedListContainerViewListDelegate {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        if let titleDataSource = segmentedView.dataSource as? JXSegmentedBaseDataSource {
            return titleDataSource.dataSource.count
        }
        return 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        return subItems[index]
    }
    
    func listView() -> UIView {
        return self
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        
    }
}

class EXOrderWayIntroImageDescItemView: UIView {
    
    enum IconType {
        case color
        case circle
    }
    lazy var label: UILabel = {
        let label = UILabel(text: "", font: .ThemeFont.MinimumRegular, textColor: .ThemeLabel.colorMedium, alignment: .left)
        return label
    }()
    override var intrinsicContentSize: CGSize {
        let textSize = label.intrinsicContentSize
        return CGSize(width: 4 + 4 + textSize.width, height: max(textSize.height, 4))
    }
    
    init(type:IconType = .color,pointColor:UIColor,text:String) {
        super.init(frame: .zero)
        //
        let pointView = UIView()
        pointView.corneradius = 2
        pointView.borderW = 1
        pointView.layer.borderColor = pointColor.cgColor
        if type == .circle {
            pointView.backgroundColor = .clear
        }else{
            pointView.backgroundColor = pointColor
        }
        pointView.snp.makeConstraints { make in
            make.width.height.equalTo(4)
        }
        //
        label.text = text
        //
        let stackView = UIStackView(arrangedSubviews: [pointView,label])
        stackView.spacing = 4
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        //
        invalidateIntrinsicContentSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EXOrderWayIntroCheckBox: EXCheckBox {
    required init(frame: CGRect = .zero, style: CheckBoxIconStyle = .circleCheck) {
        super.init(frame: .zero,style: style)
        self.checkIcon.snp.updateConstraints { make in
            make.width.height.equalTo(12)
        }
        checkLabel.font = .ThemeFont.SecondaryMedium
        checkLabel.numberOfLines = 1
        checkColor = .ThemeLabel.colorLite
    }
    override func configIcon() {
        super.configIcon()
        self.checkIcon.image = self.isChecked ? EXKitBundle.svgImage(named: "public_checked") : EXKitBundle.image(named: "quotes_unselected")
        self.checkIcon.snp.updateConstraints { make in
            make.width.height.equalTo(12)
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EXOrderWayIntroAlertSheetSubView: EXCustomBaseView {
    lazy var topLabel:UILabel = {
        let label = UILabel(text: "", font: .ThemeFont.SecondaryRegular, textColor: .ThemeLabel.colorMedium, alignment: .left)
        label.numberOfLines = 0
        return label
    }()
    lazy var imageHeaderLabel: UILabel = {
        let label = UILabel(text: "trade_market_title_sub".localized(), font: .ThemeFont.BodyMedium, textColor: .ThemeLabel.colorLite, alignment: .left)
        return label
    }()
    
        
    var orderAction:EXTradeOrderAction = .buy
    func updateLimitInfo() {
        if orderAction == .buy {
            buyCheckBox.checked(check:true)
            sellCheckBox.checked(check:false)
            imageView.image = EXKitBundle.svgImage(named: "limit_buy")
            updateTextLineHeight(for: bottomLabel1, text: "trade_limit_title_buy_2".localized())
            updateTextLineHeight(for: bottomLabel2, text: "trade_limit_title_buy_3".localized())
        }else{
            buyCheckBox.checked(check:false)
            sellCheckBox.checked(check:true)
            imageView.image = EXKitBundle.svgImage(named: "limit_sell")
            updateTextLineHeight(for: bottomLabel1, text: "trade_limit_title_sell_2".localized())
            updateTextLineHeight(for: bottomLabel2, text: "trade_limit_title_sell_3".localized())
        }
        buyCheckBox.updateTilteColor(select: buyCheckBox.isChecked)
        sellCheckBox.updateTilteColor(select: sellCheckBox.isChecked)
    }
    lazy var buyCheckBox:EXCheckBox = {
        let check = EXOrderWayIntroCheckBox()
        check.checkLabel.text = "contract_action_buy".localized()
        check.rx.controlEvent(.touchUpInside).subscribe(onNext:{ [weak self] in
            self?.orderAction = .buy
            self?.updateLimitInfo()
        }).disposed(by: self.disposeBag)
        return check
    }()
    lazy var sellCheckBox:EXCheckBox = {
        let check = EXOrderWayIntroCheckBox()
        check.checkLabel.text = "contract_action_sell".localized()
        check.rx.controlEvent(.touchUpInside).subscribe(onNext:{ [weak self] in
            self?.orderAction = .sell
            self?.updateLimitInfo()
        }).disposed(by: self.disposeBag)
        return check
    }()
    
    lazy var imageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var imageDescStackView:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }()
    
    lazy var bottomLabel1:UILabel = {
        let label = UILabel(text: "", font: .ThemeFont.SecondaryRegular, textColor: .ThemeLabel.colorMedium, alignment: .left)
        label.numberOfLines = 0
        return label
    }()
    lazy var bottomLabel2:UILabel = {
        let label = UILabel(text: "", font: .ThemeFont.SecondaryRegular, textColor: .ThemeLabel.colorMedium, alignment: .left)
        label.numberOfLines = 0
        return label
    }()
    
    init(orderWay:EXTradeOrderWay,orderAction:EXTradeOrderAction = .buy) {
        super.init(frame: .zero)
        backgroundColor = .ThemeView.alertBg
        //
        let scrollView = UIScrollView()
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        //
        let contenView = UIView()
        scrollView.addSubview(contenView)
        contenView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        //
        contenView.addSubViews([topLabel,imageHeaderLabel,imageView,imageDescStackView,bottomLabel1,bottomLabel2])
        //
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        //
        imageHeaderLabel.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(topLabel.snp.bottom).offset(20)
        }
        //
        imageView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(imageHeaderLabel.snp.bottom).offset(20)
            make.height.equalTo(Device_W * 101/344)
        }
        //
        imageDescStackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
        }
        //
        bottomLabel1.snp.makeConstraints { make in
            make.top.equalTo(imageDescStackView.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        bottomLabel2.snp.makeConstraints { make in
            make.top.equalTo(bottomLabel1.snp.bottom).offset(20)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-15)
        }
        
        //
        self.orderAction = orderAction
        if orderWay == .limit {
            //
            updateTextLineHeight(for: topLabel, text: "trade_limit_title".localized())
            //
            contenView.addSubViews([buyCheckBox,sellCheckBox])
            buyCheckBox.snp.makeConstraints { make in
                make.right.equalTo(sellCheckBox.snp.left).offset(-18)
                make.centerY.equalTo(sellCheckBox)
                make.height.equalTo(44)
            }
            sellCheckBox.snp.makeConstraints { make in
                make.right.equalTo(-16)
                make.centerY.equalTo(imageHeaderLabel)
                make.height.equalTo(44)
            }
            //
            imageDescStackView.addArrangedSubview(
                EXOrderWayIntroImageDescItemView(pointColor: .ThemeLabel.colorLite,
                                                 text: "trade_limit_chart_a".localized()))
            imageDescStackView.addArrangedSubview(
                EXOrderWayIntroImageDescItemView(pointColor: .ThemeView.highlight,
                                                 text: "trade_limit_chart_b".localized()))
            //
            updateLimitInfo()
        }else if orderWay == .market {
            updateTextLineHeight(for: topLabel, text: "trade_market_title".localized())
            //
            imageView.image = EXKitBundle.svgImage(named: "market")
            imageDescStackView.addArrangedSubview(
                EXOrderWayIntroImageDescItemView(pointColor: .ThemeView.highlight,
                                                 text: "trade_limit_chart_a".localized()))
            //
            updateTextLineHeight(for: bottomLabel1, text: "trade_market_title_2".localized())
            updateTextLineHeight(for: bottomLabel2, text: "trade_market_title_3".localized())
        }
    }
    func updateTextLineHeight(for label:UILabel, text:String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 20;
        paragraphStyle.maximumLineHeight = 20;
        let attr =
        NSAttributedString(string: text,
                           attributes: [.font:label.font ?? .ThemeFont.SecondaryRegular,
                                        .foregroundColor:label.textColor ?? .ThemeLabel.colorMedium,
                                        .paragraphStyle:paragraphStyle])
        label.attributedText = attr
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension EXOrderWayIntroAlertSheetSubView : JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}
