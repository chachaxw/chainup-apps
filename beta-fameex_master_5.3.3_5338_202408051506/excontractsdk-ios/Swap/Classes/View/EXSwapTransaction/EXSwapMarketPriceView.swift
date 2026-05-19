//
//  SLSwapMarketPriceView.swift
//  Chainup
//
//  Created by KarlLichterVonRandoll on 2023/12/20.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
let exs_proportion_width1 : CGFloat = 135 / 375 * EXSCREEN_WIDTH
///价格五档列表 English: /List of Five Price Ranges
class EXSwapMarketPriceView: UIView {
    
    // 点击深度价格 English: Click on deep pricing
    typealias ClickRightBlock = (EXOrderBookModel) -> ()
    var clickRightBlock : ClickRightBlock?
    var decimal : Int = 0
    
    typealias ClickDepthBtnBlock = (Int) -> ()//点击深度回调 English: Click depth callback
    var clickDepthBtnBlock : ClickDepthBtnBlock?
    
    var _itemModel : EXSwapItemModel?
    var itemModel : EXSwapItemModel? {
        set {
            if newValue != nil {
                
                if newValue?.instrument_id != itemModel?.instrument_id {
                    updatePercisionBtn(itemModel: newValue, idx: 0)
                    
                    footView.contractID = newValue!.instrument_id
                }
                _itemModel = newValue
                    
                if let value = newValue!.ex_contractInfo {
                    headView.priceLabel.text = "cp_overview_text6".ex_localized() + "(" + value.quote_coin + ")"
                    headView.volumLabel.text =  "cp_overview_text8".ex_localized() + "(" + value.volumeUnit + ")"
                }
            }
        }
        get {
            _itemModel
        }
    }
    
    func updateData(fairPx:String,indexPx:String) {
        var FP = ""
        if !fairPx.isEmpty {
            if let m = itemModel{
                FP = fairPx.toPricePrecision(withContractID: m.instrument_id)
            }
           
//            let text = "cp_extra_text136".ex_localized() + " " + FP
//            let att = NSMutableAttributedString(string: text)
//            att.addAttribute(.font, value: UIFont.ThemeFont.MinimumBold, range: (text as NSString).range(of: FP))
            middleCell.markPriceValueLabel.text = FP
            middleCell.priceAlert.titleLabel.text = "cp_overview_text20".ex_localized() +
                "：\(FP)"
        }else{
            if fairPx.count == 0{
                middleCell.markPriceValueLabel.text = "--"
                middleCell.priceAlert.titleLabel.text = "cp_overview_text20".ex_localized() +
                    "：--"
            }
        }
       
        if !indexPx.isEmpty {
            if let m = itemModel{
                FP = indexPx.toPricePrecision(withContractID: m.instrument_id)
            }
           
            middleCell.priceAlert.secondTitle.text = "cp_overview_text21".ex_localized() +
                "：\(FP)"
        }
        
    }
    
    var isCoin : Bool? {
        
        get {
           return EXStoreData.storeBool(forKey: EXS_UNIT_VOL)
        }
    }
    
    var buyTableViewRowDatas : [EXOrderBookModel] = []
    var sellTableViewRowDatas : [EXOrderBookModel] = []
    
    var tableViewRowDatas : [EXOrderBookModel] = []
    var maximumDataCount = 16
    
