//
//  EXHistoryDetailView.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
enum EXHistoryDetailType {
    case coin
    case lever
}

class EXHistoryDetailView: UIView {
    
    var entity = EXCurrentEntrustEntity()
    
    var leverEntity = EXLeverageHistoryDetailModel()
    
    var tableViewRowDatas : [EXHistoryDetailEntity] = []
    
    var tableHeadView = EXHistoryDetailHeadView()
    
    var type = EXHistoryDetailType.coin
    
    var page = 1
    
    lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.extUseAutoLayout()
        tableView.extSetTableView(self, self)
        tableView.extRegistCell([EXHistoryDetailTC.classForCoder()], ["EXHistoryDetailTC"])
        tableView.tableHeaderView = tableHeadView
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([tableView])
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableHeadView.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: 125)
        self.tableView.mj_header = EXRefreshHeaderView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.page = 1
            mySelf.getDatas()
        })
        self.tableView.mj_footer = EXRefreshFooterView (refreshingBlock: {[weak self] in
            guard let mySelf = self else{return}
            mySelf.getDatas()
        })
    }
    
    func getDatas(){
        if type == .coin{
            let symbol = entity.baseCoin.lowercased() + entity.countCoin.lowercased()
            tableHeadView.setView(entity,symbol:symbol)
            appApi.rx.request(.getTradeListByOrder(order_id: entity.id, symbol: symbol, pageSize: "20", page: "\(page)")).MJObjectMap(EXHistoryDetailAllEntity.self).subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                if mySelf.page == 1{
                    mySelf.tableViewRowDatas.removeAll()
                }
                for entity in model.trade_list{
                    mySelf.tableViewRowDatas.append(entity)
                }
                mySelf.page = mySelf.page + 1
                mySelf.tableView.reloadData()
                mySelf.endRefresh()
            }) {[weak self] (error) in
                self?.endRefresh()
            }.disposed(by: disposeBag)
        }else{
            let symbol = leverEntity.baseCoin.lowercased() + leverEntity.countCoin.lowercased()
            tableHeadView.setLeverView(leverEntity,symbol: symbol)
            appApi.rx.request(.getLeverTradeListByOrder(order_id: leverEntity.id, symbol: symbol, pageSize: "20", page: "\(page)")).MJObjectMap(EXHistoryDetailAllEntity.self).subscribe(onSuccess: {[weak self] (model) in
                guard let mySelf = self else{return}
                if mySelf.page == 1{
                    mySelf.tableViewRowDatas.removeAll()
                }
                for entity in model.trade_list{
                    mySelf.tableViewRowDatas.append(entity)
                }
                mySelf.page = mySelf.page + 1
                mySelf.tableView.reloadData()
                mySelf.endRefresh()
            }) {[weak self] (error) in
                self?.endRefresh()
            }.disposed(by: disposeBag)
        }
    }
    
    func endRefresh(){
        self.tableView.mj_header.endRefreshing()
        self.tableView.mj_footer.endRefreshing()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension EXHistoryDetailView : UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EXHistoryDetailTC = tableView.dequeueReusableCell(withIdentifier: "EXHistoryDetailTC") as! EXHistoryDetailTC
        let detailEntity = tableViewRowDatas[indexPath.row]
        if type == .coin{
            let symbol = entity.baseCoin.lowercased() + entity.countCoin.lowercased()
            cell.dealPriceView.setLeft("transaction_text_dealPrice".localized() + "(\(self.entity.countCoin.aliasName()))")
            cell.dealNumView.setLeft("transaction_text_dealNum".localized() + "(\(self.entity.baseCoin.aliasName()))")
            cell.setCell(detailEntity,symbol: symbol)

        }else{
            let symbol = leverEntity.baseCoin.lowercased() + leverEntity.countCoin.lowercased()
            cell.dealPriceView.setLeft("transaction_text_dealPrice".localized() + "(\(self.leverEntity.countCoin.aliasName()))")
            cell.dealNumView.setLeft("transaction_text_dealNum".localized() + "(\(self.leverEntity.baseCoin.aliasName()))")
            
            cell.setCell(detailEntity,symbol: symbol)

        }
        return cell
    }
}

