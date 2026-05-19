//
//  TransactionDetailsHeadV.swift
//  Chainup
//
//  Created by zewu wang on 2023/8/14.
//  Copyright © 2023年 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class TransactionDetailsHeadV: UIView {
    
    typealias ClickSwitchBtnBlock = (Int) -> ()
    var clickSwitchBtnBlock : ClickSwitchBtnBlock?

    lazy var transactionHeadV : TransactionHeadV = {
        let view = TransactionHeadV()
        view.extUseAutoLayout()
        return view
    }()
    
    //K-line
    lazy var kLineDetailsV : KLineDetailsView = {
        let view = KLineDetailsView()
        view.extUseAutoLayout()
        return view
    }()
    
//    //Line below k
//    lazy var kLineDetailsBottomV : UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.black
//        view.alpha = 0.8
//        view.extUseAutoLayout()
//        return view
//    }()
    
    //Depth map
    lazy var kLineDepthView : KLineDepthView = {
        let view = KLineDepthView()
        view.extUseAutoLayout()
        return view
    }()
    
    //Line below depth
    lazy var kLineDepthBottomV : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemekLine.viewbgGap
        view.extUseAutoLayout()
        return view
    }()
    
    //Buying and selling chart
    lazy var buyAndSellView : BuyAndSellView = {
        let view = BuyAndSellView()
        view.extUseAutoLayout()
        return view
    }()
    
    //Deep click button
    lazy var depthBtn : EXDealBtn = {
        let btn = EXDealBtn()
        btn.extUseAutoLayout()
        btn.tag = 10000
        btn.extSetAddTarget(self, #selector(clickSwitchBtn))
        btn.isSelected = true
        btn.layoutIfNeeded()
        btn.lineV.backgroundColor = UIColor.ThemekLine.viewHighlight
        btn.extSetTitle(LanguageTools.getString(key: "depth"), 16, UIColor.ThemekLine.labcolorLite, UIControl.State.normal)
        return btn
    }()
    
    //Deal button
    lazy var dealBtn : EXDealBtn = {
        let btn = EXDealBtn()
        btn.extUseAutoLayout()
        btn.tag = 10001
        btn.layoutIfNeeded()
        btn.lineV.isHidden = true
        btn.extSetAddTarget(self, #selector(clickSwitchBtn))
        btn.lineV.backgroundColor = UIColor.ThemekLine.viewHighlight
        btn.extSetTitle(LanguageTools.getString(key: "recent_deal"), 16, UIColor.ThemekLine.viewHighlight, UIControl.State.selected)
        btn.extSetTitle(LanguageTools.getString(key: "recent_deal"), 16, UIColor.ThemekLine.labcolorLite, UIControl.State.normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemeView.bg
        addSubViews([transactionHeadV,kLineDetailsV,kLineDepthView,buyAndSellView,kLineDepthBottomV,depthBtn,dealBtn])
        addConstraints()
    }
    
    func addConstraints() {
        transactionHeadV.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(142)
        }
        kLineDetailsV.snp.makeConstraints { (make) in
            make.height.equalTo(425)
            make.top.equalTo(transactionHeadV.snp.bottom)
            make.left.right.equalToSuperview()
        }
        buyAndSellView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(kLineDetailsV.snp.bottom)
            make.height.equalTo(20)
        }
//        kLineDetailsBottomV.snp.makeConstraints { (make) in
//            make.height.equalTo(10)
//            make.left.right.equalToSuperview()
//            make.top.equalTo(kLineDetailsV.snp.bottom)
//        }
        kLineDepthView.snp.makeConstraints { (make) in
            make.top.equalTo(buyAndSellView.snp.bottom)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(210)
        }
        kLineDepthBottomV.snp.makeConstraints { (make) in
            make.height.equalTo(10)
            make.left.right.equalToSuperview()
            make.top.equalTo(kLineDepthView.snp.bottom).offset(20)
        }
        depthBtn.snp.makeConstraints { (make ) in
            make.top.equalTo(kLineDepthBottomV.snp.bottom).offset(16)
            make.height.equalTo(30)
            make.right.equalTo(self.snp.centerX).offset(-15)
//            make.width.lessThanOrEqualTo(200)
        }
        dealBtn.snp.makeConstraints { (make) in
            make.top.equalTo(kLineDepthBottomV.snp.bottom).offset(16)
            make.height.equalTo(30)
            make.left.equalTo(self.snp.centerX).offset(15)
//            make.width.equalTo(200)
        }
    }
    
    @objc func clickSwitchBtn(_ btn : UIButton){
        depthBtn.isSelected = depthBtn == btn
        depthBtn.lineV.isHidden = depthBtn != btn
        
        dealBtn.isSelected = dealBtn == btn
        dealBtn.lineV.isHidden = dealBtn != btn
        clickSwitchBtnBlock?(btn.tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TransactionHeadV : UIView {
    var entity = TransactionHeadEntity()
    //Index label
    lazy var indexLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.layoutIfNeeded()
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.text = "--"
        return label
    }()
    
    //Exponential pattern
    lazy var indexImgV : UIImageView = {
        let imgV = UIImageView()
        imgV.extUseAutoLayout()
        return imgV
    }()
    
    //money
    lazy var moneyLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetTextColor(UIColor.ThemekLine.labcolorMedium, fontSize: 13)
        label.text = "--"
        return label
    }()
    
    //Fluctuation range
    lazy var gainsView : TransactionDetailsHeadChildV = {
        let view = TransactionDetailsHeadChildV()
        view.extUseAutoLayout()
        view.nameLabel.text = LanguageTools.getString(key: "common_text_priceLimit")
        return view
    }()
    
    //Trading volume
    lazy var volumeView : TransactionDetailsHeadChildV = {
        let view = TransactionDetailsHeadChildV()
        view.extUseAutoLayout()
        view.nameLabel.text = LanguageTools.getString(key: "deal_quantity")
        return view
    }()
    
    //Maximum price
    lazy var highView : TransactionDetailsHeadChildV = {
        let view = TransactionDetailsHeadChildV()
        view.extUseAutoLayout()
        view.nameLabel.text = LanguageTools.getString(key: "high")
        return view
    }()
    
    //Lowest price
    lazy var lowView : TransactionDetailsHeadChildV = {
        let view = TransactionDetailsHeadChildV()
        view.extUseAutoLayout()
        view.nameLabel.text = LanguageTools.getString(key: "low")
        return view
    }()
    
    //Bottom line
    lazy var bottomV : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ThemekLine.viewbgGap
        view.extUseAutoLayout()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ThemekLine.viewBg
        addSubViews([indexLabel,indexImgV,moneyLabel,gainsView,volumeView,highView,lowView,bottomV])
        addConstraints()
        setView()
    }
    
    func addConstraints() {
        indexLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(11)
            make.height.equalTo(24)
            make.top.equalToSuperview().offset(18)
//            make.right.equalToSuperview().offset(-50)
        }
        indexImgV.snp.makeConstraints { (make) in
            make.centerY.equalTo(indexLabel)
            make.height.equalTo(17)
            make.width.equalTo(17)
            make.left.equalTo(indexLabel.snp.right).offset(5)
        }
        moneyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(indexLabel)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(14)
            make.top.equalTo(indexLabel.snp.bottom).offset(6)
        }
        gainsView.snp.makeConstraints { (make) in
            make.left.equalTo(indexLabel)
            make.right.equalTo(self.snp.centerX).offset(-11)
            make.height.equalTo(17)
            make.top.equalTo(moneyLabel.snp.bottom).offset(14)
        }
        volumeView.snp.makeConstraints { (make) in
            make.left.equalTo(indexLabel)
            make.right.equalTo(self.snp.centerX).offset(-11)
            make.height.equalTo(17)
            make.top.equalTo(gainsView.snp.bottom).offset(6)
        }
        highView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(10)
            make.height.equalTo(17)
            make.top.equalTo(gainsView)
            make.left.equalTo(self.snp.centerX).offset(10)
        }
        lowView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(10)
            make.height.equalTo(17)
            make.top.equalTo(volumeView)
            make.left.equalTo(self.snp.centerX).offset(10)
        }
        bottomV.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(10)
        }
    }
    
    func setView(){
        indexLabel.text = entity.close
        indexLabel.textColor = entity.riseorfail ? UIColor.ThemekLine.up : UIColor.ThemekLine.down
        indexImgV.image = entity.riseorfail ? UIImage.init(named: "upIndex") : UIImage.init(named: "downIndex")
        indexImgV.isHidden = entity.close == "--"
//        if let rose = Float(entity.rose){
        if entity.close != "--"{
            gainsView.valueLabel.text = entity.rose + "%"
        }else{
            gainsView.valueLabel.text = entity.rose
        }
                //String.init(format: "%.2f", rose * 100) + "%"
//        }else{
//            gainsView.valueLabel.text = "--"
//        }
        volumeView.valueLabel.text = entity.vol
        highView.valueLabel.text = entity.high
        lowView.valueLabel.text = entity.low
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TransactionDetailsHeadChildV : UIView {
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.extSetTextColor(UIColor.ThemekLine.labcolorDark, fontSize: 12)
//        label.layoutIfNeeded()
        return label
    }()
    
    lazy var valueLabel : UILabel = {
       let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemekLine.labcolorLite
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([nameLabel,valueLabel])
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.height.equalTo(13)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }
        valueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.right.equalToSuperview()
            make.height.equalTo(13)
            make.centerY.equalTo(nameLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


