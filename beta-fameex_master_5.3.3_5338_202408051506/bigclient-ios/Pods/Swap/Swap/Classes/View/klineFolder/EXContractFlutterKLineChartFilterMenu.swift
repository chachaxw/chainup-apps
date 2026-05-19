//
//  EXFlutterKLineChartFilterMenu.swift
//  Chainup
//
//  Created by 尤彬 on 2023/5/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import JXSegmentedView
import EXKit

class EXContractFlutterKLineChartFilterMenu: EXView {
    
    var openStateBlock: EXComBoolBlock?
    var saceKeyValueBlock: EXComStringBlock?
    var viewModel: EXContractFlutterKLineChartViewModel?
    
    var isBottom: Bool = false {
        didSet {
            
            let image = isBottom ? EXKitBundle.image(named: "public_arrow_superior"): EXKitBundle.image(named: "public_arrow_down")
            self.arrowImgV.image = image
           
        }
    }
    
    /// 记录已选择的scaleKey English: /Record the selected scaleKey
    private var lastScaleKeyValue = ""
    private var lastSelectedIndex: Int?
    
    private lazy var menuItems: [String] = {
        return EXSwapKlineDataTool.getSmallAllKlineScale()
    }()
    
    private lazy var menuItemsValues: [String] = {
        return EXSwapKlineDataTool.getContractSaceKeys()
    }()
    
    private var defaultMenuItem: EXCOMenuSelectionModel = EXCOMenuSelectionModel()
    
    private lazy var dataSource: JXSegmentedTitleDataSource = {
        let d    = JXSegmentedTitleDataSource()
        d.titles = self.menuItems
        d.isTitleColorGradientEnabled = true
        d.isItemSpacingAverageEnabled = false
        d.itemSpacing        = 16
        d.titleNormalColor   = .ThemeLabel.colorMedium
        d.titleSelectedColor = .ThemeLabel.colorLite
        d.titleNormalFont    = .ThemeFont.SecondaryBold
        d.titleSelectedFont  = .ThemeFont.SecondaryBold
        return d
    }()
    
    private lazy var indicatorLine: JXSegmentedIndicatorLineView = {
        let v = JXSegmentedIndicatorLineView()
        v.indicatorHeight = 4
        v.indicatorWidth  = 22
        v.indicatorCornerRadius = 0
        v.indicatorColor        = .ThemeView.highlight
        return v
    }()
    
    lazy var menuView: JXSegmentedView = {
        let v = JXSegmentedView()
        v.dataSource = self.dataSource
        v.indicators = [self.indicatorLine]
        v.delegate   = self
        v.isHidden   = true
        return v
    }()
    
    private lazy var coinNameLabel: EXInsetLabel = {
        let v = EXInsetLabel()
        v.font      = .ThemeFont.SecondaryBold
        v.textColor = .ThemeLabel.colorLite
        v.edgeInset = .init(top: 0, left: 16, bottom: 0, right: 0)
        v.isHidden  = false
        return v
    }()
    
    private lazy var arrowImgV: UIImageView = {
        let v = UIImageView()
        v.isUserInteractionEnabled = true
        v.contentMode = .scaleAspectFit
//        v.image       = UIImage.themeImageNamed(imageName: "public_arrow_superior")
        //        v.image = UIImage.themeImageNamed(imageName: "public_arrow_superior")
        return v
    }()
    
