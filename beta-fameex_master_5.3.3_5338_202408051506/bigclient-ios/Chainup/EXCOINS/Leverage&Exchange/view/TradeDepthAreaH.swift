//
//  TradeDepthAreaH.swift
//  Chainup
//
//  Created by 劉軒 on 2023/10/31.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class TradeDepthMenuH:UIView {
    
    lazy var volumeBuy:UILabel = {
        let label = UILabel()
        label.textColor = .Ex.text2
        label.font = .Ex.regular(10)
        return label
    }()
    
    lazy var price:UILabel = {
        let label = UILabel()
        label.textColor = .Ex.text2
        label.font = .Ex.regular(10)
        return label
    }()
    
    lazy var volumeSell:UILabel = {
        let label = UILabel()
        label.textColor = .Ex.text2
        label.font = .Ex.regular(10)
        return label
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configMenuUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configMenuUI()
    }
    
    func configMenuUI() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(12)
        }

        contentView.addSubViews([price, volumeBuy, volumeSell])
        
        price.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        volumeSell.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        volumeBuy.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

class TradeDepthTicker:UIView {
    
    lazy var price:UILabel = {
        let label = UILabel()
        label.font = .Ex.medium(16)
        label.text = "--"
        return label
    }()
    
    lazy var rmb:UILabel = {
        let label = UILabel()
        label.textColor = .Ex.text2
        label.font = .Ex.regular(12)
        label.text = "--"
        return label
    }()
    
    //Depth button
    lazy var depthScaleBtn : EXDirectionSelector = {
        let btn = EXDirectionSelector()
        btn.backgroundColor = .Ex.special2
        btn.extSetCornerRadius(2)
        btn.iconSize = .init(width: 10, height: 10)
        btn.titleLabel.font = .Ex.regular(12)
        btn.titleLabel.textColor = .Ex.text2
        btn.contentInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return btn
    }()
    
    lazy var netWorth:UILabel = {
        let label = UILabel()
        label.font = self.themeHNMediumFont(size: 10)
        label.textColor = UIColor.ThemeLabel.colorLite
        label.text = "--"
        return label
    }()
    
    lazy var newWorthBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: .init(width: 10, height: 10)), for: .normal)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.addTarget(self, action: #selector(clickNetWorth), for: .touchUpInside)
        return btn
    }()
    
    lazy var netWorthBg:UIView = {
        let etfContainer = UIView()
        etfContainer.isHidden = true 
        return etfContainer
    }()
    
    lazy var volumeSell:UILabel = {
        let label = UILabel()
        label.textColor = .Ex.text2
        label.font = .Ex.regular(10)
        return label
    }()
    
    lazy var contentView: UIView = {
        let v = UIView()
        return v
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configMenuUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configMenuUI()
    }
    
    func configMenuUI() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(24)
        }
        contentView.addSubViews([price, rmb, netWorthBg, depthScaleBtn])
        netWorthBg.addSubViews([netWorth, newWorthBtn])
       
        price.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        rmb.snp.makeConstraints { (make) in
            make.left.equalTo(price.snp.right)
            make.bottom.equalTo(price.snp.bottom)
        }
        
        netWorthBg.snp.makeConstraints { (make) in
            make.left.equalTo(rmb.snp.right).offset(8)
            make.right.lessThanOrEqualTo(depthScaleBtn.snp.left)
            make.height.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
        
        netWorth.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.height.equalToSuperview()
        }
        
        newWorthBtn.snp.makeConstraints { (make) in
            make.left.equalTo(netWorth.snp.right)
            make.centerY.equalTo(netWorth)
            make.width.height.equalTo(16)
            make.right.equalToSuperview()
        }
        
        depthScaleBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.width.equalTo(99)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
    
    func bindTicker(tick:EXKlineTictModel,symbol:String) {
        guard let close = tick.tick?.close else {
            return
        }
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(symbol)
        price.text = close.formatAmountUseDecimal(coinmap.price)
        price.textColor = tick.tick?.roseTxtColor
        let marketR = EXAppMarketManager.sharedInstance.getMarketRight(symbol)
        let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(marketR)
        if let rst = NSString.init(string:close).multiplyingBy1(t.1, decimals: t.2){
            rmb.text = "≈\(t.0)" + rst
        }
    }
    
    func bindNetValue(value:String) {
        netWorth.text = "etf_text_networth".localized() + ":\(value)"
    }
    
    @objc func clickNetWorth(){
        let alert = EXNormalAlert()
        alert.configSigleAlert(title: "", message: "etf_text_networthPrompt".localized())
        //show
        EXAlert.showAlert(alertView: alert)
    }
    
}