    var _middleTCRow = -1
    var middleTCRow:Int {
        set {
            _middleTCRow = newValue
        }
        get {
            if _middleTCRow == -1 {
                
                return maximumDataCount / 2
            }
            return _middleTCRow
        }
    }
    var _depthCount = 0
    var depthCount:Int {
        set {
            _depthCount = newValue
        }
        get {
            if _depthCount == 0 {
                
                return maximumDataCount / 2
            }
            return _depthCount
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        self.backgroundColor = UIColor.ThemeView.card1
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        reloadView()
    }
    func updateHeadUnit(){
        let text = "cp_overview_text8".ex_localized() + "(" + "cp_overview_text9".ex_localized() + ")"
        if let isCoin = isCoin, isCoin == true {
            if let value = self.itemModel?.ex_contractInfo {
                headView.priceLabel.text = "cp_overview_text6".ex_localized() + "(" + value.quote_coin + ")"
                headView.volumLabel.text =  "cp_overview_text8".ex_localized() + "(" + value.volumeUnit + ")"
            }
        }else{
            headView.volumLabel.text = text
        }

       
    }
    func reloadView(){
        middleCell.clear()
        tableViewRowDatas.removeAll()
        buyTableViewRowDatas.removeAll()
        sellTableViewRowDatas.removeAll()
        for i in 0..<maximumDataCount + 1{
            if i < depthCount{
                let order = EXOrderBookModel()
                order.way = "2"
                tableViewRowDatas.append(order)
            } else {
                let order = EXOrderBookModel()
                order.way = "1"
                tableViewRowDatas.append(order)
            }
            buyTableViewRowDatas.append(EXOrderBookModel())
            
            let sell = EXOrderBookModel()
            sell.way = "2"
            sellTableViewRowDatas.append(sell)
        }
        tableView.reloadData()
       
    }
    
    // 刷新深度数据 English: Refresh depth data
    func updateDepthData(instrument_id : Int64) {
        if instrument_id == itemModel?.instrument_id {
            let buys = EXSwapPublicInfo.shared.getBidOrderBooks(maximumDataCount) ?? []
            let sells = EXSwapPublicInfo.shared.getAskOrderBooks(maximumDataCount) ?? []
            let all = buys + sells
            let max = all.map { item in
                return Double(item.qty) ?? 0
            }.max() ?? 0
             
            let maxVolume = String(max) ?? "0"
            self.setBuy(buys, max: maxVolume)
            self.setSell(sells, max: maxVolume)
            setTableViewRowDatas()

        }
    }
    
    // 清除深度数据 English: Clear depth data
    func clearDepathData() {
//        debug//print("====ws===清空深度") English: DebugPrint
        EXSwapPublicInfo.shared.clearOrderBooks()
        let maxVolume = "1"
        self.setBuy(EXSwapPublicInfo.shared.getBidOrderBooks(maximumDataCount) ?? [], max: maxVolume)
        self.setSell(EXSwapPublicInfo.shared.getAskOrderBooks(maximumDataCount) ?? [], max: maxVolume)
        setTableViewRowDatas()

    }
    
    //设置买 English: Set up purchase
    func setBuy(_ buys : [EXOrderBookModel] , max : String){
        buyTableViewRowDatas.removeAll()
        for _ in 0..<(maximumDataCount + 1){
            let buy = EXOrderBookModel()
            buy.way = "1"
            buyTableViewRowDatas.append(buy)
        }
        var buyArr : [EXOrderBookModel] = []
        if buys.count > (maximumDataCount + 1) {
            for i in 0..<(maximumDataCount + 1) {
                buyArr.append(buys[i])
            }
        } else {
            buyArr = buys
        }
        for i in 0..<buyArr.count {
            buyTableViewRowDatas[i].px = buyArr[i].px
            if isCoin == true {
                let qty = EXFormula.ticket(toCoin: buyArr[i].qty, price: buyArr[i].px, contract: itemModel!.ex_contractInfo,holdzero: true)
                let maxQty = EXFormula.ticket(toCoin: max, price: buyArr[i].px, contract: itemModel!.ex_contractInfo)
                buyTableViewRowDatas[i].qty = qty
                buyTableViewRowDatas[i].max_volume = maxQty
            } else {
                buyTableViewRowDatas[i].qty = buyArr[i].qty.toString(0)
                buyTableViewRowDatas[i].max_volume = max
            }
        }
    }
    
    //设置卖 English: Set up sales
    func setSell(_ sells : [EXOrderBookModel] , max : String){
        sellTableViewRowDatas.removeAll()
        for _ in 0..<(maximumDataCount + 1){
            let sell = EXOrderBookModel()
            sell.way = "2"
            sellTableViewRowDatas.append(sell)
        }
        var sellArr : [EXOrderBookModel] = []
        if sells.count > (maximumDataCount + 1) {
            for i in (0..<(maximumDataCount + 1)) {
                sellArr.append(sells[i])
            }
        } else {
            sellArr = sells
        }
        for i in 0..<sellArr.count {
            sellTableViewRowDatas[maximumDataCount - i].px = sellArr[i].px
            if isCoin == true {
                let qty = EXFormula.ticket(toCoin: sellArr[i].qty, price: sellArr[i].px, contract: itemModel!.ex_contractInfo,holdzero: true)
                let maxQty = EXFormula.ticket(toCoin: max, price: sellArr[i].px, contract: itemModel!.ex_contractInfo)
                sellTableViewRowDatas[maximumDataCount - i].qty = qty
                sellTableViewRowDatas[maximumDataCount - i].max_volume = maxQty
            } else {
                sellTableViewRowDatas[maximumDataCount - i].qty = sellArr[i].qty.toString(0)
                sellTableViewRowDatas[maximumDataCount - i].max_volume = max
            }
        }
        
    }
    func setTableViewRowDatasTip(){
        
            if tableViewRowDatas.count == 0 {
                return
            }
            guard let itemM = itemModel,let currentOrder = EXSwapPersonInfo.shared.getOrders(itemM.instrument_id) else {
                return
            }
            
            for depth in tableViewRowDatas {
                var orderPrice = ""
                for order in currentOrder {
                    if order.side == .buy_OpenLong || order.side == .buy_CloseShort {
                        orderPrice = order.px.newNumberFormat(decimal)
                    }else{
                        orderPrice = order.px.newNumberFormat(decimal,rownDown: false)
                    }
                    
    //                //print("order.side=\(order.side),order.px = \(order.px) -保留 \(decimal) 后 = \(orderPrice)") English: Print ("order. side=\ (order. side), order. px=\ (order. px) - retain \ (decimal) and then=\ (orderPrice)")
                    if Float(orderPrice) == Float(depth.px) {
                        depth.shouldTip = true
                    }
                }
            }
        }
    //切换开仓平仓更新盘口数据 English: Switching opening and closing positions to update opening data
    func updateMiddleTCRowData(){
        let type = self.footView.type
        switch type{
        case .defaultPan:// 默认盘口 English: Default disk port
            self.depthCount = self.maximumDataCount / 2
            self.middleTCRow = self.maximumDataCount / 2
        case .buy: // 买 English: buy
            self.depthCount = self.maximumDataCount
            self.middleTCRow =  0//self.maximumDataCount
        case .sell: //sell
            self.depthCount = self.maximumDataCount
            self.middleTCRow = self.maximumDataCount
        }
    }
    func setTableViewRowDatas(){
        tableViewRowDatas = []
        for _ in 0..<(maximumDataCount + 1){
            tableViewRowDatas.append(EXOrderBookModel())
        }
        let middleCount = maximumDataCount / 2
        switch self.footView.type {
        case .defaultPan:
            tableViewRowDatas[(middleCount+1)..<(maximumDataCount + 1)] = buyTableViewRowDatas[0..<middleCount]
            tableViewRowDatas[0..<middleCount] = sellTableViewRowDatas[(middleCount+1)..<(maximumDataCount + 1)]
        case .buy:
            tableViewRowDatas[1..<maximumDataCount + 1] = buyTableViewRowDatas[0..<(maximumDataCount) ]
        case .sell:
            tableViewRowDatas[0..<maximumDataCount] = sellTableViewRowDatas[1..<(maximumDataCount + 1)]
        }
//        if middleTCRow == 0{
//            tableViewRowDatas[1..<(maximumDataCount + 1)] = buyTableViewRowDatas[0..<maximumDataCount]
//        }else if middleTCRow == middleCount {
//            tableViewRowDatas[(middleCount+1)..<(maximumDataCount + 1)] = buyTableViewRowDatas[0..<middleCount]
//            tableViewRowDatas[0..<middleCount] = sellTableViewRowDatas[(middleCount+1)..<(maximumDataCount + 1)]
//        }else{
//            tableViewRowDatas[0..<maximumDataCount] = sellTableViewRowDatas[1..<(maximumDataCount + 1)]
//        }
        setTableViewRowDatasTip()
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - 高度计算 English: MARK: - Height calculation
    class func getViewHeight(maxCount: Int) -> Int{
        var total = 20 //头 English: head
        total += (6 + 20) //尾部 English: tail
        total += 20 //底部间距 English: Bottom spacing
        total += (32 + 16) //中间cell English: Intermediate cell
        total += 20 * maxCount
        return total
    }
    // MARK: - Lazy
    lazy var headView : EXSwapMarketPriceHeaderView = {
        let view = EXSwapMarketPriceHeaderView()
        return view
    }()
    var middleCell = EXSwapMarketPriceMiddleTC()
    lazy var footView : EXSwapMarketPriceFooterView = {
        let view = EXSwapMarketPriceFooterView()
        view.clickPankouBlock = {[weak self](type) in
            guard let mySelf = self else{return}

            switch type{
            case .defaultPan:// 默认盘口 English: Default disk port
                self?.depthCount = mySelf.maximumDataCount / 2
                self?.middleTCRow = mySelf.maximumDataCount / 2
                if EXKLineManager.isGreen() == true{
                    self?.footView.dishBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buyandsell"), for: .normal)
                } else {
                    self?.footView.dishBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buyandsell_1"), for: .normal)
                }
                
               // self?.footView.dishBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buyandsell"), for: .normal)
            case .buy: // 买 English: buy
                self?.depthCount = mySelf.maximumDataCount
                self?.middleTCRow =  0//mySelf.maximumDataCount
                if EXKLineManager.isGreen() == true{
                    self?.footView.dishBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buy"), for: .normal)
                }else{
                    self?.footView.dishBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_sell"), for: .normal)
                }
            case .sell: // 卖 English: sell
                self?.depthCount = mySelf.maximumDataCount
                self?.middleTCRow = mySelf.maximumDataCount
                if EXKLineManager.isGreen() == true{
                    self?.footView.dishBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_sell"), for: .normal)
                }else{
                    self?.footView.dishBtn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buy"), for: .normal)
                }
            }
            self?.setTableViewRowDatas()
        }
     
        view.precisionBtn.addTarget(self, action: #selector(clickPrecisionBtn), for: UIControl.Event.touchUpInside)

        return view
    }()
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.ext_UseAutoLayout()
        tableView.backgroundColor = UIColor.ThemeView.card1
        tableView.bounces = false
        tableView.ext_SetTableView(self, self)
        tableView.ext_RegistCell([EXSwapMarketPriceTC.classForCoder(),EXSwapMarketPriceMiddleTC.classForCoder()], ["EXSwapMarketPriceTC","EXSwapMarketPriceMiddleTC"])
        return tableView
    }()
    
    
    /// 取出前 11 条数据中的最大值 English: /Retrieve the maximum value from the first 11 data points
    func findMaxVolFromDepthData() -> (String) {
        var maxBuyVol: Double = 0
        var maxSellVol: Double = 0
        let buys = EXSwapPublicInfo.shared.getBidOrderBooks(maximumDataCount) ?? []
        let sells = EXSwapPublicInfo.shared.getAskOrderBooks(maximumDataCount) ?? []
        for i in 0..<(maximumDataCount + 1) {
            if let buyModel = buys[newSafe: i] {
                if EXSTools.handleDouble(buyModel.qty) > maxBuyVol {
                    maxBuyVol = EXSTools.handleDouble(buyModel.qty)
                }
            }
            if let sellModel = sells[newSafe: i] {
                if EXSTools.handleDouble(sellModel.qty) > maxSellVol {
                    maxSellVol = EXSTools.handleDouble(sellModel.qty)
                }
            }
        }
        return String(max(maxBuyVol, maxSellVol))
    }
    
    func updatePercisionBtn(itemModel:EXSwapItemModel?, idx:Int) {
        
        if let contractInfo = itemModel?.ex_contractInfo  {
            
            let depths = contractInfo.depthPrecisions()
            
            if depths.count > 0, idx < depths.count {
                
                footView.precisionBtn.text(content: depths[idx])
                
                let originDepth = contractInfo.coinResultVo.depth
                if  idx < originDepth.count {
                    
                    decimal = Int(originDepth[idx]) ?? 0
                }
            }
        }
    }
    
   
    @objc func clickPrecisionBtn() {
        let sheet = EXActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}

            mySelf.updatePercisionBtn(itemModel: mySelf.itemModel, idx: idx)
            
            mySelf.clickDepthBtnBlock?(idx)
        }
        sheet.actionCancelCallback =  {[weak self]() in
            guard let mySelf = self else{return}
            mySelf.footView.precisionBtn.reset()
        }
        var idx = 0
        
        if let depths = itemModel?.ex_contractInfo?.depthPrecisions() {
            
            for (index,item) in depths.enumerated() {
                if item == footView.precisionBtn.titleLabel.text {
                    idx = index
                }
            }
            
            sheet.configButtonTitles(buttons: depths, selectedIdx: idx)
        }

        EXAlert.showSheet(sheetView: sheet)
    }
}