    lazy var seperatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = .Ex.fill4
        v.isHidden        = true
        return v
    }()
    
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXContractFlutterKLineChartViewModel
        super.init(viewModel: viewModel)
    }
    
    private var isOpen: Bool = false;
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        addSubViews([menuView, coinNameLabel, arrowImgV, seperatorLine])
        arrowImgV.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 11, height: 11))
        }
        menuView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(arrowImgV.snp.left).offset(-12);
        }
        coinNameLabel.snp.makeConstraints { make in
            make.edges.equalTo(menuView).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        seperatorLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let tapGes = UITapGestureRecognizer()
        tapGes.delegate = self
        self.addGestureRecognizer(tapGes)
        tapGes.rx.event.bind(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.isOpen    = !self.isOpen
            self.updateLayout(with: self.isOpen)
        }).disposed(by: self.disposeBag)
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
//            let selectedIndex    = strongSelf.handleWithDefaultIndex()
//            let saceKeyValue     = strongSelf.menuItemsValues[selectedIndex]
//            strongSelf.lastSelectedIndex = selectedIndex;
//            strongSelf.handleWithSaceKeyValue(saceKeyValue)
//            strongSelf.menuView.selectItemAt(index: selectedIndex)
//            strongSelf.menuView.reloadData()
            strongSelf.dealscakey()
        }
        
        self.viewModel?.wsEventSubject.subscribe(onNext: {[weak self] event in
            guard let self = self else { return }
            switch event {
            case .KLineChangedEntity(let entity):
                if let contractInfo = self.viewModel?.currentItemModel?.ex_contractInfo {
                    let text = "cp_contract_perpetual_chart".ex_localized().replacingOccurrences(of: "%@", with: "")
                    self.coinNameLabel.text = contractInfo.showName() + text
                }
            case .bigKlineTimeKeyChange(let timeKey):
                lastScaleKeyValue = timeKey
                /*
                 lastScaleKeyValue
                 大k 线 时间轴变动，小k线只更新页面，无需订阅数据，页面出来会重新订阅数据
                 The timeline of the big candlestick changes, while the small candlestick only updates the page without subscribing to data. When the page comes out, it will be re subscribed to data
                 */
                self.updateScaleKey(timeKey: timeKey)
                break
            default:
                break
            }
        }).disposed(by: self.disposeBag)
    }
    
    
    func updateScaleKey(timeKey: String){
        defaultMenuItem.scaleKey = timeKey
        dealscakey()
    }
    
    func dealscakey(){
        let selectedIndex    =  self.handleWithDefaultIndex()
        let saceKeyValue     =  self.menuItemsValues[selectedIndex]
        self.lastSelectedIndex = selectedIndex;
        self.handleWithSaceKeyValue(saceKeyValue)
        self.menuView.selectItemAt(index: selectedIndex)
        self.menuView.reloadData()
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

extension EXContractFlutterKLineChartFilterMenu : JXSegmentedViewDelegate{
    
    /// 订阅K线周期 English: /Subscription K-line cycle
    internal func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        let scaleKeyValue = menuItemsValues[index]
        self.handleWithSaceKeyValue(scaleKeyValue)
    }
    
    /// 处理选择K线周期, 并执行相应的block English: /Process the selection of K-line cycles and execute the corresponding block
    /// - Parameter scaleKeyValue: Line 1min 5min ...
    internal func handleWithSaceKeyValue(_ scaleKeyValue: String) {
        if self.lastScaleKeyValue == scaleKeyValue {
            return
        }
        self.defaultMenuItem.scaleKey = scaleKeyValue
        self.lastScaleKeyValue = scaleKeyValue
        self.saceKeyValueBlock?(scaleKeyValue)
    }
    
    /// 默认选择K线的周期,并返回索引 English: /By default, select the period of the K-line and return the index
    /// - Returns: 索引 English: /- Returns: Index
    internal func handleWithDefaultIndex() -> Int {
        let scaleKey = defaultMenuItem.scaleKey
        if let index = menuItemsValues.firstIndex(of: scaleKey){
            return index
        }else {
            //MARK: 默认15min English: MARK: Default 15 minutes
            return 3
        }
    }
}


extension EXContractFlutterKLineChartFilterMenu {
    
    func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
            guard let self = self else { return }
            let index = self.handleWithDefaultIndex()
            let selectedIndex = self.menuView.selectedIndex
            if (selectedIndex == index) {
                return
            }
            self.menuView.selectItemAt(index: index)
            self.menuView.reloadData()
        }
    }
    
    
    //    public_arrow_down
    //    public_arrow_superior
    
    /// 更新布局 English: /Update Layout
    /// - Parameter isOpen: true:显示订阅条件(line 1min 5min ...) false: 显示币种名称 English: /- Parameter isOpen: true: Display subscription conditions (line 1min 5min...) false: Display currency name
    internal func updateLayout(with isOpen: Bool)  {
        self.openStateBlock?(isOpen)
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let self = self else { return }
            self.menuView.isHidden           = !isOpen
            self.coinNameLabel.isHidden      = isOpen
            self.seperatorLine.isHidden      = !isOpen
            self.arrowImgV.layer.transform   = !isOpen ?
            CATransform3DIdentity :
            CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        })
    }
}


extension EXContractFlutterKLineChartFilterMenu: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let result = touch.view?.isDescendant(of: self.menuView), result == true {
            return false
        }
        return true
    }
}


