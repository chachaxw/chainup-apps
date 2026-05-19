//
//  EXTwoByTwoTableViewCell.swift
//  Chainup
//
//  Created by chainup on 2023/8/27.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
protocol EXTwoByTwoTableViewCellDelegate {

    func leftViewDidClick(cell:EXTwoByTwoTableViewCell)
    func rightViewDidClick(cell:EXTwoByTwoTableViewCell)
}

class EXTwoByTwoTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    var delegate:EXTwoByTwoTableViewCellDelegate?
    
    private lazy var container :EXTwoByTwoContainer = {
        let rowA = EXTwoByTwoContainer()
        return rowA
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.backgroundColor = UIColor.ThemeView.bg
        contentView.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(38)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func bindCellData(model:EXTwoByTwoItemModel) {
        container.bindContainers([model], addBlock: true)
        if let view = container.containers.first,self.delegate != nil {
            view.leftViewClickBlock = {
                self.delegate?.leftViewDidClick(cell: self)
            }
            view.rightViewClickBlock = {
                self.delegate?.rightViewDidClick(cell: self)
            }
        }
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
