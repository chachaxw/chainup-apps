//
//  EXPosSetpCell.swift
//  Chainup
//
//  Created by lcus on 2023/10/11.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit
class EXPosSetpCell: UITableViewCell {

    var progrssView:EXPosStepProgressView!
    
    func setCellData(enity:EXPosDetailProtocolEnity) {
        
       
         progrssView.setTimes(enity: enity)
      
        
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
         self.selectionStyle = .none
         self.contentView.backgroundColor = UIColor.ThemeView.bg
        
        let headerTitles = ["pos_state_lockStart".localized(),
                            "pos_state_lockEnd".localized(),
                            "pos_state_InterestStart".localized(),
                            "pos_state_InterestEnd".localized()];
        
        progrssView = EXPosStepProgressView(frame: self.contentView.frame, titles: headerTitles, normalColor: .gray, highlightColor: .red);
        self.contentView .addSubview(progrssView)
        
        progrssView.snp.makeConstraints { (make) in
            
            make.top.equalTo(self.contentView).offset(10)
            make.left.equalTo(self.contentView).offset(7)
             make.right.equalTo(self.contentView).offset(-7)
            make.height.equalTo(50)
            make.bottom.equalTo(self.contentView).offset(-10).priority(.low)
            
        }
        
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
