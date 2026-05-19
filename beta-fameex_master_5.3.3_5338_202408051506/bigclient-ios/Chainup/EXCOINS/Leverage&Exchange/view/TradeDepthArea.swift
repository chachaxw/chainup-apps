//
//  TradeDepthArea.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/28.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import RxSwift
import EXKit
import SnapKit

class TradeDepthMenu:UIView {
    
    var contentInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 16) {
        didSet {
            guard contentView.superview != nil else { return }
            contentView.snp.updateConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        }
    }
    
    lazy var price:UILabel = {
        let v = UILabel()
        v.textColor = .Ex.text2
        v.font = .Ex.regular(10)
        return v
    }()
    
    lazy var volume:UILabel = {
        let v = UILabel()
        v.textColor = .Ex.text2
        v.font = .Ex.regular(10)
        return v
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    func onCreate() {
        addSubview(contentView)
        contentView.addSubViews([price, volume])
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentInsets)
        }
        price.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        volume.snp.makeConstraints { make in
            make.left.greaterThanOrEqualTo(price.snp.right).offset(4)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

class TradeDepthToolBar:UIView {
    
    var contentInsets: UIEdgeInsets = .zero {
        didSet {
            guard contentView.superview != nil else { return }
            contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(contentInsets) }
        }
    }
    
    //Depth button
    lazy var depthScaleBtn : EXDirectionSelector = {
        let v = EXDirectionSelector()
        v.backgroundColor = .Ex.special2
        v.extSetCornerRadius(2)
        v.iconSize = .init(width: 10, height: 10)
        v.titleLabel.font = .Ex.regular(12)
        v.titleLabel.textColor = .Ex.text2
        v.contentInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return v
    }()
    
    lazy var depthLayoutBtn :UIButton = {
        let v = UIButton.init(type: .custom)
        v.backgroundColor = .Ex.special2
        v.extSetCornerRadius(2)
        v.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buyandsell"), for: .normal)
        v.setEnlargeEdgeWithTop(10, left: 0, bottom: 10, right: 10)
        return v
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        onCreate()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        onCreate()
    }
    
    func onCreate() {
        addSubview(contentView)
        contentView.addSubViews([depthScaleBtn, depthLayoutBtn])
        ///
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentInsets)
        }
        depthScaleBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        depthLayoutBtn.snp.makeConstraints { make in
            make.left.equalTo(depthScaleBtn.snp.right).offset(8)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(28)
            make.height.equalTo(20)
        }
    }
}


enum TransactionPankouType {
    case defaultPan
    case buy
    case sell
}

class TradeDepthArea:EXTradeAreaBase,UITableViewDelegate,UITableViewDataSource {


    var depthLayout:Int = 0
    let rowHeight: CGFloat = 20

    var depthDataModel:ContractWsDepthModel?
    var rowDatas:[EXDepthEntity] = []
    var currentType: TransactionPankouType = .defaultPan
    var depthScale:Int = 0 {
        didSet {
            self.updateDepthScale()
        }
    }

    var orderPrices:[String] = [] {
        didSet {
            guard  let depth = depthDataModel else {return}
            self.bindDepth(depthModel: depth, volDecimal: self.entity.volDecimal())
        }
    }

    lazy var tickerHeight:CGFloat = {
        let tickerHeight:CGFloat = entity.etfOpen == "1" ? 56 : 42
        return tickerHeight
    }()

    lazy var depthMenu:TradeDepthMenu = {
        let v = TradeDepthMenu()
        return v
    }()
    
