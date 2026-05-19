//
//  EXFollowCoinListView.swift
//  Chainup
//
//  Created by ljw on 2023/12/19.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXFollowCoinListView: UIView {
    let baseNumber = 1000
    typealias SelectFollowCoinBlock = (CoinListEntity) -> ()
    var symbol = ""
    var mainChainNameTip = ""
    
    var selectCoinBlock : SelectFollowCoinBlock?//Select Callback
    var currentBtn = EXTextButton.init(type:.custom)//Record the currently selected button
    var selectedFollowCoinName = "" {
        didSet {
            for (idx,item) in self.followCoinListArr.enumerated() {
                if item.name == selectedFollowCoinName {
                    if let selectedBtn = self.viewWithTag(idx + baseNumber) as? EXTextButton  {
                        itemDidTapAction(sender: selectedBtn)
                    }
                    break
                }
            }
        }
    }
    
    var selectFollowCoinEntity = CoinListEntity() {//The currently selected slave chain model
        didSet {
            self.selectCoinBlock?(selectFollowCoinEntity)
        }
    }
    ///Chain Name
    lazy var linkNameLab : UILabel = {
        let linkNameLab = UILabel()
        linkNameLab.isUserInteractionEnabled = true
        let tapGesTure = UITapGestureRecognizer.init(target: self, action:#selector(describleDetail))
        linkNameLab.addGestureRecognizer(tapGesTure)
//        linkNameLab.extSetText("link_name".localized(), textColor: UIColor.ThemeLabel.colorMedium, fontSize: 12)
        linkNameLab.text = "link_name".localized()
        linkNameLab.textColor = UIColor.ThemeLabel.colorMedium
        linkNameLab.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        linkNameLab.sizeToFit()
        return linkNameLab
    }()
    ///Question mark
    lazy var questionBtn : UIButton = { [weak self] in
        let questionBtn = UIButton()
        questionBtn.isHidden = true
        questionBtn.setImage(UIImage.themeImageNamed(imageName: "public_hint").reSizeImage(reSize: CGSize(width: 12, height: 12)), for: UIControl.State.normal)
        questionBtn.addTarget(self, action: #selector(describleDetail), for: UIControl.Event.touchUpInside)
        return questionBtn
    }()
    ///From chain array
    var followCoinListArr = [CoinListEntity]()
    
    init(frame: CGRect, followCoinListArr:[CoinListEntity],symbol:String) {
        super.init(frame: frame)
        self.followCoinListArr = followCoinListArr
        self.symbol = symbol
        getLinkDescribe()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension EXFollowCoinListView {
    func setupUI() {
        let startX : CGFloat = 15
        let startY : CGFloat = 0
        self.addSubViews([linkNameLab,questionBtn])
         linkNameLab.frame = CGRect.init(x: startX, y: startY, width: linkNameLab.width, height: linkNameLab.height)
        questionBtn.frame = CGRect.init(x: linkNameLab.ext_right()+5, y: 0, width: 14, height: 14)
        questionBtn.centerY = linkNameLab.centerY
        let btnHeight : CGFloat = 26
        let horizonGap : CGFloat = SCREEN_WIDTH * 0.06
        let btnWidth : CGFloat = (SCREEN_WIDTH - 30 - horizonGap*2)/3
        let ygap : CGFloat = 15
        let column = 3;
//        var hasMain = false
        for (idx,item) in followCoinListArr.enumerated() {
            let cellItem = EXTextButton.init(type:.custom)
            cellItem.setFont(font: UIFont.ThemeFont.BodyMedium)
            cellItem.supportCheckHighlight = true
//            if item.mainChainType == "1" {
//                 cellItem.isSelected = true
//                 currentBtn = cellItem
//                 self.selectFollowCoinEntity = item
//                 hasMain = true
//            }else {
//                 cellItem.isSelected = false
//            }
            if idx == 0 {
                 cellItem.isSelected = true
                 currentBtn = cellItem
                 self.selectFollowCoinEntity = item
            }else {
                 cellItem.isSelected = false
            }

            cellItem.setColor(color:  UIColor.ThemeView.bgTab)
            cellItem.setTitleColor(UIColor.ThemeLabel.colorMedium, for: .normal)
            cellItem.setTitleColor(UIColor.ThemeLabel.colorLite, for: .selected)
            cellItem.setTitle(item.mainChainName.aliasName(), for: .normal)
            cellItem.addTarget(self, action: #selector(itemDidTapAction(sender:)), for: .touchUpInside)
            
            self.addSubview(cellItem)
            let col : CGFloat = CGFloat(CGFloat(idx %  column))
            let row : CGFloat = CGFloat(CGFloat(idx / column))
            let xPosition = (btnWidth + horizonGap)*CGFloat(col)
            let yPosition = (btnHeight + ygap)*(row) + linkNameLab.ext_bottom() + 15
            let px = CGFloat(startX) + xPosition
            let py = startY + yPosition
            cellItem.frame = CGRect(x: px, y: CGFloat(py), width: btnWidth, height: CGFloat(btnHeight))
            cellItem.tag = idx + baseNumber
         }
//        if !hasMain && self.followCoinListArr.count > 0 {//Did not return to the main chain, default to selecting the first one
//            let firstBtn = self.viewWithTag(0 + baseNumber) as? EXTextButton
//            if let firstBtn = firstBtn {
//                itemDidTapAction(sender: firstBtn)
//            }
//        }
         if let lastView = self.subviews.last {
             self.height = lastView.ext_bottom()//Highly adaptive
         }
    }
    
    @objc func describleDetail() {
        if self.mainChainNameTip.isEmpty {
            return
        }
        let normal = EXNormalAlert()
        normal.configSigleAlert(title: "link_name".localized(), message:mainChainNameTip)
        EXAlert.showAlert(alertView: normal)
    }
    @objc func itemDidTapAction(sender:EXTextButton) {
        currentBtn.isSelected = false
        sender.isSelected = true
        currentBtn = sender
        self.selectFollowCoinEntity = self.followCoinListArr[sender.tag - baseNumber]
    }
    
    func getLinkDescribe() {
        EXGetFollowCoinVm.shareInstance.getCost(symbol: self.symbol) {[weak self] (item) in
            if let model = item {
                self?.questionBtn.isHidden = model.mainChainNameTip.isEmpty
                self?.mainChainNameTip = model.mainChainNameTip
            }
        }

    }
}