// MARK: - functuin view

class EXSwapMarketPriceHeaderView : UIView{
    
    //价格 English: price
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.MinimumRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    //数量 English: quantity
    lazy var volumLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.MinimumRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.textAlignment = .right
        label.text = "cp_overview_text8".ex_localized() + "(" + "cp_overview_text9".ex_localized() + ")"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.card1
        exs_addSubViews([priceLabel,volumLabel])
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.greaterThanOrEqualTo(volumLabel.snp.left)
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(14)
        }
        volumLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()// .offset(-10)
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(14)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

enum EXSwapMarketPriceShowType {
    case defaultPan
    case buy
    case sell
}

class EXSwapMarketPriceFooterView : UIView{
    
    var type = EXSwapMarketPriceShowType.defaultPan
    
    typealias ClickPankouBlock = (EXSwapMarketPriceShowType) -> ()
    var clickPankouBlock : ClickPankouBlock?

    var showAlert = false
    var contractID : Int64 = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemeView.card1
        exs_addSubViews([dishBtn, precisionBtn])
        dishBtn.imageView?.contentMode = .scaleAspectFit
        dishBtn.snp.makeConstraints { (make) in
           //  make.top.equalToSuperview().offset(6)
            make.height.equalTo(20)
            make.width.equalTo(30)
            make.bottom.right.equalToSuperview()
        }
        precisionBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalTo(dishBtn.snp.left).offset(-10)
            make.centerY.equalTo(dishBtn)
            make.height.equalTo(20)
        }

    }
    
    // MARK: - 懒加载控件 English: MARK: - Lazy loading control
    /// 盘口 English: /Disk mouth
    lazy var dishBtn : UIButton = {
        let btn = UIButton()
        btn.ext_UseAutoLayout()
//        if EXKLineManager.isGreen() == true{
//            btn.setImage(UIImage.exs_themeImageNamed(imageName: "defaultpankou"), for: .normal)
//        }else{
//
//        }
        btn.backgroundColor =  UIColor.getConfigBg()//   ThemeView.card2
        btn.layer.borderColor =  UIColor.getConfigBg().cgColor
        btn.layer.borderWidth = 0.5
        btn.layer.cornerRadius = 4
        btn.setImage(UIImage.exs_themeImageNamed(imageName: "public_icon_buyandsell"), for: .normal)
        btn.exs_setEnlargeEdgeWithTop(10, left: 20, bottom: 10, right: 20)
        btn.ext_SetAddTarget(self, #selector(clickDishBtn))
        return btn
    }()
    /// 委托类型按钮 English: /Delegate Type Button
    lazy var precisionBtn : EXSDirectionButton = {
        let btn = EXSDirectionButton()
        btn.ext_UseAutoLayout()
        btn.backgroundColor =  UIColor.getConfigBg()
        btn.container.backgroundColor =  UIColor.getConfigBg()
        btn.titleLabel.font = UIFont.ThemeFont.SecondaryRegular
        btn.titleLabel.textColor = UIColor.ThemeLabel.colorMedium
        btn.layer.borderColor =  UIColor.getConfigBg().cgColor
        btn.layer.borderWidth = 0.5
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        btn.setAlighment(margin: .marginRight)
        btn.container.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        btn.titleLabel.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(btn.imageView.snp.left).offset(-8)
        }
        btn.imageView.snp.remakeConstraints { (make) in
            make.left.equalTo(btn.titleLabel.snp.right).offset(8)
            make.right.equalToSuperview().offset(-8)
            
            make.centerY.equalTo(btn.titleLabel)
        }
        return btn
    }()
    /// 点击盘口按钮 English: /Click on the disk opening button
    @objc func clickDishBtn(){
        let arr = ["cp_content_text16".ex_localized(),
                   "cp_extra_text50".ex_localized(),
                   "cp_extra_text51".ex_localized()]
        let sheet = EXActionSheetView()
        sheet.actionIdxCallback = {[weak self](idx) in
            guard let mySelf = self else{return}
            switch idx {
            case 0:
                self?.type = .defaultPan
            case 1:
                self?.type = .buy
            case 2:
                self?.type = .sell
            default:
                break
            }
            mySelf.clickPankouBlock?(mySelf.type)
        }
        //设置默认值 English: Set default values
        var idx = 0
        switch type {
        case .defaultPan:
            idx = 0
        case .buy:
            idx = 1
        case .sell:
            idx = 2
        }
        sheet.configButtonTitles(buttons:  arr,selectedIdx: idx)
        EXAlert.showSheet(sheetView: sheet)
    }
  
    
