//
//  EXHelpTC.swift
//  Chainup
//
//  Created by zewu wang on 2023/4/22.
//  Copyright © 2023 zewu wang. All rights reserved.
//

import UIKit
import EXKit

class EXHelpTC: UITableViewCell {
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.extUseAutoLayout()
        label.textColor = UIColor.ThemeLabel.colorLite
        label.font = UIFont.ThemeFont.BodyRegular
        return label
    }()

    lazy var lineV : UIView = {
        let view = UIView()
        view.extUseAutoLayout()
        view.backgroundColor = UIColor.ThemeView.seperator
        return view
    }()
    
    lazy var rightV : UIImageView = {
        let view = UIImageView()
        view.extUseAutoLayout()
        view.image = EXKitBundle.image(named: "public_positions_arrow_right")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var button : UIButton = {
        let btn = UIButton.init(frame: self.bounds)
        btn.backgroundColor = UIColor.clear
        btn.isUserInteractionEnabled = false
        return btn
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.extSetCell()
        contentView.addSubViews([nameLabel,lineV,rightV,button])
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(20)
            make.right.equalTo(rightV.snp.left).offset(-10)
        }
        lineV.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.height.equalTo(0.5)
        }
        rightV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(10)
            make.width.equalTo(10)
            make.right.equalToSuperview().offset(-15)
        }
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    func setCell(_ entity : EXHelpEntity){
        nameLabel.text = entity.title
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
