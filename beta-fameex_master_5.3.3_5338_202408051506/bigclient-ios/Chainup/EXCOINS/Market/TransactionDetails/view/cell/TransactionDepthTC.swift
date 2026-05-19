//
//  TransactionDepthTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/9/14.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class TransactionDepthTC: UITableViewCell {

//    //Bid 
//    lazy var buyLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.layoutIfNeeded()
//        label.extSetTextColor(UIColor.ThemekLine.labcolorMedium, fontSize: 12)
//        return label
//    }()
    
    //Purchase quantity
    lazy var buyNumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.extSetTextColor(UIColor.ThemekLine.labcolorLite, fontSize: 12)
        return label
    }()
    
    //Purchase price
    lazy var buyPriceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textAlignment = .right
        label.extSetTextColor(UIColor.ThemekLine.up, fontSize: 12)
        return label
    }()
    
    //Selling price
    lazy var sellPriceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.extSetTextColor(UIColor.ThemekLine.down, fontSize: 12)
        return label
    }()
    
    //Number of selling orders
    lazy var sellNumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textAlignment = .right
        label.extSetTextColor(UIColor.ThemekLine.labcolorLite, fontSize: 12)
        return label
    }()
    
    //Selling orders
    lazy var sellLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textAlignment = .right
        label.extSetTextColor(UIColor.ThemekLine.labcolorMedium, fontSize: 12)
        return label
    }()
    
//    //Buying background
//    lazy var buyBackV : UIView = {
//        let view = UIView()
//        view.extUseAutoLayout()
//        view.backgroundColor = UIColor.ThemekLine.up
//        view.alpha = 0.15
//        return view
//    }()
//
//    //Selling Background
//    lazy var sellBackV : UIView = {
//        let view = UIView()
//        view.extUseAutoLayout()
//        view.backgroundColor = UIColor.ThemekLine.down
//        view.alpha = 0.15
//        return view
//    }()
    
    lazy var buyLayer:CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.ThemekLine.up15.cgColor
        return layer
    }()
    
    lazy var sellLayer:CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.ThemekLine.down15.cgColor
        return layer
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.ThemekLine.viewBg
        contentView.backgroundColor = UIColor.ThemekLine.viewBg
        contentView.addSubViews([buyNumLabel,buyPriceLabel,sellPriceLabel,sellNumLabel,sellLabel])
        addConstraints()
        self.extSetCell(UIColor.ThemekLine.viewBg)
        self.layer.addSublayer(buyLayer)
        self.layer.addSublayer(sellLayer)
    }
    
    func addConstraints() {
//        buyLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(10)
//            make.centerY.equalToSuperview()
//            make.height.equalTo(13)
//            make.right.equalTo(buyNumLabel.snp.left).offset(-10)
//        }
        buyNumLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        buyPriceLabel.snp.makeConstraints { (make) in
            make.right.equalTo(contentView.snp.centerX).offset(-5)
            make.centerY.equalTo(buyNumLabel)
            make.height.equalTo(13)
            make.left.equalTo(buyNumLabel.snp.right).offset(10)
        }
        sellPriceLabel.snp.makeConstraints { (make ) in
            make.left.equalTo(contentView.snp.centerX).offset(5)
            make.centerY.equalTo(buyNumLabel)
            make.height.equalTo(13)
            make.right.equalTo(sellNumLabel.snp.left).offset(-10)
        }
        sellNumLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.height.equalTo(buyNumLabel)
        }
        sellLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.centerY.height.equalTo(buyNumLabel)
            make.left.equalTo(sellNumLabel.snp.right).offset(10)
        }
