//
//  EXRecommendETFBar.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/22.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXBarItem:UIView {
    var entity:CoinMapEntity = CoinMapEntity()
    
    lazy var bg:UIButton = {
        let bg = UIButton.init(type: .custom)
        bg.corneradius = 4
        bg.backgroundColor = UIColor.ThemeNav.bg
        bg.addTarget(self, action: #selector(etfBarItemClicked(bar:)), for: .touchUpInside)
        return bg
    }()
    
    lazy var titleLabel:UILabel = {
        let title = UILabel()
        title.font = UIFont.ThemeFont.SecondaryMedium
        title.textColor = UIColor.ThemeLabel.colorLite
        return title
    }()
    
    lazy var mutibleLabel:UILabel = {
        let title = UILabel()
        title.font = UIFont.ThemeFont.SecondaryMedium
        title.textColor = UIColor.ThemeLabel.colorMedium
        return title
    }()
    
    lazy var roseLabel:UILabel = {
        let title = UILabel()
        title.font = UIFont.ThemeFont.SecondaryMedium
        title.textColor = UIColor.ThemeLabel.colorMedium
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configBarItemUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configBarItemUI() {
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(bg)
        bg.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        bg.addSubViews([titleLabel,mutibleLabel,roseLabel])
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(18)
        }
        
        mutibleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(3)
            make.right.lessThanOrEqualTo(roseLabel.snp.left).offset(-5)
            make.height.equalTo(18)
        }
        
        roseLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(18)
        }
        
        roseLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        roseLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    func bindWithEntity(_ etfItem:CoinMapEntity) {
        self.entity = etfItem
        titleLabel.text = etfItem.etfBase + etfItem.etfMultiple + etfItem.etfSide
        if etfItem.etfSide == "S" {
            mutibleLabel.textColor = UIColor.ThemeState.fail
            mutibleLabel.text = "[\(etfItem.etfMultiple)\("etf_multipleS".localized())]"
        }else {
            mutibleLabel.textColor = UIColor.ThemeState.success
            mutibleLabel.text = "[\(etfItem.etfMultiple)\("etf_multipleL".localized())]"
        }
    }
    
    func bindTicker(tick :TickItem) {
        roseLabel.textColor = tick.roseTxtColor
        roseLabel.text = tick.rose + "%"
    }
    
    @objc func etfBarItemClicked(bar:UIButton) {
        EXNavigationHandler.sharedHandler.commandTradingCoin(entity.symbol, "buy")
    }
}

class EXRecommendETFBar: UIView {
    typealias BarTapBlock = (CoinMapEntity) -> ()
    var onBarTapBlock:BarTapBlock?
    var etfItems:[EXBarItem] = []
    
    var stackContainer:UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 5
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configBars()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configBars() {
        self.addSubview(stackContainer)
        stackContainer.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func updateWithEntity(entity:CoinMapEntity) {
        if stackContainer.arrangedSubviews.count > 0 {
            etfItems.removeAll()
            stackContainer.removeAllArrangedSubviews()
        }
        for etf in entity.etfUpAndDown {
            let etfItem = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(etf.lowercased())
            if etfItem.symbol.count > 0 {
                let etfBar = EXBarItem.init()
                etfBar.bindWithEntity(etfItem)
                stackContainer.addArrangedSubview(etfBar)
                self.etfItems.append(etfBar)
            }
        }
    }
    
    func bindJumpBarTicker(symbol:String,ticker:EXKlineTictModel) {
        guard let tick = ticker.tick else {return }
        
        for item in etfItems {
            if item.entity.symbol == symbol {
                item.bindTicker(tick: tick)
            }
        }
    }
}