//    // 点击标记价格 English: Click to mark price
//    @objc func clickMarketPriceBtn() {
//       
//        let alert = EXSNormalAlert()
//        alert.configSigleAlert(title: "cp_overview_text20".ex_localized(), message: "cp_stoporder_text8".ex_localized())
//        //展示 English: show
//        EXAlert.showAlert(alertView: alert)
//    }
    
//    func reloadView(){
//        markPriceValueLabel.text = " --"
//        indicatorsPriceValueLabel.text = " --"
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EXSwapMarketPriceTC: UITableViewCell {
    
    //价格 English: price
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    lazy var tipView:UIView = {
       let v = UIView()
        v.corneradius = 2
        v.isHidden = true
        return v
    }()
    //数量 English: quantity
    lazy var volumLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
//        if !EXThemeManager.isNight() {
//            label.textColor = UIColor.ThemeLabel.colorMedium
//        }else{
            label.textColor = UIColor.ThemeLabel.colorLite
//        }
        label.textAlignment = .right
        label.layoutIfNeeded()
        return label
    }()
    
    //进度视图 English: Progress View
    lazy var progressView : UIView = {
        let view = UIView()
        view.ext_UseAutoLayout()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        contentView.exs_addSubViews([priceLabel,volumLabel,tipView,progressView])
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.lessThanOrEqualTo(volumLabel.snp.left)
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
        }
        tipView.snp.makeConstraints { (make) in
            make.leading.equalTo(priceLabel.snp_trailing).offset(2)
            make.centerY.equalTo(priceLabel)
            make.size.equalTo(CGSize(width: 4, height: 4))
        }
        volumLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-2)
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    func setCell(_ entity : EXOrderBookModel,pricePrecision:Int){
        priceLabel.textColor = entity.way == "1" ? UIColor.ThemekLine.up : UIColor.ThemekLine.down
        if entity.px.isEmpty {
            priceLabel.text = "--"
        }else {
            let num = String(pricePrecision)
            priceLabel.text = entity.px.exs_formatAmountUseDecimal(num,holdZero: true)
        }
        
        if !entity.qty.isEmpty {
            volumLabel.text = entity.qty
        } else {
            volumLabel.text = "--"
        }
        
        progressView.backgroundColor = priceLabel.textColor.withAlphaComponent(0.1)
        var lenght : CGFloat = 0
        if entity.max_volume != "0" , volumLabel.text != "--"{
            if let max = Double(entity.max_volume), let entityQty = Double(entity.qty), max > 0{
                let l = entityQty / max
                lenght = CGFloat(l) * exs_proportion_width1
            }
        }
        if lenght < 0 {
            lenght = 0
        }
        var x: CGFloat = exs_proportion_width1 - lenght
        if x < 0 {
            x = exs_proportion_width1
        }
        progressView.frame = CGRect(x:x , y: 0, width: lenght, height: 20)
        if !entity.qty.isEmpty {
            volumLabel.text = EXSTools.dealDataFormate(entity.qty)
        } else {
            volumLabel.text = "--"
        }
        tipView.isHidden = !entity.shouldTip
        tipView.backgroundColor = priceLabel.textColor
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if  highlighted {
            self.contentView.backgroundColor = UIColor.ThemeView.card2
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now()+0.08, execute:
            {
                self.contentView.backgroundColor = UIColor.ThemeView.card1
            })
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

class EXSwapMarketPriceMiddleTC : UITableViewCell{
    var lineFished =  false
    lazy var containerView = UIView()
    lazy var priceLabel : TopLabel = {
        let label = TopLabel()
        label.ext_UseAutoLayout()
        label.font = UIFont.ThemeFont.HeadMedium
        label.text = "--"
        label.textColor = UIColor.ThemekLine.up
        return label
    }()
    let line = UIView()
//    lazy var rateLabel : UILabel = {
//        let label = UILabel()
//        label.ext_UseAutoLayout()
//        label.font = UIFont.ThemeFont.SecondaryRegular
//        label.text = "--"
//        label.textColor = UIColor.ThemekLine.up
//
//        label.layer.cornerRadius = 1
//        label.layer.masksToBounds = true
//        return label
//    }()
    /// 标记价格 English: /Mark price
    lazy var markPricetitleLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textAlignment = .left
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.text = "cp_extra_text136".ex_localized()
        return label
    }()
    /// 标记价格 English: /Mark price
    lazy var markPriceValueLabel : UILabel = {
        let label = UILabel()
        label.ext_UseAutoLayout()
        label.textAlignment = .right
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    func clear(){
        self.markPriceValueLabel.text = "--"
        self.priceLabel.text = "--"
    }
    func updatePriceData(priceText:String,rateText:String,bgColor:UIColor) {

        if EXSTools.colorWithUpAndDownText(rateText) != nil {
            self.priceLabel.textColor = EXSTools.colorWithUpAndDownText(rateText)
        }
        self.priceLabel.text = !priceText.isEmpty ? priceText : "--"

    }
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.ext_SetCell()
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickMarketPriceBtn))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        self.contentView.backgroundColor = UIColor.ThemeView.card1
        containerView.backgroundColor = UIColor.ThemeView.card1
        contentView.exs_addSubViews([containerView])
        containerView.exs_addSubViews([priceLabel, markPricetitleLabel,markPriceValueLabel,line])
        containerView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