//        buyBackV.snp.makeConstraints { (make) in
//            make.right.equalTo(contentView.snp.centerX)
//            make.bottom.top.equalToSuperview()
//            make.width.equalTo(0)
//        }
//        sellBackV.snp.makeConstraints { (make) in
//            make.left.equalTo(contentView.snp.centerX)
//            make.bottom.top.equalToSuperview()
//            make.width.equalTo(0)
//        }
        buyLayer.frame = CGRect(x: SCREEN_WIDTH/2 - 1 , y: 0, width: 0, height: 30)
        sellLayer.frame = CGRect(x: SCREEN_WIDTH/2 + 1, y: 0, width: 0, height: 30)
    }
    
    func setCell(_ entity : TransactionDepthEntity,index : Int,asksAlllength:String , buysAlllength : String){
        var buyswidth : CGFloat = 0
//        buyLabel.text = "\(index + 1)"
        buyNumLabel.text = entity.buysNum
        buyPriceLabel.text = entity.buys
        if NumberHandler.handleDouble(buysAlllength.count) > 0{
            if let t = NSString.init(string: entity.buyslength).dividing(by: buysAlllength, decimals: 18){
                buyswidth = CGFloat(NumberHandler.handleDouble(t)) * (SCREEN_WIDTH - 20)/2
            }
        }
//        buyBackV.snp.updateConstraints { (make) in
//            make.width.equalTo(buyswidth)
//        }
        var sellwidth : CGFloat = 0
        if NumberHandler.handleDouble(asksAlllength.count) > 0{
            if let t = NSString.init(string: entity.askslength).dividing(by: asksAlllength, decimals: 18){
                sellwidth = CGFloat(NumberHandler.handleDouble(t)) * (SCREEN_WIDTH - 20)/2
            }
        }
//        sellLabel.text = "\(index + 1)"
        sellNumLabel.text = entity.asksNum
        sellPriceLabel.text = entity.asks
        
        buyLayer.frame = CGRect(x:SCREEN_WIDTH/2 - buyswidth - 1, y: 0, width: buyswidth, height:30)
        sellLayer.frame = CGRect(x: SCREEN_WIDTH/2 + 1, y: 0, width: sellwidth, height: 30)

//        sellBackV.snp.updateConstraints { (make) in
//            make.width.equalTo(sellwidth)
//        }
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

class TransactionDepthTV : UIView{
    
    //Bid 
//    lazy var buyLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.layoutIfNeeded()
//        label.extSetText(LanguageTools.getString(key: "buy"), textColor: UIColor.ThemekLine.labcolorMedium, fontSize: 12)
//        return label
//    }()
    
    //Purchase quantity
    lazy var buyNumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textAlignment = .left
        label.text = "charge_text_volume".localized()
        label.textColor = UIColor.ThemekLine.labcolorDark
        label.minimumRegular()
        return label
    }()
    
    //price
    lazy var priceLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textAlignment = .center
        label.text = "contract_text_price".localized()
        label.textColor = UIColor.ThemekLine.labcolorDark
        label.minimumRegular()
        return label
    }()
    
    //Number of selling orders
    lazy var sellNumLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.textAlignment = .right
        label.text = "charge_text_volume".localized()
        label.textColor = UIColor.ThemekLine.labcolorDark
        label.minimumRegular()
        return label
    }()
    
    //Selling orders
//    lazy var sellLabel : UILabel = {
//        let label = UILabel()
//        label.extUseAutoLayout()
//        label.layoutIfNeeded()
//        label.textAlignment = .right
//        label.extSetText(LanguageTools.getString(key: "sell"), textColor: UIColor.ThemekLine.labcolorMedium, fontSize: 12)
//        return label
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.ThemekLine.viewBg
        addSubViews([buyNumLabel,priceLabel,sellNumLabel])
        addConstraints()
    }
    
    func addConstraints() {
//        buyLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(10)
//            make.bottom.equalToSuperview().offset(-5)
//            make.height.equalTo(13)
//            make.right.equalTo(buyNumLabel.snp.left).offset(-10)
//        }
        buyNumLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(13)
            make.centerY.equalToSuperview()
        }
        priceLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.height.equalTo(buyNumLabel)
        }
        sellNumLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.bottom.height.equalTo(buyNumLabel)
        }
//        sellLabel.snp.makeConstraints { (make) in
//            make.right.equalToSuperview().offset(-10)
//            make.bottom.height.equalTo(buyLabel)
//            make.left.equalTo(buyLabel.snp.right).offset(10)
//        }
    }
    
    func setView(_ baseCoin : String , marketCoin : String){
        buyNumLabel.text = LanguageTools.getString(key: "quantity") + "(\(baseCoin))"
        sellNumLabel.text = buyNumLabel.text
        priceLabel.text = LanguageTools.getString(key: "price") + "(\(marketCoin))"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

