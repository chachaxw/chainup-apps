//
//  EXKlineDetailHeader.swift
//  Chainup
//
//  Created by youbin on 2023/6/15.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import SwiftEventBus
class EXKlineDetailHeader: EXView {
    var lastScaleKey = ""
    var hasLoadedAllKline = false
    public var klineHeight: CGFloat{
        get {
            //            var hasETF: Bool = true
            //            if let _entity = self.viewModel?.entity {
            //                if _entity.etfOpen == "1" {
            //                    hasETF = true
            //                } else {
            //                    hasETF = false
            //                }
            //            }
            //Set KLine not to display etf net value attribute
            return EXKlineDetailTableHeader.getHeightHasETF(false)
        }
    }
    
    lazy var kline: EXKlineDetailTableHeader = {
        let v = EXKlineDetailTableHeader(entity: self.viewModel?.entity ?? CoinMapEntity())
        v.reloadLable()
        v.isCloseNetworth = true
        v.gap.backgroundColor = .clear
        return v
    }()
    
    lazy var promptLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.textColor = UIColor.ThemeLabel.colorHighlight
        v.font = UIFont.ThemeFont.SecondaryMedium
        return v
    }()
    
    lazy var gap:UIView = {
        let v:UIView = UIView()
        v.backgroundColor = UIColor.ThemekLine.navBg
        return v
    }()
    
    var viewModel: EXKlineDetailNewViewModel?
    
    var heightCallback: ((_ height: CGFloat) -> Void)?
    
    required init(viewModel: EXViewModelProtocol?) {
        self.viewModel = viewModel as? EXKlineDetailNewViewModel
        super.init(viewModel: viewModel)
        self.viewModel?.resetKLine(self.kline)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.promptLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 32
    }
    
    override func setupView() {
        super.setupView()
        self.backgroundColor = UIColor.ThemekLine.viewBg
        addSubViews([kline, promptLabel, gap])
        kline.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(klineHeight)
        }
        promptLabel.snp.makeConstraints { make in
            make.top.equalTo(kline.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(0)
        }
        gap.snp.makeConstraints { make in
            make.top.equalTo(promptLabel.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(10)
        }
        updateLayout(entity: self.viewModel?.entity)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        self.handleKlinePrePage()
        self.viewModel?.wsEventSubject.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .KLineHistory(let items, let prePage):
                self.kline.klineView.hideLoading()
                if prePage {
                    self.kline.klineView.reloadPreData(data: items)
                } else {
                    self.kline.klineView.reloadData(data: items)
                }
                
            case .KLineHistoryFinish(let finished):
                if finished {
                    self.hasLoadedAllKline = true
                    self.kline.klineView.hideLoading()
                }
                
            case .KLineData(let item):
                self.kline.klineView.appendData(data: item)
                
            case .KLinePrice(let item):
                self.kline.updateTicker(withItem: item)
                
            case .KLineDepthChart(let item):
                guard let _entity = self.viewModel?.entity else { return }
                self.kline.updateItems(depthItems: item.0, max: self.viewModel?.maxDepth ?? 0, price: item.1, entity: _entity)
                
            case .KLineNetworth(let item):
                self.kline.setNetWorth(model: item.1)
                
            case .KLineChangedEntity(let entity):
                self.updateLayout(entity: entity)
                
            default:
                break
            }
        }).disposed(by: self.disposeBag)
        
        
        //KLine's click on 'More Responses'
        self.kline.onMenuActionCallback = { [weak self] (action, sender, key) in
            guard let `self` = self else { return }
            self.handleMenuAction(action: action, sender: sender, key: key)
        }
        
    }
    
    
    private func updateLayout(entity: CoinMapEntity?) {
        var _promptHeight: CGFloat = 0.0
        var text = ""
        if let _entity = entity {
//            if _entity.etfOpen == "1" {
//                var multiple = ""
//                if _entity.etfSide == "S" {
//                    multiple = String.init(format: "etf_notes_multipleS".localized(), _entity.etfMultiple)
//                }else {
//                    multiple = String.init(format: "etf_notes_multipleL".localized(), _entity.etfMultiple)
//                }
//                text = String(format: "etf_notes_explain_tips".localized(), _entity.coinName, _entity.etfBase, multiple)
//            }
//            self.promptLabel.text = text
            self.kline.coinEntity = _entity
        } else {
            self.promptLabel.text = ""
            self.kline.coinEntity = CoinMapEntity()
        }
        
        kline.snp.updateConstraints { make in
            make.height.equalTo(klineHeight)
        }
        layoutIfNeeded()
        if text.count > 0 {
//            _promptHeight = self.promptLabel.frame.height
            _promptHeight = text.textSizeWithFont(UIFont.ThemeFont.SecondaryMedium, width: SCREEN_WIDTH - 32).height
        }
        let _height = self.promptLabel.frame.origin.y + _promptHeight + 10 + self.gap.frame.size.height
        var _frame = self.frame
        _frame.size.height = ceil(_height)
        self.frame = _frame
        self.heightCallback?(self.frame.height)
    }
    
    
    func handleKlinePrePage() {
        SwiftEventBus.onMainThread(self, name: EXEventBusConst.onKlinePrePageTrigger) {[weak self] result in
            guard let `self` = self else {return}

            if self.hasLoadedAllKline {
                return
            }
            self.viewModel?.getHistoryKlinePre()
            self.kline.klineView.showLoading()
        }
    }
    
}



extension EXKlineDetailHeader {
    
    ///Click on Menu
    func handleMenuAction(action:KLineFilterMenuAction,sender:UIButton,key:String){
        
        if action == .changeScale {
            self.handleScale(key: key)
        } else if action == .zoom {
            guard let _entity    = self.viewModel?.entity else { return }
            guard let _menuModel = self.viewModel?.menuModel else { return }
            guard let _kDetailType = self.viewModel?.kDetailType else { return }
            let horizontal = EXMarketDetailHolzontalVc.instanceFromStoryboard(name: StoryBoardNameMarket)
            horizontal.accountType = _kDetailType
            horizontal.menuModel   = _menuModel
            horizontal.coinMapEntity = _entity
            //TODO: Shared menu
            horizontal.menuPublish
                .subscribe(onNext:{[weak self] model in
                    guard let `self` = self else {return}
                    self.changeMenuModel(menuModel: model)
                }).disposed(by: self.disposeBag)
            
            self.yy_viewController?.navigationController?.pushViewController(horizontal, animated: true)
            
        } else {}
    }
    
    func handleScale(key:String) {
        if lastScaleKey == key {
            return
        }
        self.hasLoadedAllKline = false
//        if let _scaleKey = self.viewModel?.menuModel.scaleKey, _scaleKey == key {
//            return
//        }
        self.viewModel?.trackActionOn()
        self.viewModel?.menuModel.scaleKey = key
        lastScaleKey = key
        self.viewModel?.scoketCandleScale(key: key)
        self.kline.klineView.showLoading()
        self.kline.klineView.chartSerieSwitchToLineMode(on: (key == EXKlineWsVm.keyLine))
        self.kline.klineView.updateMasterAlgorithm(to: self.kline.klineView.menuModel.masterType)
    }
    
    func changeMenuModel(menuModel:EXMenuSelectionModel) {
        self.viewModel?.menuModel = menuModel
        self.kline.menuModel = menuModel
        self.kline.menuBar.selectDefaultScaleType(type: menuModel.scaleKey)
        self.handleScale(key: menuModel.scaleKey)
    }
    
}


