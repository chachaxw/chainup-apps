//
//  EXHistoryEntrustTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXHistoryEntrustTC: UITableViewCell {

    //business
    lazy var buytypeLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(16), textColor: .Ex.kLine.up1)
        label.extUseAutoLayout()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    //Coin pair name
    lazy var nameLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(16), textColor: .Ex.text1)
        label.extUseAutoLayout()
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    //Transaction type
    lazy var typeLabel : UILabel = {
        let label = UILabel(font: .Ex.regular(12), textColor: .Ex.text2)
        label.extUseAutoLayout()
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    //time
    lazy var timeView : EXHistoryEntrustDetailView = {
        let view = EXHistoryEntrustDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    //quantity
    lazy var volumView : EXHistoryEntrustDetailView = {
        let view = EXHistoryEntrustDetailView()
        view.extUseAutoLayout()
        view.nameLabel.textAlignment = .center
        view.volumLabel.textAlignment = .center
        return view
    }()
    
    //price
    lazy var priceView : EXHistoryEntrustDetailView = {
        let view = EXHistoryEntrustDetailView()
        view.extUseAutoLayout()
        view.nameLabel.textAlignment = .right
        view.volumLabel.textAlignment = .right
        return view
    }()
    
    //Total transaction amount
    lazy var dealTotalAmountView : EXHistoryEntrustDetailView = {
        let view = EXHistoryEntrustDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    //Actual transaction
    lazy var dealView : EXHistoryEntrustDetailView = {
        let view = EXHistoryEntrustDetailView()
        view.extUseAutoLayout()
        view.nameLabel.textAlignment = .center
        view.volumLabel.textAlignment = .center
        return view
    }()
    
    //Average transaction price
    lazy var averageView : EXHistoryEntrustDetailView = {
        let view = EXHistoryEntrustDetailView()
        view.extUseAutoLayout()
        view.nameLabel.textAlignment = .right
        view.volumLabel.textAlignment = .right
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = .Ex.fill4
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
     
        addSubViews([buytypeLabel,nameLabel,typeLabel,
                     timeView,volumView,priceView,
                     dealTotalAmountView,dealView,averageView,lineV])

        ///
        buytypeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(22)
            make.left.equalToSuperview().offset(16)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(buytypeLabel.snp.right).offset(4)
            make.height.equalTo(20)
            make.centerY.equalTo(buytypeLabel)
        }
        typeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(buytypeLabel)
            make.right.equalToSuperview().offset(-16)
            make.left.greaterThanOrEqualTo(nameLabel.snp.right)
        }

         ///
        timeView.snp.makeConstraints { make in
            make.top.equalTo(buytypeLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(35)
        }
        volumView.snp.makeConstraints { (make) in
            make.left.equalTo(timeView.snp.right).offset(10)
            make.centerY.width.height.equalTo(timeView)
        }
        priceView.snp.makeConstraints { (make) in
            make.left.equalTo(volumView.snp.right).offset(10)
            make.centerY.width.height.equalTo(timeView)
            make.right.equalToSuperview().offset(-16)
        }
        
        ///
        dealTotalAmountView.snp.makeConstraints { (make) in
            make.top.equalTo(timeView.snp.bottom).offset(19)
            make.centerX.height.width.equalTo(timeView)
        }
        dealView.snp.makeConstraints { (make) in
            make.left.equalTo(dealTotalAmountView.snp.right).offset(10)
            make.centerY.height.width.equalTo(dealTotalAmountView)
        }
        averageView.snp.makeConstraints { (make) in
            make.left.equalTo(dealView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.centerY.width.height.equalTo(dealView)
        }
        
        ///
        lineV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : EXCurrentEntrustEntity){
        let symbol = entity.baseCoin.lowercased()+entity.countCoin.lowercased()
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
        if entity.side == "BUY"{//buy
            buytypeLabel.textColor = UIColor.ThemekLine.up
            buytypeLabel.text = LanguageTools.getString(key: "otc_text_tradeObjectBuy")
        }else{
            buytypeLabel.textColor = UIColor.ThemekLine.down
            buytypeLabel.text = LanguageTools.getString(key: "otc_text_tradeObjectSell")
        }
        
        nameLabel.text = entity.getShowName()
        typeLabel.text = entity.status_text

        timeView.setName("charge_text_date".localized())
        timeView.setVolum(DateTools.strToTimeString(entity.time_long, dateFormat: "MM/dd HH:mm:ss"))
        
        volumView.setName(LanguageTools.getString(key: "charge_text_volume") + "(\(entity.baseCoin.aliasName()))")
        volumView.setVolum(entity.volume.formatAmountUseDecimal(coinmap.volume))
        
        priceView.setName(LanguageTools.getString(key: "contract_text_price") + "(\(entity.countCoin.aliasName()))")
        if entity.type == "2"{//market price
            priceView.setVolum(LanguageTools.getString(key: "contract_action_marketPrice"))
        }else{
            priceView.setVolum(entity.price.formatAmountUseDecimal(coinmap.price))
        }
        
        dealView.setName(LanguageTools.getString(key: "contract_text_dealDone") + "(\(entity.baseCoin.aliasName()))")
        dealView.setVolum(entity.deal_volume.formatAmountUseDecimal(coinmap.volume))
        
        averageView.setName(LanguageTools.getString(key: "contract_text_dealAverage") + "(\(entity.countCoin.aliasName()))")
        averageView.setVolum(entity.avg_price.formatAmountUseDecimal(coinmap.price))
        
        dealTotalAmountView.setName(LanguageTools.getString(key: "noun_order_GMV") + "(\(entity.countCoin.aliasName()))")
        dealTotalAmountView.setVolum(entity.deal_money.formatAmountUseDecimal("8"))
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

        // Configure the view for the selected state
    }

}

class EXHistoryEntrustDetailView : UIView {
    
    lazy var nameLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(12), textColor: .Ex.text2)
        label.extUseAutoLayout()
        return label
    }()
    
    lazy var volumLabel : UILabel = {
        let label = UILabel(font: .Ex.medium(14), textColor: .Ex.text1)
        label.extUseAutoLayout()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([nameLabel,volumLabel])
        nameLabel.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
        }
        volumLabel.snp.makeConstraints { (make) in
            make.top.greaterThanOrEqualTo(nameLabel.snp.bottom)
            make.bottom.left.right.equalToSuperview()
           
        }
    }
    
    func setName(_ name : String){
        nameLabel.text = name
    }
    
    func setVolum(_ volum : String){
        volumLabel.text = volum
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