    lazy var depthToolBar:TradeDepthToolBar = {
        let v = TradeDepthToolBar()
        v.depthLayoutBtn.addTarget(self, action: #selector(layoutBtnDidTapped), for: .touchUpInside)
        v.depthScaleBtn.addTarget(self, action: #selector(scaleBtnDidTapped), for: .touchUpInside)
        return v
    }()
    
    var pankouHeightConstraint: Constraint!
    lazy var pankouTable : UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.extUseAutoLayout()
        v.extSetTableView(self, self)
        v.register(EXTransactionVerticalCell.classForCoder(), forCellReuseIdentifier: "EXTransactionVerticalCell")
        v.register(EXOrderNowCell.classForCoder(), forCellReuseIdentifier: "EXOrderNowCell")
        v.contentInsetAdjustmentBehavior = .never
        v.isScrollEnabled = false
        return v
    }()
    
    override func onCreate() {
        configDepthAreaUI()
        configDefultDepthData()
        updateTableViewHeight()
    }
    
    func configDepthAreaUI() {
        addSubViews([depthMenu, pankouTable, depthToolBar])
        ///
        depthMenu.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(12)
        }
        pankouTable.snp.makeConstraints { make in
            make.top.equalTo(depthMenu.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            self.pankouHeightConstraint = make.height.equalTo(0).constraint
        }
        depthToolBar.snp.makeConstraints { make in
            make.top.equalTo(pankouTable.snp.bottom).offset(8)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(20)
            make.bottom.equalToSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDatas.count
    }
    
    func depthCellNumber() -> Int {
     
        if orderType == .leverage {
            switch orderWay {
                case .limit: return 6
                case .market: return 6
            }
        }else{
            switch orderWay {
                case .limit: return 6
                case .market: return 6
            }
        }
    }
    
    func getOrderNowIdx() -> Int{
        
        switch currentType {
        case .defaultPan:
            return depthCellNumber()
        case .buy:
            return 0
        case .sell:
            return depthCellNumber() * 2
        }
    }
    
    func isTickerNowCell(atRow:Int)->Bool {
        if currentType == .defaultPan,atRow == depthCellNumber() {
            return true
        }else if currentType == .buy,atRow == 0 {
            return true
        }else if currentType == .sell,atRow == (rowDatas.count - 1) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var cellH = 20.0
        if isTickerNowCell(atRow: indexPath.row) {
            cellH = (entity.etfOpen == "1" ? 56 : 50)
        }
        return cellH
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isTickerNowCell(atRow: indexPath.row) {
            let cell : EXOrderNowCell = tableView.dequeueReusableCell(withIdentifier: "EXOrderNowCell") as! EXOrderNowCell
            return cell
        }else {
            let entity = self.rowDatas[indexPath.row]
            let cell : EXTransactionVerticalCell = tableView.dequeueReusableCell(withIdentifier: "EXTransactionVerticalCell") as! EXTransactionVerticalCell
            cell.type = .vertical
            cell.setCell(entity)
            if currentType == .defaultPan {
                if indexPath.row > depthCellNumber() {
                    cell.color = .Ex.kLine.up1
                }else{
                    cell.color = .Ex.kLine.down1
                }
            }else if currentType == .buy {
                cell.color = .Ex.kLine.up1
            }else if currentType == .sell {
                cell.color = .Ex.kLine.down1
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isTickerNowCell(atRow: indexPath.row) {
            return
        }else {
            let entity = rowDatas[indexPath.row]
            self.clickDepthBlock?(entity)
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}

//MARK: refresh method
extension TradeDepthArea {
    
    func configDepthCellItem() {
        self.rowDatas.removeAll()
        for _ in 0..<(depthCellNumber()*2 + 1) {
            self.rowDatas.append(EXDepthEntity())
        }
    }
    
    //Set default values
    func configDefultDepthData() {
        configDepthCellItem()
        let r = entity.marketName.aliasName()
        depthMenu.price.text = "contract_text_price".localized() + "(\(r))"
        depthMenu.volume.text = "charge_text_volume".localized()
        self.updateDepthScale()
        self.pankouTable.reloadData()
    }
    
    func getOrderCell() -> EXOrderNowCell? {
        let cell = pankouTable.cellForRow(at: IndexPath.init(row: self.getOrderNowIdx(), section: 0)) as? EXOrderNowCell
        return cell
    }
    //Refresh the latest price
    func bindTicker(tick:EXKlineTictModel) {
        guard let cell = getOrderCell() else {return}
        self.priceNow = tick.tick?.close
        cell.bindTicker(tick: tick, symbol: entity.name)
    }
    
    //Refresh disk port
    func bindDepth(depthModel:ContractWsDepthModel, priceDecimal: Int = 4, volDecimal: Int = 4) {
        configDepthCellItem()

        self.depthDataModel = depthModel
        let depthItem = depthModel.depthDatas
        var max:CGFloat = 0.00000001
        let bidAry = depthItem.reversed().filter { item -> Bool in
            return item.type == .bid
        }
        let askAry = depthItem.filter { item -> Bool in
            return item.type == .ask
        }

        let minCount = (currentType == .defaultPan) ? depthCellNumber() : depthCellNumber()*2
        let buysN = min(minCount, bidAry.count)
        let asksN = min(minCount, askAry.count)
        
        if currentType == .defaultPan {
            //A total of 11, with the latest price in the middle
            //Seller (to add in reverse)
            let bidsMax = bidAry.prefix(buysN).reduce(0.0) {$0 + $1.amount}
            let asksMax = askAry.prefix(buysN).reduce(0.0) {$0 + $1.amount}
            max = max > bidsMax ? max : bidsMax
            max = max > asksMax ? max : asksMax
        
            var depth = 0
            if entity.depthArray.count > depthScale {
                depth = entity.depthArray[depthScale]
            }
            
            for i in 0..<asksN {
                let item = askAry[i]
                rowDatas[(depthCellNumber() - 1) - i].setEntity(item.value,
                                          xnum: item.amount,
                                         color: .Ex.kLine.up1,
                                          depthSum:Double(max),
                                          entityDepth: depth,
                                          baseWidth: self.width,
                                          orderAry: self.orderPrices,
                                                                type: .sell,
                                                                volDecimal: volDecimal)
            }
            
            //buyer
            for i in 0..<buysN{
                let item = bidAry[i]
                rowDatas[i+(depthCellNumber() + 1)].setEntity(item.value,
                                        xnum: item.amount,
                                        color: UIColor.ThemekLine.up,
                                        depthSum:Double(max),
                                        entityDepth: depth,
                                        baseWidth: self.width,
                                        orderAry: self.orderPrices,
                                        type: .buy, volDecimal: volDecimal)
            }
            if rowDatas.count > (depthCellNumber() + 1) {
                let buyItem = rowDatas[depthCellNumber() + 1].price
                if buyItem.count > 0 {
                    self.firstBuy = (buyItem == "--") ? "0" : buyItem
                }
                
                let sellItem = rowDatas[depthCellNumber() - 1].price
                if sellItem.count > 0 {
                    self.firstSell =  (sellItem == "--") ? "0" : sellItem
                }
            }

        }else if currentType == .buy {
            //There are a total of 11, and the first one is the latest price
            
            let bidsMax = bidAry.prefix(buysN).reduce(0.0) {$0 + $1.amount}
            max = max > bidsMax ? max : bidsMax
            
            for i in 0..<buysN{
                let item = bidAry[i]
                rowDatas[i+1].setEntity(item.value, xnum: item.amount, color: .Ex.kLine.up1, depthSum:Double(max), entityDepth: entity.depthArray[depthScale],baseWidth: self.width,orderAry: self.orderPrices,type: .buy, volDecimal: volDecimal)
            }
        }else if currentType == .sell {
            
            let asksMax = askAry.prefix(buysN).reduce(0.0) {$0 + $1.amount}
            max = max > asksMax ? max : asksMax
            //seller
            //There are a total of 11, and the last one is the latest price
            for i in 0..<asksN {
                let item = askAry[i]
                rowDatas[(depthCellNumber()*2 - 1) - i].setEntity(item.value, xnum: item.amount, color: .Ex.kLine.down1, depthSum:Double(max), entityDepth: entity.depthArray[depthScale],baseWidth: self.width,orderAry: self.orderPrices,type: .sell, volDecimal: volDecimal)
            }
        }
        self.pankouTable.reloadData()
    }
    
    //Refresh Net Value
    func updateNetWorth(value:String) {
        guard let cell = getOrderCell() else {return}
        cell.bindNetValue(value: value)
    }
    
    //Refresh entity
    func reload(_ entity:CoinMapEntity) {
        self.entity = entity
        self.orderPrices.removeAll()
        self.updateDepthLayout(0)
        configDefultDepthData()
        updateTableViewHeight()
        handleETF()
    }
    
    func handleETF() {
        self.tickerHeight = entity.etfOpen == "1" ? 56 : 42
        guard let cell = getOrderCell() else { return }
        cell.hideETF(entity.etfOpen == "0")
    }
    
    //Refresh Depth Button
    func updateDepthScale() {
        if entity.depthArray.count > depthScale {
            depthToolBar.depthScaleBtn.titleLabel.text = entity.depthArrayShow[depthScale]
            //depthToolBar.depthScaleBtn.titleLabel.text = "kline_action_depth".localized() + " " + "\(entity.depthArray[depthScale])"
        }
    }
    
    func updateDepthLayout(_ idx:Int) {
        if idx == 0 {
            self.currentType = .defaultPan
        }else if idx == 1 {
            self.currentType = .buy
        }else if idx == 2 {
            self.currentType = .sell
        }
        
        switch currentType {
        case .defaultPan:
            if EXKLineManager.isGreen() == true{
                depthToolBar.depthLayoutBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buyandsell"), for: .normal)
            }else{
                depthToolBar.depthLayoutBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buyandsell_1"), for: .normal)
            }
            
        case .buy:
            if EXKLineManager.isGreen() == true{
                depthToolBar.depthLayoutBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buy"), for: .normal)
            }else{
                depthToolBar.depthLayoutBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_sell"), for: .normal)
            }
        case .sell:
            if EXKLineManager.isGreen() == true{
                depthToolBar.depthLayoutBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_sell"), for: .normal)
            }else{
                depthToolBar.depthLayoutBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buy"), for: .normal)
            }
        }
        if let model = self.depthDataModel {
            rowDatas.removeAll()
            self.bindDepth(depthModel: model, volDecimal: self.entity.volDecimal())
        } else {
            configDefultDepthData()
        }
    }
    
    
    func updateTableViewHeight() {
        //MARK: --- 数据源加载闪动
        pankouTable.reloadData()
        pankouTable.layoutIfNeeded()
        var height:CGFloat = 0
        for section in 0 ..< pankouTable.numberOfSections {
            for row in 0 ..< pankouTable.numberOfRows(inSection: section) {
                height += tableView(pankouTable, heightForRowAt: IndexPath(row: row, section: section))
            }
        }
        pankouHeightConstraint.update(offset: height)
    }
    
    
}

//MAR: Actions
extension TradeDepthArea {
    
    @objc func scaleBtnDidTapped() {
        self.onDepthScaleBlock?()
    }
    
    @objc func layoutBtnDidTapped() {
        self.onDepthLayoutBlock?()
    }
}

extension TradeDepthArea :EXEmptyUIProtocal{
    
    func isEmptyUI() -> Bool {
        if let cell = self.pankouTable.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? EXTransactionVerticalCell{
            guard let price = cell.priceLabel.text,let volume = cell.volumLabel.text else {
                return true
            }
            return (price == "--" && volume == "--")
        }else {
            return true
        }
    }
    
    func isEmptyData() -> Bool {
        if self.rowDatas.count > 0 {
            let item = rowDatas[0]
            return (item.price == "--" || item.num == "--")
        }
        return true
    }
}

