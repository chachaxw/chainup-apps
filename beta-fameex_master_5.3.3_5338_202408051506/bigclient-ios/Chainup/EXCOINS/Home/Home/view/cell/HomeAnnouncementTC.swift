//
//  HomeAnnouncementTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/11/9.
//  Copyright © 2023 zewu wang. All rights reserved.
//announcement

import UIKit

class HomeAnnouncementTC: UITableViewCell {
    
    lazy var label : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.SecondaryRegular
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addSubViews([label])
        if EXHomeViewModel.isUIStatusNormal() {
            contentView.backgroundColor = UIColor.ThemeView.bg
        }else if EXHomeViewModel.status() == .two{
            contentView.backgroundColor = UIColor.ThemeNav.bg
        }else if EXHomeViewModel.status() == .three{
            contentView.backgroundColor = UIColor.ThemeView.bg
        }
        label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setCell(_ entity : NoticeInfoEntity){
        label.text = entity.title
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

