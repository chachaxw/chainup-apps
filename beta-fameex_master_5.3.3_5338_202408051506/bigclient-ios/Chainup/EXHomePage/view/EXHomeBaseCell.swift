//
//  EXHomeBaseCell.swift
//  Chainup
//
//  Created by liuxuan on 2023/8/13.
//  Copyright © 2023 ChainUP. All rights reserved.
//

import UIKit
import EXKit

class EXHomeBaseCell: UITableViewCell,EXReusableView {
    
    var roundCorners:Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if roundCorners {
            roundCorners(corners: [.topLeft, .topRight], radius: 20)
        }else {
            roundCorners(corners: [.topLeft,.topRight], radius: 0)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.ThemeView.bg
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        self.selectionStyle = .none
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.ThemeView.bg
        self.contentView.backgroundColor = UIColor.ThemeView.bg
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
 

}
