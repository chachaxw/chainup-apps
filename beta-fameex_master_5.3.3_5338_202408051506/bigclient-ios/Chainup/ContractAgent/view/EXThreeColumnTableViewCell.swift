//
//  EXThreeColumnTableViewCell.swift
//  Chainup
//
//  Created by chainup on 2023/8/27.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXThreeColumnTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    private lazy var infoView: EXThreeColumnView = {
        let rowA = EXThreeColumnView()
        return rowA
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = UIColor.ThemeView.bg
        contentView.addSubview(infoView)
       
        infoView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindCellData(models:[ExThreeColumnDataModel]) {
        infoView.bindItems(with: models)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
