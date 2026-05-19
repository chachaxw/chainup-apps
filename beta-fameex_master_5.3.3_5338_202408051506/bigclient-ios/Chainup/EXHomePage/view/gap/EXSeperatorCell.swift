//
//  EXSeperatorCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/3.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit

class EXSeperatorCell: EXHomeBaseCell {

    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        view.isHidden = true
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setView()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = UIColor.ThemeNav.bg
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setView(){
        
        self.contentView.addSubview(lineV)
        lineV.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    

}
