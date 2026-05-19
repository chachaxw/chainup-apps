//
//  EXWithdrawal recordsWithdrawal records EXWithdrawalRecordsCell.swift
//  Chainup
//
//  Created by cwd on 2023/7/25.
//  Copyright © 2023 Chainup. All rights reserved.
//

import UIKit
import EXKit
class EXRewardDetailsCell: EXBaseCell {

    var item: EXUserRewardRecoardItem? {
        didSet{
            
            guard let item = item else { return }
            titleLabel.text = item.taskName
            let interval = TimeInterval.init(item.receiveTime.bigDiv("1000")) ?? 0
            timeLabel.text  = DateTools.dateToString(interval)
            amountLabel.text = "+" + item.amount + item.coin
        }
    }
    //MARK: UI    
    override func setUpView() {
        self.contentView.addSubViews([titleLabel,amountLabel,timeLabel])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(175~)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(14)
            make.bottom.equalToSuperview().offset(-12)
        }
        amountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
    
    
    //MARK: lazy
    lazy var titleLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        label.numberOfLines = 0
        return label
    }()
    lazy var amountLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.medium(16), textColor: .Ex.text1, alignment: NSTextAlignment.right)
        label.ext_UseAutoLayout()
        return label
    }()
    lazy var timeLabel: UILabel = {
        let label = UILabel(text:"", font: .Ex.regular(12), textColor: .Ex.text2, alignment: NSTextAlignment.left)
        label.ext_UseAutoLayout()
        return label
    }()

}
