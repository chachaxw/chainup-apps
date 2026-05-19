//
//  EXOTCOrderInfoCard.swift
//  Chainup
//
//  Created by liuxuan on 2023/3/29.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXOTCOrderInfoCard: NibBaseView {
    
    static private let itemHeight:CGFloat = 28
    @IBOutlet var headerView: EXOTCOrderInfoDisplayTitle!
    @IBOutlet var itemStack: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    
    override func onCreate() {
        titleLabel.font = UIFont.ThemeFont.HeadRegular
        titleLabel.textColor = UIColor.ThemeLabel.colorLite
        
    }
    
    func updateInfos(models:[OTCOrderInfoModel],title:String) {
        titleLabel.text = title
        for (_,item) in models.enumerated() {
            let itemView = EXOTCOrderInfoView()
            itemView.bindInfoWith(model: item)
            itemStack.addArrangedSubview(itemView)
            itemView.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                make.height.equalTo(EXOTCOrderInfoCard.itemHeight)
            }
        }
        
        let fullHeight = EXOTCOrderInfoCard.itemsHeightWithModels(models: models)
        itemStack.snp.remakeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(fullHeight)
            make.bottom.equalToSuperview()
        }
    }
    
    static func itemsHeightWithModels(models:[OTCOrderInfoModel]) -> CGFloat{
        return CGFloat(models.count) * itemHeight + CGFloat(1*(models.count - 1))
    }
    
    static func fullHeightWithModels(models:[OTCOrderInfoModel]) -> CGFloat {
        //Item height+header height+up and down gap 16
        return self.itemsHeightWithModels(models:models) + 45 + 14
    }
}