class EXHistoryDetailHeadView : UIView{
    
    lazy var typeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadRegular
        return label
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var priceView : EXCurrentEntrustDetailView = {
        let view = EXCurrentEntrustDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var volumView : EXCurrentEntrustDetailView = {
        let view = EXCurrentEntrustDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var actualView : EXCurrentEntrustDetailView = {
        let view = EXCurrentEntrustDetailView()
        view.extUseAutoLayout()
        view.titleLabel.textAlignment = .right
        view.volumLabel.textAlignment = .right
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeNav.bg
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let width = (SCREEN_WIDTH - 30) / 3
        addSubViews([typeLabel,nameLabel,priceView,volumView,actualView,lineV])
        typeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(15)
            make.width.lessThanOrEqualTo(100)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(typeLabel.snp.right).offset(5)
            make.height.equalTo(19)
            make.centerY.equalTo(typeLabel)
            make.right.equalToSuperview().offset(-10)
        }
        priceView.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(35)
            make.top.equalTo(typeLabel.snp.bottom).offset(22)
        }
        volumView.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.centerX.equalToSuperview()
            make.height.equalTo(35)
            make.top.equalTo(typeLabel.snp.bottom).offset(22)
        }
        actualView.snp.makeConstraints { (make) in
            make.width.equalTo(width)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(35)
            make.top.equalTo(typeLabel.snp.bottom).offset(22)
        }
        lineV.snp.makeConstraints { (make) in
            make.bottom.right.left.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setView(_ entity : EXCurrentEntrustEntity, symbol:String){
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
        typeLabel.textColor = entity.side == "SELL" ? UIColor.ThemekLine.down : UIColor.ThemekLine.up
        typeLabel.text = entity.side == "SELL" ? LanguageTools.getString(key: "otc_text_tradeObjectSell") : LanguageTools.getString(key: "otc_text_tradeObjectBuy")
        nameLabel.setCoinMap(entity.getShowName())
        priceView.setView(LanguageTools.getString(key: "noun_order_GMV")+"(\(entity.countCoin.aliasName()))", volum: entity.deal_money.formatAmountUseDecimal("8"))
        volumView.setView(LanguageTools.getString(key: "contract_text_dealAverage")+"(\(entity.countCoin.aliasName()))", volum: entity.avg_price.formatAmountUseDecimal(coinmap.price))
        actualView.setView(LanguageTools.getString(key: "kline_text_volume")+"(\(entity.baseCoin.aliasName()))", volum: entity.deal_volume.formatAmountUseDecimal(coinmap.volume))
    }
    
    func setLeverView(_ entity : EXLeverageHistoryDetailModel,symbol:String){
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
        typeLabel.textColor = entity.side == "SELL" ? UIColor.ThemekLine.down : UIColor.ThemekLine.up
        typeLabel.text = entity.side == "SELL" ? LanguageTools.getString(key: "otc_text_tradeObjectSell") : LanguageTools.getString(key: "otc_text_tradeObjectBuy")
        nameLabel.setCoinMap(entity.getShowName())
        priceView.setView(LanguageTools.getString(key: "noun_order_GMV")+"(\(entity.countCoin.aliasName()))", volum: entity.deal_money.formatAmountUseDecimal("8"))
        volumView.setView(LanguageTools.getString(key: "contract_text_dealAverage")+"(\(entity.countCoin.aliasName()))", volum: entity.avg_price.formatAmountUseDecimal(coinmap.price))
        actualView.setView(LanguageTools.getString(key: "kline_text_volume")+"(\(entity.baseCoin.aliasName()))", volum: entity.deal_volume.formatAmountUseDecimal(coinmap.volume))
    }
}


