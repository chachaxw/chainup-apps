//
//  EXTradeHeaderView.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/26.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXTradeHeaderView: UIView {
    
    lazy var marketBtn: RepeatButton = {
        
        let btn = RepeatButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.ThemeFont.H3Bold
        btn.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
        btn.setImage(UIImage.themeImageNamed(imageName: "trade_icon_switchcurrency"), for: .normal)
        return btn
    }()
    
    lazy var rateBtn: RepeatButton = {
        let btn = RepeatButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryMedium
        btn.layer.cornerRadius = 2
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return btn
    }()
    
    lazy var tagBtn: RepeatButton = {
        let btn = RepeatButton.init(type: .custom)
        btn.titleLabel?.font = UIFont.ThemeFont.SecondaryMedium
        btn.setTitleColor(UIColor.ThemeView.highlight, for: .normal)
        btn.backgroundColor = UIColor.ThemeView.highlight15
        btn.layer.cornerRadius = 2
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return btn
    }()
    
    lazy var moreBtn: RepeatButton = {
        let btn = RepeatButton.init(type: .custom)
        btn.setImage(UIImage.themeImageNamed(imageName: "trade_more"), for: .normal)
        return btn
    }()
    
    lazy var exchangeBtn: RepeatButton = {
        let btn = RepeatButton.init(type: .custom)
        btn.setImage(UIImage.themeImageNamed(imageName: "coins_switch"), for: .normal)
        return btn
    }()
    
    lazy var detailBtn: RepeatButton = {
        let btn = RepeatButton.init(type: .custom)
        btn.setImage(UIImage.themeImageNamed(imageName: "trade_details"), for: .normal)
        return btn
    }()
    
    lazy var leftContainer:UIStackView = {
        let c = UIStackView.init()
        c.axis = .horizontal
        c.spacing = 4
        return c
    }()
    
    lazy var rightContainer:UIStackView = {
        let c = UIStackView.init()
        c.axis = .horizontal
        return c
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configTradeHeader()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configTradeHeader()
    }
    
    func configTradeHeader() {
        self.addSubview(marketBtn)
        self.addSubview(leftContainer)
        self.addSubview(rightContainer)
        marketBtn.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(105)
        }
        leftContainer.snp.makeConstraints { (make) in
            make.left.equalTo(marketBtn.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
        }
        rightContainer.snp.makeConstraints { (make) in
            make.right.equalTo(-9)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        
        leftContainer.addArrangedSubview(rateBtn)
        leftContainer.addArrangedSubview(tagBtn)

        rightContainer.addArrangedSubview(detailBtn)
       // rightContainer.addArrangedSubview(exchangeBtn)
        rightContainer.addArrangedSubview(moreBtn)
        
        detailBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        exchangeBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
        
        moreBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
        }
    }
    
    func reload(show:Bool){
            exchangeBtn.isHidden = !show
//            moreBtn.isHidden = !show
    }
    func bindMenu(name:String,tag:String,rate:TickItem?) {
        marketBtn.setTitle(name, for: .normal)
        marketBtn.textSizeFit()
        if let tick = rate,tick.rose != "--" {
            rateBtn.isHidden = false
            let color = tick.riseorfail ? UIColor.ThemekLine.up :UIColor.ThemekLine.down
            rateBtn.setTitle(tick.rose + "%", for: .normal)
            rateBtn.setTitleColor(color, for:.normal)
            rateBtn.backgroundColor = color.withAlphaComponent(0.15)

        }else {
            rateBtn.isHidden = true
        }
        
        if tag.count > 0 {
            tagBtn.isHidden = false
            tagBtn.setTitle(tag, for: .normal)
        }else {
            tagBtn.isHidden = true
        }
    }
}

extension UIButton{
    func textSizeFit(imageWidth: CGFloat = 20,space: CGFloat = 4)  {
        guard let text = self.titleLabel?.text else{
            return
        }
        //Left and right spacing image
        let titleLabelsize = text.textSizeWithFont(titleLabel!.font, width: SCREEN_WIDTH)
        var totalW = titleLabelsize.width + imageWidth + space + 5
        if totalW >= SCREEN_WIDTH {
            totalW = SCREEN_WIDTH - 10
        }
        self.snp_updateConstraints { make in
            make.width.equalTo(totalW)
        }
    }
    
    func textWidthFit(space: CGFloat = 4) -> CGFloat {
        guard let text = self.titleLabel?.text else{
           return 0
        }
        //Left and right spacing image
        var imageWidth: CGFloat = 0
        if let imageV = self.imageView {
            imageWidth = imageV.size.width
        }
        let titleLabelsize = text.textSizeWithFont(titleLabel!.font, width: SCREEN_WIDTH)
        let totalW = titleLabelsize.width + imageWidth + space + 5
        return totalW
    }
    
}

