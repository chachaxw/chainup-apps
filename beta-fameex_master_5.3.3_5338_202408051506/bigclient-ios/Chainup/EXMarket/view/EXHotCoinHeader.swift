//
//  EXHotCoinHeader.swift
//  Chainup
//
//  Created by liuxuan on 2023/10/9.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit

class EXHotCoinHeader: UIView {
    
    var btnsAry:[UIButton] = []
    typealias ItemSelectedCallback = (String) -> ()
    var itemDidChangeBlock : ItemSelectedCallback?
    static let column:Int = 3

    
    lazy var containerView:UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.ThemeView.bg
        return container
    }()
    
    lazy var titleLabel:UILabel = {
        let title = UILabel()
        title.font = UIFont.ThemeFont.BodyRegular
        title.textColor = UIColor.ThemeLabel.colorMedium
        title.text = "assets_popular_crypto".localized()
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configHotCoinSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configHotCoinSubviews()
//        fatalError("init(coder:) has not been implemented")
    }
    
    func hotCoins() -> [String] {
        return EXAppCache.sharedCache.getHotCoins() ?? []
    }
    
    func configHotCoinSubviews() {
        self.backgroundColor = UIColor.ThemeView.bg
        self.addSubview(containerView)
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(15)
            make.bottom.equalTo(containerView.snp.top).offset(-15)
            make.right.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        
        let btnHeight = 30
        let horizonGap:CGFloat = 10
        let btnWidth = (SCREEN_WIDTH - 50)/3
        let ygap = 10
        let startX = 15
        let startY = 0
        
        for (idx,item) in hotCoins().enumerated() {
            
            let cellItem = UIButton.init(type:.custom)
            cellItem.layer.borderColor = UIColor.ThemeLabel.colorDark.cgColor
            cellItem.layer.cornerRadius = 4
            cellItem.layer.borderWidth = 0.5
            cellItem.titleLabel?.font =  UIFont.ThemeFont.BodyMedium
            cellItem.backgroundColor = UIColor.ThemeView.bg
            cellItem.setTitleColor(UIColor.ThemeLabel.colorLite, for: .normal)
            cellItem.setTitle(item.aliasName(), for: .normal)
            cellItem.addTarget(self, action: #selector(itemDidTapAction(sender:)), for: .touchUpInside)
            containerView.addSubview(cellItem)
            let col = idx %  EXHotCoinHeader.column
            let row = idx / EXHotCoinHeader.column
            let xPosition = (btnWidth + horizonGap)*CGFloat(col)
            let yPosition = (btnHeight + ygap)*(row)
            let px = CGFloat(startX) + xPosition
            let py = startY + yPosition
            cellItem.frame = CGRect(x: px, y: CGFloat(py), width: btnWidth, height: CGFloat(btnHeight))
            cellItem.tag = idx
            btnsAry.append(cellItem)
        }
    }
    
    @objc func itemDidTapAction(sender:UIButton) {
        let coin = self.hotCoins()[sender.tag]
        itemDidChangeBlock?(coin.aliasName())
    }
    
    class func getHeight(hotCoins:[String]) -> CGFloat{
        let quotient = hotCoins.count/self.column
        var remainder = hotCoins.count%self.column

        if remainder > 0 {
            remainder = 1
        }
        let rowHeight = (quotient + remainder)*30
        let gapHeight = (quotient + remainder - 1)*10
        return CGFloat(rowHeight + gapHeight + 25 + 44)
    }
    
}
