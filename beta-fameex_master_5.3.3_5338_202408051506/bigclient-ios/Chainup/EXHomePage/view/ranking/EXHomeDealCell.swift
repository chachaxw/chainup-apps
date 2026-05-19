//
//  EXHomeDealCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/14.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
//Deal List Style

class EXHomeDealCell: EXHomeBaseCell {
    
//    //Ranking
//    lazy var rankLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.textColor = UIColor.ThemekLine.up
//        label.font = UIFont().themeHNBoldItalicFont(size:14)
//        label.textAlignment = .center
//        return label
//    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font =  UIFont.ThemeFont.HeadMedium
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .right
        label.font = UIFont.ThemeFont.HeadMedium
        label.textColor = UIColor.ThemeLabel.colorLite
        return label
    }()
    
    lazy var turnoverLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textAlignment = .right
        label.textColor = UIColor.ThemeLabel.colorLite
        label.extSetCornerRadius(4)
        label.font = UIFont.ThemeFont.HeadMedium
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (highlighted) {
            self.contentView.backgroundColor = UIColor.ThemeView.card2
        }else{
            self.contentView.backgroundColor = UIColor.ThemeView.card1
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.ThemeView.bg
        contentView.backgroundColor = UIColor.ThemeView.bg
        self.extSetCell()
        let width = EXHomeRankNewCell.nameLabelWidth()
        contentView.addSubViews([nameLabel,priceLabel,turnoverLabel])
//        rankLabel.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().offset(15)
//            make.height.equalTo(17)
//            make.width.lessThanOrEqualTo(20)
//        }
//
        nameLabel.snp.remakeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(17)
            make.width.equalTo(width)
        }
    
        priceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(turnoverLabel.snp.left).offset(-28)
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(17)
        }
        turnoverLabel.snp.makeConstraints { (make) in
            make.width.equalTo(72)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.right.equalToSuperview().offset(-MARGIN_LEFT)
        }
    }
    
    func bindCell(_ model : EXHomeTicker){
        nameLabel.text = model.symbol.aliasName()
        let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(model.symbol)
        
        
        
        if model.symbol.isEmpty {
            priceLabel.text = "--"
        }else {
            if var p = NSString.init(string: t.1).decimalString1(t.2){
                if p.lessThanOrEqual("0") {
                    let precision = EXAppMarketManager.sharedInstance.getCoinPrecision(model.symbol)
                    p = t.1.decimalString1(precision)
                }
                priceLabel.text = p
            }
        }
        
//        print("model.symbol = \(model.symbol) t.1 = \( t.1) ,t.2 = \(t.2)")
        turnoverLabel.text = model.volume
//        if model.app_serial_number > 0 {
//            rankLabel.text = "\(model.app_serial_number)"
//            if model.app_serial_number < 4 {
//                rankLabel.textColor = UIColor.ThemekLine.up
//            }else {
//                rankLabel.textColor = UIColor.ThemeLabel.colorDark
//            }
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

