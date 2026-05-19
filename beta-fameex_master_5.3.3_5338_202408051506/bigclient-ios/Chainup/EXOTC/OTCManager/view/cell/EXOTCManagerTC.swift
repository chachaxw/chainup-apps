//
//  EXOTCManagerTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/10/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import YYWebImage

class EXOTCManagerTC: UITableViewCell {
    
    typealias ClickCheckBtnBlock = (EXOTCManagerAdListEntity) -> ()
    var clickCheckBtnBlock : ClickCheckBtnBlock?
    
    var entity = EXOTCManagerAdListEntity()

    lazy var dealLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.HeadMedium
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.HeadBold
        return label
    }()
    
    lazy var statusLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorMedium
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.layoutIfNeeded()
        return label
    }()
    
    lazy var pricingView : EXOTCManagerDetailView = {
        let view = EXOTCManagerDetailView()
        view.extUseAutoLayout()
        view.setLeft("otc_setPrice_method".localized())
        return view
    }()
    
    lazy var priceView : EXOTCManagerDetailView = {
        let view = EXOTCManagerDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var numView : EXOTCManagerDetailView = {
        let view = EXOTCManagerDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var limitView : EXOTCManagerDetailView = {
        let view = EXOTCManagerDetailView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var iconView : EXOTCManagerIconView = {
        let view = EXOTCManagerIconView()
        view.extUseAutoLayout()
        return view
    }()
    
    lazy var checkBtn : UIButton = {
        let btn = UIButton()
        btn.extUseAutoLayout()
        btn.setTitle("otc_text_adLook".localized(), for: UIControl.State.normal)
        btn.setTitleColor(UIColor.ThemeLabel.white, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.ThemeFont.BodyBold
        btn.backgroundColor = UIColor.ThemeBtn.highlight
        btn.extSetCornerRadius(1.5)
        btn.extSetAddTarget(self, #selector(clickCheckBtn))
        return btn
    }()
    
    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        self.contentView.addSubViews([dealLabel,nameLabel,statusLabel,pricingView,priceView,numView,limitView,iconView,checkBtn,lineV])
        
        dealLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(16)
            make.top.equalTo(16)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dealLabel.snp.right).offset(5)
            make.height.equalTo(16)
            make.centerY.equalTo(dealLabel)
        make.right.lessThanOrEqualTo(statusLabel.snp.left).offset(-5)
        }
        
        statusLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(14)
            make.centerY.equalTo(dealLabel)
        }
        
        pricingView.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.top.equalTo(dealLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
        }
        
        priceView.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.top.equalTo(pricingView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        
        numView.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.top.equalTo(priceView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        
        limitView.snp.makeConstraints { (make) in
            make.height.equalTo(16)
            make.top.equalTo(numView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        
        iconView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalTo(checkBtn)
            make.height.equalTo(16)
            make.right.equalTo(checkBtn.snp.left).offset(-5)
        }
        
        checkBtn.snp.makeConstraints { (make) in
            make.height.equalTo(32)
            make.width.equalTo(72)
            make.right.equalToSuperview().offset(-15)
            make.top.equalTo(limitView.snp.bottom).offset(18)
        }
        
        lineV.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.bottom.right.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        
    }
    
    func setCell(_ entity : EXOTCManagerAdListEntity){
        self.entity = entity
        dealLabel.text = entity.side == "BUY" ? "otc_text_tradeObjectBuy".localized() : "otc_text_tradeObjectSell".localized()
        dealLabel.textColor = entity.side == "BUY" ? UIColor.ThemekLine.up : UIColor.ThemekLine.down
        nameLabel.text = entity.coin.aliasName()
        statusLabel.text = entity.status_str
        if entity.priceRateType == "0"{
            pricingView.setRight("otc_custom_price".localized())
        }else{
            pricingView.setRight("otc_text_marketPrice".localized())
        }
        
        priceView.setLeft("otc_text_price".localized() + "(\(entity.payCoin))")
        priceView.setRight(entity.price.formatCurrencyMoney(entity.payCoin,format: .fiatFormat))
        
        numView.setLeft("otc_text_remainingNum".localized() + "(\(entity.coin.aliasName()))")
        numView.setRight(entity.fmsResidue())
        
        limitView.setLeft("otc_text_tradingLimits".localized() + "(\(entity.payCoin))")
        limitView.setRight(entity.minTrade.formatCurrencyMoney(entity.payCoin, format: .fiatFormat) + "-" + entity.maxTrade.formatCurrencyMoney(entity.payCoin, format: .fiatFormat))
        
        iconView.setView(entity.payments)
    }
    
    //Click on the view button
    @objc func clickCheckBtn(){
        self.clickCheckBtnBlock?(self.entity)
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

class EXOTCManagerDetailView : UIView {
    
    let leftLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.SecondaryRegular
        label.textColor = UIColor.ThemeLabel.colorMedium
        return label
    }()
    
    let rightLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.font = UIFont.ThemeFont.BodyRegular
        label.textColor = UIColor.ThemeLabel.colorLite
        label.layoutIfNeeded()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubViews([leftLabel,rightLabel])
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
            make.right.equalTo(rightLabel.snp.left).offset(-5)
        }
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(14)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    func setLeft(_ str : String){
        leftLabel.text = str
    }
    
    func setRight(_ str : String){
        rightLabel.text = str
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class EXOTCManagerIconView : UIView {
    
    lazy var oneImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.isHidden = true
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
    
    lazy var twoImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.isHidden = true
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
    
    lazy var threeImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        imgV.isHidden = true
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([oneImgV,twoImgV,threeImgV])
        oneImgV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.height.width.equalTo(16)
            make.centerY.equalToSuperview()
        }
        twoImgV.snp.makeConstraints { (make) in
            make.left.equalTo(oneImgV.snp.right).offset(10)
            make.height.width.equalTo(16)
            make.centerY.equalToSuperview()
        }
        threeImgV.snp.makeConstraints { (make) in
            make.left.equalTo(twoImgV.snp.right).offset(10)
            make.height.width.equalTo(16)
            make.centerY.equalToSuperview()
        }
    }
    
    func setView(_ arr : [EXOTCManagerPaymentEntity]){
        oneImgV.isHidden = true
        twoImgV.isHidden = true
        threeImgV.isHidden = true
        if arr.count > 0{
            oneImgV.isHidden = false
            if let url = URL.init(string: arr[0].icon){
                oneImgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
            }
        }
        
        if arr.count > 1{
            twoImgV.isHidden = false
            if let url = URL.init(string: arr[1].icon){
                twoImgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
            }
        }
        
        if arr.count > 2{
            threeImgV.isHidden = false
            if let url = URL.init(string: arr[2].icon){
                threeImgV.yy_setImage(with: url, options: YYWebImageOptions.allowBackgroundTask)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