//            make.top.equalToSuperview().offset(6)
//            make.bottom.equalToSuperview().offset(-6)
             make.centerY.equalToSuperview()
        }
        priceLabel.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview()
        }
        markPricetitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(priceLabel.snp.bottom) //.offset(-6)
            make.bottom.equalToSuperview()
        }
        markPriceValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(markPricetitleLabel.snp.right).offset(3)
            make.top.equalTo(priceLabel.snp.bottom)//.offset(-6)
            make.bottom.equalToSuperview()
        }
        
        line.snp.makeConstraints { make in
            make.top.equalTo(markPricetitleLabel.snp.bottom).offset(2)
            make.left.equalToSuperview()
            make.right.equalTo(markPricetitleLabel.snp.right).offset(2)
            make.height.equalTo(0.5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.line.drawDashLine()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var priceAlert : EXSwapFairPriceAlert = {
        let ret = EXSwapFairPriceAlert()
        ret.configSigleAlert(title: "cp_overview_text20".ex_localized(), message: "cp_stoporder_text8".ex_localized())
        ret.secondMessageLabel.text = "cp_stoporder_text7".ex_localized()
        return ret
    }()
    // 点击标记价格 English: Click to mark price
    @objc func clickMarketPriceBtn() {
        //展示 English: show
        EXAlert.showAlert(alertView: priceAlert)
    }
}

extension EXSwapMarketPriceView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30 //多来一点 English: Have more
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == middleTCRow{
            return 50 + 4
        }else{
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maximumDataCount + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == middleTCRow {
            let cell : EXSwapMarketPriceMiddleTC = tableView.dequeueReusableCell(withIdentifier: "EXSwapMarketPriceMiddleTC") as! EXSwapMarketPriceMiddleTC
            middleCell = cell
            return cell
        }else{
            let cell : EXSwapMarketPriceTC = tableView.dequeueReusableCell(withIdentifier: "EXSwapMarketPriceTC") as! EXSwapMarketPriceTC
            let entity = tableViewRowDatas[indexPath.row]
            cell.setCell(entity,pricePrecision: decimal)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row != middleTCRow{
            self.feedbackGenerator()
            
//            let cell = tableView.cellForRow(at: indexPath) as! EXSwapMarketPriceTC
//            cell.priceLabel.font = UIFont.ThemeFont.HeadBold
////            cell.contentView.backgroundColor = UIColor.extColorWithHex("#F9F9FA")
//            DispatchQueue.main.asyncAfter(deadline: .now()+0.001, execute:
//            {
//                cell.priceLabel.font = UIFont.ThemeFont.HeadMedium
//            })
            let entity = tableViewRowDatas[indexPath.row]
            entity.px = entity.px.toString(decimal)
            if !entity.px.isEmpty, entity.px.greaterThan("0"){
                self.clickRightBlock?(entity)
            }
        }
    }
}



class TopLabel: UILabel {
    var topMargin: CGFloat // 距离顶部的距离，外界可以随意设置 English: The distance from the top can be freely set by the outside world
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        textRect.origin.y = bounds.origin.y + topMargin
        return textRect
    }
    
    override func drawText(in rect: CGRect) {
        let actualRect = textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: actualRect)
    }
    // 通过约束布局用这个 English: By constraining the layout with this
    init(topMargin: CGFloat = 0) {
        self.topMargin = topMargin
        super.init(frame: .zero)
    }
    // 通过frame 布局用这个 English: Using this through frame layout
    init(frame: CGRect,topMargin: CGFloat = 0) {
        self.topMargin = topMargin
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public extension Array where Element: Equatable {
    
    subscript (newSafe index: Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
    
    mutating func ch_removeObject(_ object: Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func ch_removeObjectsInArray(_ array: [Element]) {
        for object in array {
            self.ch_removeObject(object)
        }
    }
}