class TradeDepthAreaH: EXTradeAreaBase {
    var depthDataModel:ContractWsDepthModel?

    var tableViewRowDatas1 : [EXDepthEntity] = [EXDepthEntity(),EXDepthEntity(),EXDepthEntity(),EXDepthEntity(),EXDepthEntity()]
    
    var tableViewRowDatas2 : [EXDepthEntity] = [EXDepthEntity(),EXDepthEntity(),EXDepthEntity(),EXDepthEntity(),EXDepthEntity()]
    
    var depthScale:Int = 0 {
        didSet {
            self.updateDepthScale()
        }
    }
    
    var orderPrices:[String] = [] {
        didSet {
            guard let depth = depthDataModel else {return}
            self.bindDepth(depthModel: depth, volDecimal: self.entity.volDecimal())
        }
    }
    
    lazy var tableView1 : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.sectionFooterHeight = .leastNonzeroMagnitude
        tableView.sectionFooterHeight = .leastNonzeroMagnitude
        tableView.rowHeight = 20
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var tableView2 : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.sectionFooterHeight = .leastNonzeroMagnitude
        tableView.sectionFooterHeight = .leastNonzeroMagnitude
        tableView.rowHeight = tableView1.rowHeight
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var tickerMenu:TradeDepthTicker = {
        let view = TradeDepthTicker()
        return view
    }()
    
    //16
    lazy var depthMenu:TradeDepthMenuH = {
        let view = TradeDepthMenuH()
        return view
    }()
    
