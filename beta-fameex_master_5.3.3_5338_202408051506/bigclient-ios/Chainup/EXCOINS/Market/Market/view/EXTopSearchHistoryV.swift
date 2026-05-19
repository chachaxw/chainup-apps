//
//  EXTopSearchHistoryV.swift
//  Chainup
//
//  Created by liuxuan on 2022/7/25.
//  Copyright © 2022 Chainup. All rights reserved.
//

import UIKit
import EXKit

class EXTopSearchHistoryV: UIView {
    
    let maxWidth = SCREEN_WIDTH - 32
    
    lazy var titleLabel:UILabel = {
        let t = UILabel()
        t.text = "common_action_history".localized()
        t.textColor = .Ex.text1
        t.font = .Ex.medium(16)
        return t
    }()
    
    lazy var removeBtn:UIButton = {
        let t = UIButton.init(type: .custom)
        t.setEnlargeEdgeWithTop(10, left: 10, bottom: 10, right: 10)
        t.setImage(UIImage.themeImageNamed(imageName: "public_delete_default"), for: .normal)
        return t
    }()
    
    lazy var historyContainer:EKTagView = {
        let t = EKTagView()
        return t
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews([titleLabel,removeBtn,historyContainer])
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(MARGIN_LEFT)
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview()
        }
        
        removeBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-MARGIN_LEFT)
            make.width.height.equalTo(16)
            make.centerY.equalTo(titleLabel)
        }
        
        historyContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(MARGIN_LEFT)
            make.trailing.equalToSuperview().offset(-MARGIN_LEFT)
            make.bottom.equalToSuperview()
        }
    }
    
    func bindingHistorys(coinSymbols:[String]) {
        historyContainer.subviews.forEach({$0.removeFromSuperview()})
        historyContainer.bindingTags(coinSymbols)
    }
    
    class func heightForHeader(_ coinSymbols:[String]) -> CGFloat{
        let titleH:CGFloat = 44
        let tagH:CGFloat = EKTagView.heightForTagV(coinSymbols)
        return titleH + tagH + 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
