//
//  EXOrderNowCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/30.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXOrderNowCell: UITableViewCell {
    
    lazy var container:UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()
    
    lazy var priceNow:UILabel = {
        let label = UILabel()
        label.font = .Ex.medium(16)
        label.textColor = .Ex.kLine.up1
        label.text = "--"
        return label
    }()
    
    lazy var rmb:UILabel = {
        let label = UILabel()
        label.font = .Ex.regular(12)
        label.textColor = .Ex.text2
        label.text = "--"
        return label
    }()
    
    lazy var netWorth:UILabel = {
        let label = UILabel()
        label.font = .Ex.regular(10)
        label.textColor = .Ex.text1
        label.text = "--"
        return label
    }()
    
    lazy var newWorthBtn:UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.isHidden = true
        btn.setImage(UIImage.themeImageNamed(imageName: "public_hint"), for: .normal)
        btn.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        btn.addTarget(self, action: #selector(clickNetWorth), for: .touchUpInside)
        return btn
    }()
    
    lazy var netWorthBg:UIView = {
        let etfContainer = UIView()
        etfContainer.isHidden = true 
        return etfContainer
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extSetCell(.clear, selStyle: .none, isRemoveSelectedBackgroundView: true)
        configTickerUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configTickerUI() {
        netWorthBg.addSubview(netWorth)
        netWorthBg.addSubview(newWorthBtn)
        netWorth.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        newWorthBtn.snp.makeConstraints { (make) in
            make.left.equalTo(netWorth.snp.right)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }

        self.contentView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
        }
        container.addArrangedSubview(priceNow)
        container.addArrangedSubview(rmb)
        container.addArrangedSubview(netWorthBg)
        netWorthBg.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(14)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindTicker(tick:EXKlineTictModel,symbol:String) {
        
        guard let close = tick.tick?.close else {
            priceNow.text = "--"
            rmb.text = "--"
            return
        }
        let entity = EXAppMarketManager.sharedInstance.getCoinMapEntityByName(symbol)
        var tickerNow = close
        
        if let i = Int(entity.price){//Default Precision
            if let rst = (close as NSString).decimalString1(i) {
                tickerNow = rst
            }
        }
        
        priceNow.text = tickerNow
        priceNow.textColor = tick.tick?.roseTxtColor
        let marketR = EXAppMarketManager.sharedInstance.getMarketRight(symbol)
        let t = EXAppMarketManager.sharedInstance.getCoinExchangeRate(marketR)
        if let rst = NSString.init(string:close).multiplyingBy1(t.1, decimals: t.2){
            rmb.text = "≈\(t.0)" + rst
        }
    }
    
    func bindNetValue(value:String) {
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || value == "--" {
            netWorth.text = "--"
            newWorthBtn.isHidden = true
            return
        }
        if newWorthBtn.isHidden {
            newWorthBtn.isHidden = false
        }

        netWorth.text = "etf_text_networth".localized() + ":\(value)"
    }
    
    func hideETF(_ hide:Bool) {
        netWorthBg.isHidden = hide
    }
    
    //Click Net Value
    @objc func clickNetWorth(){
        let alert = EXNormalAlert()
        alert.configSigleAlert(title: "", message: "etf_text_networthPrompt".localized())
        //show
        EXAlert.showAlert(alertView: alert)
    }
    
}

