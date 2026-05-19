//
//  TransactionDetailsTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/27.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class TransactionDetailsTC: UITableViewCell {

    //Time label
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetTextColor(UIColor.ThemekLine.labcolorLite, fontSize: 12)
        label.text = "--"
        return label
    }()
    
    //quantity
    lazy var numLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetTextColor(UIColor.ThemekLine.labcolorLite, fontSize: 12)
        label.layoutIfNeeded()
        label.textAlignment = .right
        label.text = "--"
        return label
    }()
    
    //price
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetTextColor(UIColor.ThemekLine.labcolorLite, fontSize: 12)
        label.text = "--"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell(UIColor.ThemekLine.viewBg)
        contentView.addSubViews([timeLabel,numLabel,priceLabel])
        addConstraints()
    }
    
    func addConstraints() {
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalTo(priceLabel.snp.left).offset(-10)
            make.height.equalTo(13)
            make.centerY.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.snp.centerX)
            make.height.equalTo(13)
            make.centerY.equalToSuperview()
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.left.equalTo(priceLabel.snp.right).offset(10)
            make.height.equalTo(13)
            make.centerY.equalToSuperview()
        }
    }
    
    func setCellWithEntity(_ entity : EXTickDataItem?,volDecimal:Int = 8,priceDecimal:Int = 8){
        if let item = entity {
            setCell(time: item.time,
                    volume: item.vol.decimalString1(volDecimal),
                    price: item.price.decimalString1(priceDecimal),
                    priceTextColor: item.side == "BUY" ? UIColor.ThemekLine.up : UIColor.ThemekLine.down)
        }else {
            
            setCell(time: "--",
                    volume: "--",
                    price: "--",
                    priceTextColor: UIColor.ThemekLine.labcolorMedium)
        }
    }
    
    func setCell(time:String,volume:String,price:String, priceTextColor:UIColor){
        
        timeLabel.text = time
        numLabel.text = volume
        priceLabel.text = price
        priceLabel.textColor = priceTextColor
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

class TransactionDetailsV : UIView{
    
    //Time label
    lazy var timeLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetTextColor(UIColor.ThemekLine.labcolorDark, fontSize: 11)
        label.text = LanguageTools.getString(key: "kline_text_dealTime")
        return label
    }()
    
    //price
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetTextColor(UIColor.ThemekLine.labcolorDark, fontSize: 11)
        label.layoutIfNeeded()
        label.text = LanguageTools.getString(key: "contract_text_price")
        return label
    }()
    
    //quantity
    lazy var numLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetTextColor(UIColor.ThemekLine.labcolorDark, fontSize: 11)
        label.textAlignment = .right
        label.text = LanguageTools.getString(key: "charge_text_volume")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemekLine.viewBg
        addSubViews([timeLabel,priceLabel,numLabel])
        addConstraints()
    }
    
    func addConstraints() {
//        dealLabel.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(10)
//            make.left.equalToSuperview().offset(10)
//        }
        
//        let offsetX = (SCREEN_WIDTH - 20)/8
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(priceLabel.snp.left).offset(-10)
            make.height.equalTo(13)
            make.bottom.equalToSuperview().offset(-5)
        }

        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(-15)
            make.height.equalTo(13)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        numLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(priceLabel.snp.right).offset(10)
            make.height.equalTo(13)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
    
//    func setView(_ buy : String , sell : String){
//
//        priceLabel.text = priceLabel.text! + "(\(buy))"
//        numLabel.text = numLabel.text! + "(\(sell))"
//
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

