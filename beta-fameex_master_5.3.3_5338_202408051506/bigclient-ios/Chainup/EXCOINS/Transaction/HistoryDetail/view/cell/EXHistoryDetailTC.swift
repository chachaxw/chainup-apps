//
//  EXHistoryDetailTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/3/10.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit


class EXHistoryDetailTC: UITableViewCell {
    
    lazy var dealTimeView : EXHistoryDetailTCView = {
        let view = EXHistoryDetailTCView()
        view.extUseAutoLayout()
        view.setLeft("charge_text_date".localized())
        return view
    }()
    
    lazy var dealPriceView : EXHistoryDetailTCView = {
        let view = EXHistoryDetailTCView()
        view.extUseAutoLayout()
//        view.setLeft("transaction_text_dealPrice".localized())
        return view
    }()
    
    lazy var dealNumView : EXHistoryDetailTCView = {
        let view = EXHistoryDetailTCView()
        view.extUseAutoLayout()
//        view.setLeft("transaction_text_dealNum".localized())
        return view
    }()
    
    lazy var poundageView : EXHistoryDetailTCView = {
        let view = EXHistoryDetailTCView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extSetCell()
        contentView.addSubViews([dealTimeView,dealPriceView,dealNumView,poundageView,lineV])
        dealTimeView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalToSuperview().offset(15)
            make.height.equalTo(14)
        }
        dealPriceView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(dealTimeView.snp.bottom).offset(15)
            make.height.equalTo(14)
        }
        dealNumView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(dealPriceView.snp.bottom).offset(15)
            make.height.equalTo(14)
        }
        poundageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(dealNumView.snp.bottom).offset(15)
            make.height.equalTo(14)
        }
        lineV.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setCell(_ entity : EXHistoryDetailEntity,symbol:String){
        let coinmap = EXAppMarketManager.sharedInstance.getCoinMapEntityBySymbol(symbol)
        
        dealTimeView.setRight(DateTools.strToTimeString(entity.time_long, dateFormat: "MM-dd HH:mm:ss"))
        
        dealPriceView.setRight(entity.price.formatAmountUseDecimal(coinmap.price))
        
        dealNumView.setRight(entity.volume.formatAmountUseDecimal(coinmap.volume))
        
        poundageView.setLeft("withdraw_text_fee".localized() + "(\(entity.feeCoin.aliasName().uppercased()))")
        //Qiu Liangding, with a precision of 8 digits for handling fees and total transaction amount
        poundageView.setRight(entity.fee.formatAmountUseDecimal("8"))
    }
    
    required init?(coder: NSCoder) {
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

class EXHistoryDetailTCView: UIView {
    
    lazy var leftLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()
    
    lazy var rightLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([leftLabel,rightLabel])
        let width = (SCREEN_WIDTH - 30) / 2
        leftLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(width)
            make.left.equalToSuperview()
        }
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(width)
            make.right.equalToSuperview()
        }
    }
    
    func setLeft(_ text : String){
        leftLabel.text = text
    }
    
    func setRight(_ text : String){
        rightLabel.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