    override func onCreate() {
        tableView1.extRegistCell([EXTransactionHorizontalbuyCell.classForCoder()], ["EXTransactionHorizontalbuyCell"])
        tableView2.extRegistCell([EXTransactionHorizontalsellCell.classForCoder()], ["EXTransactionHorizontalsellCell"])
        
        self.addSubViews([tickerMenu,tableView1,tableView2,depthMenu])
        configDefultDepthData()
        tickerMenu.depthScaleBtn.addTarget(self, action: #selector(scaleBtnDidTapped), for: .touchUpInside)
        tickerMenu.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }

        depthMenu.snp.makeConstraints { (make) in
            make.top.equalTo(tickerMenu.snp.bottom).offset(12)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        tableView1.snp.makeConstraints { (make) in
            make.top.equalTo(depthMenu.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalTo(self.snp.centerX)
            make.height.equalTo(tableView1.rowHeight * CGFloat(depthCellNumber()))
        }
        tableView2.snp.makeConstraints { (make) in
            make.height.top.bottom.equalTo(tableView1)
            make.right.equalToSuperview()
            make.left.equalTo(self.snp.centerX)
        }
    }
    
    //Set default values
    func configDefultDepthData() {
        let r = entity.marketName.aliasName()
        let l = entity.coinName.aliasName()
        depthMenu.price.text = "contract_text_price".localized() + "(\(r))"
        depthMenu.volumeBuy.text = "charge_text_volume".localized() + "(\(l))"
        depthMenu.volumeSell.text = "charge_text_volume".localized() + "(\(l))"
        updateDepthScale()
    }
    
    //Refresh Depth Button
    func updateDepthScale() {
        if entity.depthArray.count > depthScale {
            tickerMenu.depthScaleBtn.titleLabel.text =  entity.depthArrayShow[depthScale] //  entity.depthArray[depthScale]
           // tickerMenu.depthScaleBtn.titleLabel.text = "kline_action_depth".localized() + "\(entity.depthArray[depthScale])"
        }
    }
}

extension TradeDepthAreaH {
    
    func resetDepthRowData() {
        tableViewRowDatas1.removeAll()
        tableViewRowDatas2.removeAll()

        for _ in 0..<depthCellNumber() {
            tableViewRowDatas1.append(EXDepthEntity())
            tableViewRowDatas2.append(EXDepthEntity())
        }
    }
    
    //Refresh entity
    func reload(_ entity:CoinMapEntity) {
        self.entity = entity
        self.orderPrices.removeAll()
        resetDepthRowData()
        tableView1.reloadData()
        tableView2.reloadData()
        configDefultDepthData()
        handleETF()
    }
    
    func handleETF() {
        tickerMenu.netWorthBg.isHidden = (entity.etfOpen == "0")
    }
    
    //Refresh the latest price
    func bindTicker(tick:EXKlineTictModel) {
        tickerMenu.bindTicker(tick: tick, symbol: entity.name)
        self.priceNow = tick.tick?.close
//Print ("Horizontal Price  (self. priceNow)")
    }
    
    //Refresh Net Value
    func updateNetWorth(value:String) {
        tickerMenu.bindNetValue(value: value)
    }
    
    func depthCellNumber() -> Int {
        return 6
    }
    
    //Refresh disk port
    func bindDepth(depthModel:ContractWsDepthModel, priceDecimal: Int = 4, volDecimal: Int = 4) {
        self.resetDepthRowData()
        self.depthDataModel = depthModel
        let depthItem = depthModel.depthDatas
        var max:CGFloat = 0.00000001
        let bidAry = depthItem.reversed().filter { item -> Bool in
            return item.type == .bid
        }
        let askAry = depthItem.filter { item -> Bool in
            return item.type == .ask
        }

        let minCount = 6
        let buysN = min(minCount, bidAry.count)
        let asksN = min(minCount, askAry.count)
        
        let bidsMax = bidAry.prefix(buysN).reduce(0.0) { $0 + $1.amount }
        let asksMax = askAry.prefix(asksN).reduce(0.0) { $0 + $1.amount }
        max = max > bidsMax ? max : bidsMax
        max = max > asksMax ? max : asksMax
        
        //5 in total
        //seller
        var depth = 0
        if entity.depthArray.count > depthScale {
            depth = entity.depthArray[depthScale]
        }
        for i in 0..<asksN {
            let item = askAry[i]
            tableViewRowDatas2[i].setEntity(item.value, xnum: item.amount, color: .Ex.kLine.down1, depthSum:Double(max), entityDepth: depth,orderAry: self.orderPrices, volDecimal: volDecimal)
        }
        
        //buyer
        for i in 0..<buysN {
            let item = bidAry[i]
            tableViewRowDatas1[i].setEntity(item.value, xnum: item.amount, color: .Ex.kLine.up1, depthSum:Double(max), entityDepth: depth,orderAry: self.orderPrices, volDecimal: volDecimal)
        }
        if tableViewRowDatas1.count > 0 {
            let buyItem = tableViewRowDatas1[0].price
            if buyItem.count > 0 {
                self.firstBuy = (buyItem == "--") ? "0" : buyItem
            }
        }

        if tableViewRowDatas2.count > 0 {
            let sellItem = tableViewRowDatas2[0].price
            if sellItem.count > 0 {
                self.firstSell =  (sellItem == "--") ? "0" : sellItem
            }
        }
        
        self.tableView1.reloadData()
        self.tableView2.reloadData()
    }
    
    @objc func scaleBtnDidTapped() {
        self.onDepthScaleBlock?()
    }
}

extension TradeDepthAreaH : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableView1{
            let entity = tableViewRowDatas1[indexPath.row]
            let cell : EXTransactionHorizontalbuyCell = tableView.dequeueReusableCell(withIdentifier: "EXTransactionHorizontalbuyCell") as! EXTransactionHorizontalbuyCell
            cell.type = .horizontalbuy
            cell.setCell(entity)
            cell.color = .Ex.kLine.up1
            return cell
        }else{
            let entity = tableViewRowDatas2[indexPath.row]
            let cell : EXTransactionHorizontalsellCell = tableView.dequeueReusableCell(withIdentifier: "EXTransactionHorizontalsellCell") as! EXTransactionHorizontalsellCell
            cell.type = .horizontalsell
            cell.setCell(entity)
            cell.color = .Ex.kLine.down1
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == tableView1{
            let entity = tableViewRowDatas1[indexPath.row]
            self.clickDepthBlock?(entity)
        }else{
            let entity = tableViewRowDatas2[indexPath.row]
            self.clickDepthBlock?(entity)
        }
    }
}

